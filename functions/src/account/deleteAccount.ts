import * as admin from 'firebase-admin';
import { logger } from 'firebase-functions/v2';
import { onCall } from 'firebase-functions/v2/https';

import { requireAuth } from '../utils/auth';
import { toHttpsError } from '../utils/errors';

/**
 * Security finding F5.1 — App Store / Play Store + GDPR / CCPA compliance.
 *
 * Cascade delete of users/{uid}: cases subtree, usage subtree, anonymize
 * feedback and moderationLogs by nulling the userId. Then deletes the auth
 * user. Idempotent (a re-call after a partial failure resumes cleanup).
 */
export const deleteAccount = onCall(
  {
    region: 'us-central1',
    enforceAppCheck: true,
    memory: '512MiB',
    timeoutSeconds: 120,
  },
  async (request) => {
    try {
      const auth = requireAuth(request);
      const db = admin.firestore();
      const uid = auth.uid;

      await deleteSubcollection(
        db,
        db.collection('users').doc(uid).collection('cases'),
      );
      await deleteSubcollection(
        db,
        db.collection('users').doc(uid).collection('usage'),
      );

      await anonymizeQuery(
        db.collection('feedback').where('userId', '==', uid),
      );
      await anonymizeQuery(
        db.collection('moderationLogs').where('userId', '==', uid),
      );

      await db.collection('users').doc(uid).delete();

      try {
        await admin.auth().deleteUser(uid);
      } catch (error) {
        logger.warn('account.delete_auth_failed', {
          uid,
          error: String(error),
        });
      }

      logger.info('account.deleted', { uid });
      return { ok: true };
    } catch (error) {
      throw toHttpsError(error);
    }
  },
);

async function deleteSubcollection(
  db: admin.firestore.Firestore,
  ref: admin.firestore.CollectionReference,
): Promise<void> {
  const batchSize = 250;
  while (true) {
    const snap = await ref.limit(batchSize).get();
    if (snap.empty) return;
    const batch = db.batch();
    snap.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
    if (snap.size < batchSize) return;
  }
}

async function anonymizeQuery(
  query: admin.firestore.Query,
): Promise<void> {
  const batchSize = 250;
  let lastDoc: admin.firestore.QueryDocumentSnapshot | null = null;
  while (true) {
    let q = query.limit(batchSize);
    if (lastDoc) q = q.startAfter(lastDoc);
    const snap = await q.get();
    if (snap.empty) return;
    const batch = snap.docs[0].ref.firestore.batch();
    snap.docs.forEach((doc) => batch.update(doc.ref, { userId: null }));
    await batch.commit();
    if (snap.size < batchSize) return;
    lastDoc = snap.docs[snap.size - 1];
  }
}
