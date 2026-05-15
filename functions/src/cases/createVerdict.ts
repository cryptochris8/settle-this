import * as admin from 'firebase-admin';
import { logger } from 'firebase-functions/v2';
import { onCall } from 'firebase-functions/v2/https';

import { OPENAI_API_KEY } from '../ai/openaiClient';
import { PROMPT_VERSION } from '../ai/prompts';
import { classifySafety } from '../ai/safetyClassifier';
import {
  CreateVerdictInputSchema,
  type Verdict,
  VerdictResponseSchema,
} from '../ai/schemas';
import {
  BLOCKED_TEMPLATE,
  generateVerdict,
  SOFT_REDIRECT_TEMPLATE,
} from '../ai/verdictGenerator';
import { requireAuth } from '../utils/auth';
import { AppError, toHttpsError } from '../utils/errors';
import { detectPii, normalizeUserInput, redactPii } from '../utils/pii';
import { reserveVerdictSlot } from '../utils/quota';

export const createVerdict = onCall(
  {
    region: 'us-central1',
    enforceAppCheck: true,
    secrets: [OPENAI_API_KEY],
    memory: '512MiB',
    timeoutSeconds: 60,
  },
  async (request) => {
    try {
      const auth = requireAuth(request);
      const input = CreateVerdictInputSchema.parse(request.data);

      const scenario = normalizeUserInput(input.scenario);
      const sideA = normalizeUserInput(input.sideA);
      const sideB = normalizeUserInput(input.sideB);

      const piiFlags = detectPii(`${scenario}\n${sideA}\n${sideB}`);
      const redactedContent = {
        scenario: piiFlags.any ? redactPii(scenario) : scenario,
        sideA: piiFlags.any ? redactPii(sideA) : sideA,
        sideB: piiFlags.any ? redactPii(sideB) : sideB,
        relationshipType: input.relationshipType,
        tone: input.tone,
      };

      const db = admin.firestore();
      const userSnap = await db.collection('users').doc(auth.uid).get();
      const subscriptionStatus =
        (userSnap.get('subscription.status') as string | undefined) ?? 'free';
      const isPaid = subscriptionStatus === 'plus' || subscriptionStatus === 'trial';

      await reserveVerdictSlot({
        uid: auth.uid,
        isPaid,
        isAnonymous: auth.isAnonymous,
        db,
      });

      const safety = await classifySafety(redactedContent);

      const caseId = db
        .collection('users')
        .doc(auth.uid)
        .collection('cases')
        .doc().id;

      let verdict: Verdict;
      let status: 'completed' | 'blocked' | 'needs_soft_redirect';

      if (safety.action === 'block') {
        verdict = BLOCKED_TEMPLATE;
        status = 'blocked';
      } else if (safety.action === 'soft_redirect') {
        verdict = SOFT_REDIRECT_TEMPLATE;
        status = 'needs_soft_redirect';
      } else {
        try {
          verdict = await generateVerdict(redactedContent);
          status = 'completed';
        } catch (error) {
          logger.warn('verdict.generation_failed_falling_back', {
            error: String(error),
          });
          verdict = SOFT_REDIRECT_TEMPLATE;
          status = 'needs_soft_redirect';
        }
      }

      const safeForShare =
        status === 'completed' &&
        safety.safeForShare &&
        safety.riskLevel === 'low' &&
        !piiFlags.any &&
        verdict.shareCard !== null;

      if (!safeForShare) {
        verdict = { ...verdict, shareCard: null };
      }

      if (input.saveCase || status !== 'completed') {
        await persistCase({
          db,
          uid: auth.uid,
          caseId,
          input,
          piiFlags: piiFlags.any,
          safety,
          verdict,
          status,
          model: 'gpt-4o-mini',
        });
      }

      await db.collection('moderationLogs').add({
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        userId: auth.uid,
        caseId,
        riskLevel: safety.riskLevel,
        categories: safety.categories,
        action: safety.action,
        promptVersion: PROMPT_VERSION,
      });

      const response = VerdictResponseSchema.parse({
        caseId,
        status,
        verdict,
      });

      logger.info('verdict.completed', {
        promptVersion: PROMPT_VERSION,
        status,
        riskLevel: safety.riskLevel,
        saveCase: input.saveCase,
      });

      return response;
    } catch (error) {
      logger.error('verdict.failed', {
        error: error instanceof Error ? error.message : String(error),
      });
      if (error instanceof AppError) throw toHttpsError(error);
      // Zod parse errors come up here
      throw toHttpsError(
        new AppError(
          'invalid_input',
          error instanceof Error ? error.message : 'Invalid input.',
        ),
      );
    }
  },
);

interface PersistCaseArgs {
  db: admin.firestore.Firestore;
  uid: string;
  caseId: string;
  input: ReturnType<typeof CreateVerdictInputSchema.parse>;
  piiFlags: boolean;
  safety: Awaited<ReturnType<typeof classifySafety>>;
  verdict: Verdict;
  status: 'completed' | 'blocked' | 'needs_soft_redirect';
  model: string;
}

async function persistCase(args: PersistCaseArgs): Promise<void> {
  const {
    db,
    uid,
    caseId,
    input,
    piiFlags,
    safety,
    verdict,
    status,
    model,
  } = args;
  const now = admin.firestore.FieldValue.serverTimestamp();

  await db
    .collection('users')
    .doc(uid)
    .collection('cases')
    .doc(caseId)
    .set({
      caseId,
      userId: uid,
      createdAt: now,
      updatedAt: now,
      promptVersion: PROMPT_VERSION,
      model,
      relationshipType: input.relationshipType,
      tone: input.tone,
      status,
      input: {
        scenarioSanitized: redactPii(normalizeUserInput(input.scenario)),
        sideASanitized: redactPii(normalizeUserInput(input.sideA)),
        sideBSanitized: redactPii(normalizeUserInput(input.sideB)),
        inputCharCount:
          (input.scenario?.length ?? 0) +
          (input.sideA?.length ?? 0) +
          (input.sideB?.length ?? 0),
        containsPotentialPII: piiFlags,
      },
      safety: {
        riskLevel: safety.riskLevel,
        categories: safety.categories,
        blockedReason: safety.action === 'block' ? safety.reason : null,
        safeForHumor: safety.safeForHumor,
        safeForShare:
          status === 'completed' &&
          safety.safeForShare &&
          safety.riskLevel === 'low' &&
          !piiFlags,
      },
      verdict,
      share: {
        shareCount: 0,
        lastSharedAt: null,
        shareCardTitle: verdict.shareCard?.headline ?? null,
      },
      feedback: {
        userRating: null,
        wasHelpful: null,
        wasFunny: null,
        wasFair: null,
        reported: false,
      },
      deletedAt: null,
    });

  await db
    .collection('users')
    .doc(uid)
    .set(
      {
        counters: {
          totalCasesCreated: admin.firestore.FieldValue.increment(1),
        },
        lastActiveAt: now,
      },
      { merge: true },
    );
}
