import { logger } from 'firebase-functions/v2';

import { AppError } from '../utils/errors';
import { AI_MODEL_VERDICT, openaiClient } from './openaiClient';
import {
  buildUserMessage,
  PROMPT_VERSION,
  REPAIR_SYSTEM_PROMPT,
  toneInstruction,
  VERDICT_GENERATOR_SYSTEM_PROMPT,
  type UserContent,
} from './prompts';
import { postCheckIsUnsafe } from './safetyClassifier';
import { type Verdict, VerdictOutputSchema } from './schemas';

/**
 * Generates a verdict for an allowed case. Validates with Zod; on failure,
 * runs one repair pass (security finding F4.3 — repair prompt does NOT echo
 * bad output back); on second failure throws ai_validation_failed so the
 * caller can fall back to a safe template.
 */
export async function generateVerdict(content: UserContent): Promise<Verdict> {
  const client = openaiClient();

  let raw: string;
  try {
    const response = await client.chat.completions.create({
      model: AI_MODEL_VERDICT,
      temperature: 0.6,
      response_format: { type: 'json_object' },
      messages: [
        { role: 'system', content: VERDICT_GENERATOR_SYSTEM_PROMPT },
        { role: 'system', content: toneInstruction(content) },
        { role: 'user', content: buildUserMessage(content) },
      ],
    });
    raw = response.choices[0]?.message.content ?? '';
  } catch (error) {
    throw new AppError(
      'ai_generation_failed',
      'Verdict generation failed.',
      error,
    );
  }

  const firstAttempt = parseAndValidate(raw);
  if (firstAttempt.ok) {
    return guardOutput(firstAttempt.value);
  }

  logger.info('verdict.repair_attempt', {
    promptVersion: PROMPT_VERSION,
    issues: firstAttempt.issueSummary,
  });

  let repaired: string;
  try {
    const response = await client.chat.completions.create({
      model: AI_MODEL_VERDICT,
      temperature: 0,
      response_format: { type: 'json_object' },
      messages: [
        { role: 'system', content: VERDICT_GENERATOR_SYSTEM_PROMPT },
        { role: 'system', content: toneInstruction(content) },
        { role: 'user', content: buildUserMessage(content) },
        { role: 'system', content: REPAIR_SYSTEM_PROMPT },
      ],
    });
    repaired = response.choices[0]?.message.content ?? '';
  } catch (error) {
    throw new AppError(
      'ai_validation_failed',
      'Verdict could not be repaired.',
      error,
    );
  }

  const second = parseAndValidate(repaired);
  if (!second.ok) {
    throw new AppError('ai_validation_failed', 'Verdict JSON invalid twice.');
  }
  return guardOutput(second.value);
}

interface ParseSuccess {
  ok: true;
  value: Verdict;
}

interface ParseFailure {
  ok: false;
  issueSummary: string[];
}

function parseAndValidate(raw: string): ParseSuccess | ParseFailure {
  let parsed: unknown;
  try {
    parsed = JSON.parse(raw);
  } catch {
    return { ok: false, issueSummary: ['parse_error'] };
  }
  const result = VerdictOutputSchema.safeParse(parsed);
  if (!result.success) {
    return {
      ok: false,
      issueSummary: result.error.issues.map(
        (i) => `${i.path.join('.')}:${i.code}`,
      ),
    };
  }
  return { ok: true, value: result.data };
}

/**
 * Generator-side post-check (security finding F3.1). If the verdict body or
 * share card contains unsafe content, strip the share card and append a
 * safety note rather than persisting it.
 */
function guardOutput(v: Verdict): Verdict {
  const flat = [
    v.title,
    v.summaryVerdict,
    v.funnyFinalRuling,
    v.textToSend,
    v.shareCard?.headline ?? '',
    v.shareCard?.verdictOneLiner ?? '',
    v.shareCard?.shortRuling ?? '',
  ].join('\n');

  if (postCheckIsUnsafe(flat)) {
    logger.warn('verdict.post_check_failed');
    return {
      ...v,
      shareCard: null,
      safetyNote:
        v.safetyNote ??
        'This verdict was scrubbed of unsafe content; share is disabled.',
      funnyFinalRuling: '',
    };
  }
  return v;
}

export const SOFT_REDIRECT_TEMPLATE: Verdict = {
  title: 'This one deserves a serious response',
  summaryVerdict:
    "This sounds bigger than a lighthearted everyday disagreement. Settle This can help you organize your thoughts, but this may deserve a real conversation with trusted support or a qualified professional.",
  whoWasMoreRight: 'unclear',
  confidence: 'low',
  sideAGotRight: '',
  sideBGotRight: '',
  whatWasMissed:
    'Some situations are harder than a chore-chart squabble — context that is not in this app may matter most.',
  practicalFix:
    'Consider talking to a trusted friend, family member, or a relevant professional. If anyone is unsafe, prioritize safety first.',
  funnyFinalRuling: '',
  textToSend: '',
  shareCard: null,
  safetyNote:
    "This is outside the app's lighthearted dispute-referee mode.",
};

export const BLOCKED_TEMPLATE: Verdict = {
  title: 'We can’t weigh in on this one',
  summaryVerdict:
    'This topic falls outside what Settle This can help with. We keep it limited to low-stakes everyday disagreements.',
  whoWasMoreRight: 'unclear',
  confidence: 'low',
  sideAGotRight: '',
  sideBGotRight: '',
  whatWasMissed: '',
  practicalFix: '',
  funnyFinalRuling: '',
  textToSend: '',
  shareCard: null,
  safetyNote: 'Settle This does not generate verdicts for serious or unsafe topics.',
};
