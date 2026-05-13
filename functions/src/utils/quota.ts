import { firestore } from 'firebase-admin';

import { AppError } from './errors';
import { dateKey } from './auth';

export interface QuotaPolicy {
  freeVerdictsPerDay: number;
  paidDailySoftCap: number;
  anonymousLifetimeCap: number;
}

// TODO(launch): revert to {free: 3, anon: 2} before public launch. These are
// loose limits for in-dev iteration so the user can test prompts/UI without
// hitting quota every few minutes. paidDailySoftCap stays put.
export const DEFAULT_QUOTA: QuotaPolicy = {
  freeVerdictsPerDay: 20,
  paidDailySoftCap: 100,
  anonymousLifetimeCap: 50,
};

interface ReserveArgs {
  uid: string;
  isPaid: boolean;
  isAnonymous: boolean;
  policy?: QuotaPolicy;
  db: firestore.Firestore;
}

/**
 * Atomically reserves one verdict slot. Returns the reserved usage doc snapshot.
 *
 * Security finding F7.1 — quota check + increment in a single transaction so
 * parallel callable invocations cannot bypass the daily limit.
 */
export async function reserveVerdictSlot({
  uid,
  isPaid,
  isAnonymous,
  policy = DEFAULT_QUOTA,
  db,
}: ReserveArgs): Promise<void> {
  const today = dateKey();
  const usageRef = db
    .collection('users')
    .doc(uid)
    .collection('usage')
    .doc(today);
  const userRef = db.collection('users').doc(uid);

  await db.runTransaction(async (tx) => {
    const [usageSnap, userSnap] = await Promise.all([
      tx.get(usageRef),
      tx.get(userRef),
    ]);

    const free = (usageSnap.get('freeVerdictsUsed') as number | undefined) ?? 0;
    const paid = (usageSnap.get('paidVerdictsUsed') as number | undefined) ?? 0;
    const anonTotal =
      (userSnap.get('totalAnonymousVerdicts') as number | undefined) ?? 0;

    if (isAnonymous && anonTotal >= policy.anonymousLifetimeCap) {
      throw new AppError(
        'quota_exceeded',
        'Anonymous trial limit reached. Sign in to keep going.',
      );
    }

    if (!isPaid && free >= policy.freeVerdictsPerDay) {
      throw new AppError(
        'quota_exceeded',
        "You're out of free verdicts for today.",
      );
    }

    if (isPaid && paid >= policy.paidDailySoftCap) {
      throw new AppError(
        'quota_exceeded',
        "You've hit today's verdict limit. The courtroom reopens tomorrow.",
      );
    }

    const now = firestore.FieldValue.serverTimestamp();
    if (isPaid) {
      tx.set(
        usageRef,
        {
          dateKey: today,
          userId: uid,
          paidVerdictsUsed: firestore.FieldValue.increment(1),
          lastUpdatedAt: now,
        },
        { merge: true },
      );
    } else {
      tx.set(
        usageRef,
        {
          dateKey: today,
          userId: uid,
          freeVerdictsUsed: firestore.FieldValue.increment(1),
          lastUpdatedAt: now,
        },
        { merge: true },
      );
    }

    if (isAnonymous) {
      tx.set(
        userRef,
        {
          totalAnonymousVerdicts: firestore.FieldValue.increment(1),
        },
        { merge: true },
      );
    }
  });
}
