import { timingSafeEqual } from 'node:crypto';

import * as admin from 'firebase-admin';
import { defineSecret } from 'firebase-functions/params';
import { logger } from 'firebase-functions/v2';
import { onRequest } from 'firebase-functions/v2/https';

const REVENUECAT_WEBHOOK_SECRET = defineSecret('REVENUECAT_WEBHOOK_SECRET');

interface RevenueCatEvent {
  type: string;
  app_user_id?: string;
  original_app_user_id?: string;
  id?: string;
  product_id?: string;
  expiration_at_ms?: number;
  entitlement_ids?: string[];
}

/**
 * Security finding F2.3 — constant-time secret comparison + replay protection.
 * Rejects events whose `id` is already in `processedEvents/{id}`.
 */
export const revenueCatWebhook = onRequest(
  {
    region: 'us-central1',
    secrets: [REVENUECAT_WEBHOOK_SECRET],
  },
  async (req, res) => {
    if (req.method !== 'POST') {
      res.status(405).send('Method not allowed');
      return;
    }

    const expectedSecret =
      process.env.REVENUECAT_WEBHOOK_SECRET ?? REVENUECAT_WEBHOOK_SECRET.value();
    const provided = req.get('Authorization')?.replace(/^Bearer\s+/i, '') ?? '';

    if (!expectedSecret || provided.length !== expectedSecret.length) {
      res.status(401).send('unauthorized');
      return;
    }

    const expectedBuf = Buffer.from(expectedSecret);
    const providedBuf = Buffer.from(provided);
    if (
      providedBuf.length !== expectedBuf.length ||
      !timingSafeEqual(providedBuf, expectedBuf)
    ) {
      res.status(401).send('unauthorized');
      return;
    }

    const body = req.body as { event?: RevenueCatEvent } | undefined;
    const event = body?.event;
    if (!event?.id || !event.type) {
      res.status(400).send('bad event');
      return;
    }

    const db = admin.firestore();
    const eventRef = db.collection('processedEvents').doc(event.id);
    const seen = await eventRef.get();
    if (seen.exists) {
      res.status(200).send('duplicate');
      return;
    }

    const uid = event.app_user_id ?? event.original_app_user_id;
    if (!uid) {
      res.status(400).send('missing app_user_id');
      return;
    }

    const { status, currentPeriodEnd } = mapEventToSubscription(event);

    await db.collection('users').doc(uid).set(
      {
        subscription: {
          status,
          revenueCatCustomerId: uid,
          entitlement: event.entitlement_ids?.[0] ?? null,
          currentPeriodEnd,
        },
      },
      { merge: true },
    );

    await eventRef.set({
      type: event.type,
      receivedAt: admin.firestore.FieldValue.serverTimestamp(),
      uid,
    });

    logger.info('billing.event_processed', {
      type: event.type,
      uid,
      status,
    });

    res.status(200).send('ok');
  },
);

function mapEventToSubscription(event: RevenueCatEvent): {
  status: 'free' | 'trial' | 'plus' | 'expired';
  currentPeriodEnd: admin.firestore.Timestamp | null;
} {
  const expiresAt = event.expiration_at_ms
    ? admin.firestore.Timestamp.fromMillis(event.expiration_at_ms)
    : null;

  switch (event.type) {
    case 'INITIAL_PURCHASE':
    case 'RENEWAL':
    case 'PRODUCT_CHANGE':
    case 'UNCANCELLATION':
      return { status: 'plus', currentPeriodEnd: expiresAt };
    case 'NON_RENEWING_PURCHASE':
      return { status: 'plus', currentPeriodEnd: expiresAt };
    case 'TRIAL_STARTED':
    case 'TRIAL_CONVERTED':
      return { status: 'trial', currentPeriodEnd: expiresAt };
    case 'EXPIRATION':
    case 'CANCELLATION':
    case 'BILLING_ISSUE':
      return { status: 'expired', currentPeriodEnd: expiresAt };
    default:
      return { status: 'free', currentPeriodEnd: null };
  }
}
