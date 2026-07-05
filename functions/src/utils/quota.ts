import { firestore } from 'firebase-admin';

import { AppError } from './errors';
import { dateKey } from './auth';

export interface QuotaPolicy {
  freeVerdictsPerDay: number;
  paidDailySoftCap: number;
}

export const DEFAULT_QUOTA: QuotaPolicy = {
  freeVerdictsPerDay: 3,
  paidDailySoftCap: 100,
};

interface ReserveArgs {
  uid: string;
  isPaid: boolean;
  policy?: QuotaPolicy;
  db: firestore.Firestore;
}

/**
 * Atomically reserves one verdict slot.
 *
 * Security finding F7.1 — the quota check and increment run in a single
 * transaction so parallel callable invocations cannot bypass the daily limit.
 *
 * Anonymous users are treated as the standard free tier (freeVerdictsPerDay).
 * There is intentionally no separate anonymous lifetime cap: social sign-in is
 * the eventual upgrade path, but until it ships an anon user IS the free tier,
 * and the client UI advertises the daily allowance.
 */
export async function reserveVerdictSlot({
  uid,
  isPaid,
  policy = DEFAULT_QUOTA,
  db,
}: ReserveArgs): Promise<void> {
  const today = dateKey();
  const usageRef = db
    .collection('users')
    .doc(uid)
    .collection('usage')
    .doc(today);

  await db.runTransaction(async (tx) => {
    const usageSnap = await tx.get(usageRef);

    const free = (usageSnap.get('freeVerdictsUsed') as number | undefined) ?? 0;
    const paid = (usageSnap.get('paidVerdictsUsed') as number | undefined) ?? 0;

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
  });
}
