import * as admin from 'firebase-admin';
import { onCall } from 'firebase-functions/v2/https';
import { z } from 'zod';

import { requireAuth } from '../utils/auth';
import { AppError, toHttpsError } from '../utils/errors';

const DeleteCaseInputSchema = z.object({
  caseId: z.string().min(1).max(64),
  hard: z.boolean().default(false),
});

export const deleteCase = onCall(
  { region: 'us-central1', enforceAppCheck: true },
  async (request) => {
    try {
      const auth = requireAuth(request);
      const { caseId, hard } = DeleteCaseInputSchema.parse(request.data);
      const db = admin.firestore();
      const ref = db
        .collection('users')
        .doc(auth.uid)
        .collection('cases')
        .doc(caseId);
      const snap = await ref.get();
      if (!snap.exists) {
        throw new AppError('not_found', 'Case not found.');
      }

      if (hard) {
        await ref.delete();
      } else {
        await ref.update({
          deletedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
      return { ok: true };
    } catch (error) {
      throw toHttpsError(error);
    }
  },
);
