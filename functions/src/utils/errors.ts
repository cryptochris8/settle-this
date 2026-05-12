import { FunctionsErrorCode, HttpsError } from 'firebase-functions/v2/https';

export type AppErrorCode =
  | 'invalid_input'
  | 'quota_exceeded'
  | 'safety_blocked'
  | 'ai_generation_failed'
  | 'ai_validation_failed'
  | 'not_authenticated'
  | 'permission_denied'
  | 'not_found'
  | 'rate_limited'
  | 'unknown_error';

export class AppError extends Error {
  constructor(
    public readonly code: AppErrorCode,
    message: string,
    public readonly cause?: unknown,
  ) {
    super(message);
    this.name = 'AppError';
  }
}

const HTTPS_ERROR_MAP: Record<AppErrorCode, FunctionsErrorCode> = {
  invalid_input: 'invalid-argument',
  quota_exceeded: 'resource-exhausted',
  safety_blocked: 'failed-precondition',
  ai_generation_failed: 'internal',
  ai_validation_failed: 'internal',
  not_authenticated: 'unauthenticated',
  permission_denied: 'permission-denied',
  not_found: 'not-found',
  rate_limited: 'resource-exhausted',
  unknown_error: 'internal',
};

export function toHttpsError(error: unknown): HttpsError {
  if (error instanceof HttpsError) return error;
  if (error instanceof AppError) {
    return new HttpsError(HTTPS_ERROR_MAP[error.code], error.message, {
      code: error.code,
    });
  }
  const message = error instanceof Error ? error.message : 'Unknown error';
  return new HttpsError('internal', message, { code: 'unknown_error' });
}
