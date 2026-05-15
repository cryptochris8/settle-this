import * as admin from 'firebase-admin';
import { onCall } from 'firebase-functions/v2/https';

import { dateKey, requireAuth } from '../utils/auth';
import { toHttpsError } from '../utils/errors';
import { DEFAULT_QUOTA } from '../utils/quota';

export const getUserUsage = onCall(
  { region: 'us-central1', enforceAppCheck: true },
  async (request) => {
    try {
      const auth = requireAuth(request);
      const db = admin.firestore();

      const today = dateKey();
      const [usageSnap, userSnap] = await Promise.all([
        db
          .collection('users')
          .doc(auth.uid)
          .collection('usage')
          .doc(today)
          .get(),
        db.collection('users').doc(auth.uid).get(),
      ]);

      const free = (usageSnap.get('freeVerdictsUsed') as number | undefined) ?? 0;
      const paid = (usageSnap.get('paidVerdictsUsed') as number | undefined) ?? 0;
      const subscriptionStatus =
        (userSnap.get('subscription.status') as string | undefined) ?? 'free';
      const isPaid =
        subscriptionStatus === 'plus' || subscriptionStatus === 'trial';

      return {
        dateKey: today,
        freeVerdictsUsed: free,
        paidVerdictsUsed: paid,
        freeVerdictsPerDay: DEFAULT_QUOTA.freeVerdictsPerDay,
        remainingFreeVerdicts: Math.max(
          0,
          DEFAULT_QUOTA.freeVerdictsPerDay - free,
        ),
        subscriptionStatus,
        isPaid,
      };
    } catch (error) {
      throw toHttpsError(error);
    }
  },
);
