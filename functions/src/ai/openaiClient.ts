import { defineSecret } from 'firebase-functions/params';
import OpenAI from 'openai';

/**
 * Security finding F2.1 — OpenAI key lives in Google Cloud Secret Manager.
 * v2 callables that need the key must declare it in their `secrets:` config.
 */
export const OPENAI_API_KEY = defineSecret('OPENAI_API_KEY');

let client: OpenAI | undefined;

export function openaiClient(): OpenAI {
  if (client) return client;
  const apiKey = process.env.OPENAI_API_KEY ?? OPENAI_API_KEY.value();
  if (!apiKey) {
    throw new Error('OPENAI_API_KEY is not set.');
  }
  client = new OpenAI({ apiKey });
  return client;
}

export const AI_MODEL_VERDICT = process.env.AI_MODEL_VERDICT ?? 'gpt-4o-mini';
export const AI_MODEL_SAFETY = process.env.AI_MODEL_SAFETY ?? 'gpt-4o-mini';
