import { z } from 'zod';

export const RelationshipTypeEnum = z.enum([
  'partner',
  'roommate',
  'friend',
  'family',
  'coworker',
  'other',
]);

export const ToneEnum = z.enum([
  'balanced_referee',
  'playful_roast',
  'courtroom_judge',
]);

export const CreateVerdictInputSchema = z.object({
  scenario: z.string().min(30).max(3000),
  sideA: z.string().max(1500).nullish(),
  sideB: z.string().max(1500).nullish(),
  relationshipType: RelationshipTypeEnum,
  tone: ToneEnum,
  saveCase: z.boolean().default(true),
});

export type CreateVerdictInput = z.infer<typeof CreateVerdictInputSchema>;

export const SafetyClassifierOutputSchema = z.object({
  riskLevel: z.enum(['low', 'medium', 'high']),
  action: z.enum(['allow', 'soft_redirect', 'block']),
  safeForHumor: z.boolean(),
  safeForShare: z.boolean(),
  categories: z.array(z.string()).default([]),
  reason: z.string().max(400).default(''),
  redactionSuggestions: z.array(z.string()).default([]),
});

export type SafetyClassification = z.infer<typeof SafetyClassifierOutputSchema>;

export const ShareCardSchema = z.object({
  headline: z.string().min(1).max(60),
  verdictOneLiner: z.string().min(1).max(120),
  shortRuling: z.string().min(1).max(160),
});

export const VerdictOutputSchema = z.object({
  title: z.string().min(1).max(80),
  summaryVerdict: z.string().min(1).max(500),
  whoWasMoreRight: z.enum(['side_a', 'side_b', 'both', 'neither', 'unclear']),
  confidence: z.enum(['low', 'medium', 'high']),
  sideAGotRight: z.string().max(500).default(''),
  sideBGotRight: z.string().max(500).default(''),
  whatWasMissed: z.string().max(500).default(''),
  practicalFix: z.string().max(600).default(''),
  funnyFinalRuling: z.string().max(300).default(''),
  textToSend: z.string().max(600).default(''),
  shareCard: ShareCardSchema.nullable(),
  safetyNote: z.string().max(400).nullable(),
});

export type Verdict = z.infer<typeof VerdictOutputSchema>;

export const VerdictResponseSchema = z.object({
  caseId: z.string(),
  status: z.enum(['completed', 'blocked', 'needs_soft_redirect']),
  verdict: VerdictOutputSchema.nullable(),
});

export type VerdictResponse = z.infer<typeof VerdictResponseSchema>;

export const FeedbackInputSchema = z.object({
  caseId: z.string().min(1).max(64),
  rating: z.enum(['thumbs_up', 'thumbs_down']),
  tags: z
    .array(
      z.enum([
        'funny',
        'fair',
        'helpful',
        'too_harsh',
        'not_helpful',
        'not_fair',
        'unsafe',
      ]),
    )
    .max(7)
    .default([]),
  freeText: z.string().max(1000).nullish(),
});

export type FeedbackInput = z.infer<typeof FeedbackInputSchema>;
