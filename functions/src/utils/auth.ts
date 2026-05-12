import type { CallableRequest } from 'firebase-functions/v2/https';

import { AppError } from './errors';

export interface AuthedContext {
  uid: string;
  isAnonymous: boolean;
  email: string | null;
  appCheckPassed: boolean;
}

export function requireAuth<T>(request: CallableRequest<T>): AuthedContext {
  if (!request.auth) {
    throw new AppError('not_authenticated', 'You must be signed in.');
  }
  return {
    uid: request.auth.uid,
    isAnonymous: request.auth.token.firebase?.sign_in_provider === 'anonymous',
    email: request.auth.token.email ?? null,
    appCheckPassed: request.app !== undefined,
  };
}

/**
 * Per-day key in YYYYMMDD form, in UTC. Backend treats UTC as the boundary so
 * that quota arithmetic is consistent across timezones.
 */
export function dateKey(now: Date = new Date()): string {
  const y = now.getUTCFullYear().toString().padStart(4, '0');
  const m = (now.getUTCMonth() + 1).toString().padStart(2, '0');
  const d = now.getUTCDate().toString().padStart(2, '0');
  return `${y}${m}${d}`;
}
