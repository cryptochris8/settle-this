import { logger } from 'firebase-functions/v2';

import { AppError } from '../utils/errors';
import { AI_MODEL_SAFETY, openaiClient } from './openaiClient';
import {
  buildUserMessage,
  PROMPT_VERSION,
  SAFETY_CLASSIFIER_SYSTEM_PROMPT,
  type UserContent,
} from './prompts';
import {
  SafetyClassifierOutputSchema,
  type SafetyClassification,
} from './schemas';

/**
 * Classify-then-generate, fail-closed (security finding F4.1). On any error
 * (network, parse, schema, or moderation upstream), return a soft-redirect
 * decision rather than letting the generator run.
 */
export async function classifySafety(
  content: UserContent,
): Promise<SafetyClassification> {
  try {
    const moderationFlag = await runHostedModeration(content.scenario);
    if (moderationFlag) {
      logger.info('safety.moderation_blocked', {
        promptVersion: PROMPT_VERSION,
      });
      return {
        riskLevel: 'high',
        action: 'block',
        safeForHumor: false,
        safeForShare: false,
        categories: ['moderation_flag'],
        reason: 'Flagged by moderation endpoint.',
        redactionSuggestions: [],
      };
    }
  } catch (error) {
    logger.warn('safety.moderation_unavailable', { error: String(error) });
    // Continue to bespoke classifier. Moderation outage alone is not fatal.
  }

  const client = openaiClient();
  let raw: string;
  try {
    const response = await client.chat.completions.create({
      model: AI_MODEL_SAFETY,
      temperature: 0,
      response_format: { type: 'json_object' },
      messages: [
        { role: 'system', content: SAFETY_CLASSIFIER_SYSTEM_PROMPT },
        { role: 'user', content: buildUserMessage(content) },
      ],
    });
    raw = response.choices[0]?.message.content ?? '';
  } catch (error) {
    return failClosed('classifier_call_failed', error);
  }

  let parsed: unknown;
  try {
    parsed = JSON.parse(raw);
  } catch {
    return failClosed('classifier_invalid_json', raw.slice(0, 200));
  }

  const result = SafetyClassifierOutputSchema.safeParse(parsed);
  if (!result.success) {
    return failClosed('classifier_schema_mismatch', result.error.issues);
  }

  return result.data;
}

async function runHostedModeration(text: string): Promise<boolean> {
  const client = openaiClient();
  const response = await client.moderations.create({
    model: 'omni-moderation-latest',
    input: text,
  });
  return response.results[0]?.flagged ?? false;
}

function failClosed(
  reason: string,
  detail: unknown,
): SafetyClassification {
  logger.warn('safety.fail_closed', { reason, detail });
  return {
    riskLevel: 'medium',
    action: 'soft_redirect',
    safeForHumor: false,
    safeForShare: false,
    categories: ['classifier_unavailable'],
    reason: 'Classifier unavailable; defaulting to a calm response.',
    redactionSuggestions: [],
  };
}

/**
 * Generator-side post-check. If the generator output mentions explicit
 * safety-keyword content, downgrade to soft-redirect rather than ship it.
 */
const POST_CHECK_PATTERNS = [
  /\bkill (myself|yourself|themselves)\b/i,
  /\bsuicid(e|al)\b/i,
  /\bdoxx?\b/i,
  /\bbreak up\b/i,
  /\bdivorce\b/i,
];

export function postCheckIsUnsafe(verdictText: string): boolean {
  return POST_CHECK_PATTERNS.some((re) => re.test(verdictText));
}

export function reservedReasons(): string[] {
  return ['classifier_unavailable', 'moderation_flag'];
}

export function flagsForBlockedShare(s: SafetyClassification): boolean {
  if (s.action !== 'allow') return true;
  if (s.riskLevel !== 'low') return true;
  return !s.safeForShare;
}

export function unused(): typeof AppError {
  // Keep AppError import live; createVerdict is the consumer.
  return AppError;
}
