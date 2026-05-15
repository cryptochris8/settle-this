import * as admin from 'firebase-admin';
import { onCall } from 'firebase-functions/v2/https';

import { PROMPT_VERSION } from '../ai/prompts';
import { FeedbackInputSchema } from '../ai/schemas';
import { requireAuth } from '../utils/auth';
import { AppError, toHttpsError } from '../utils/errors';

export const submitFeedback = onCall(
  { region: 'us-central1', enforceAppCheck: true },
  async (request) => {
    try {
      const auth = requireAuth(request);
      const input = FeedbackInputSchema.parse(request.data);
      const db = admin.firestore();

      const caseRef = db
        .collection('users')
        .doc(auth.uid)
        .collection('cases')
        .doc(input.caseId);
      const caseSnap = await caseRef.get();
      if (!caseSnap.exists) {
        throw new AppError('not_found', 'Case not found.');
      }

      const tone = caseSnap.get('tone') as string | undefined;

      const feedbackRef = db.collection('feedback').doc();
      await feedbackRef.set({
        feedbackId: feedbackRef.id,
        caseId: input.caseId,
        userId: auth.uid,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        rating: input.rating,
        tags: input.tags,
        freeText: input.freeText ?? null,
        tone: tone ?? null,
        promptVersion: PROMPT_VERSION,
      });

      const updates: Record<string, unknown> = {
        'feedback.userRating': input.rating,
        'feedback.wasHelpful': input.tags.includes('helpful'),
        'feedback.wasFunny': input.tags.includes('funny'),
        'feedback.wasFair': input.tags.includes('fair'),
        'feedback.reported': input.tags.includes('unsafe'),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };
      await caseRef.update(updates);

      return { ok: true, feedbackId: feedbackRef.id };
    } catch (error) {
      throw toHttpsError(error);
    }
  },
);
