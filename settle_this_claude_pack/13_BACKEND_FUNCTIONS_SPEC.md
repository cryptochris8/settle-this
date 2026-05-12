# Backend Functions Spec

## Runtime

Firebase Functions v2, TypeScript.

Recommended folder:

```text
functions/
  src/
    index.ts
    ai/
      openaiClient.ts
      prompts.ts
      safetyClassifier.ts
      verdictGenerator.ts
      jsonValidation.ts
    cases/
      createVerdict.ts
      deleteCase.ts
      getUserUsage.ts
      submitFeedback.ts
    billing/
      revenueCatWebhook.ts
    utils/
      auth.ts
      quota.ts
      errors.ts
      pii.ts
```

## createVerdict callable

### Responsibilities

1. Require auth.
2. Validate input.
3. Check subscription/free quota.
4. Sanitize and flag possible PII.
5. Run safety classifier.
6. If blocked, return blocked response and log moderation action.
7. If soft redirect, generate serious response or return template.
8. If allowed, generate verdict.
9. Validate output JSON.
10. Save case if requested.
11. Update usage counter.
12. Return case ID and verdict payload.

### Input schema

```ts
const CreateVerdictInputSchema = z.object({
  scenario: z.string().min(30).max(3000),
  sideA: z.string().max(1500).optional().nullable(),
  sideB: z.string().max(1500).optional().nullable(),
  relationshipType: z.enum(['partner', 'roommate', 'friend', 'family', 'coworker', 'other']),
  tone: z.enum(['balanced_referee', 'playful_roast', 'courtroom_judge']),
  saveCase: z.boolean().default(true),
});
```

### Output schema

```ts
const VerdictOutputSchema = z.object({
  title: z.string().min(1).max(80),
  summaryVerdict: z.string().min(1).max(500),
  whoWasMoreRight: z.enum(['side_a', 'side_b', 'both', 'neither', 'unclear']),
  confidence: z.enum(['low', 'medium', 'high']),
  sideAGotRight: z.string().max(500),
  sideBGotRight: z.string().max(500),
  whatWasMissed: z.string().max(500),
  practicalFix: z.string().max(600),
  funnyFinalRuling: z.string().max(300),
  textToSend: z.string().max(600),
  shareCard: z.object({
    headline: z.string().max(60),
    verdictOneLiner: z.string().max(120),
    shortRuling: z.string().max(160),
  }).nullable(),
  safetyNote: z.string().nullable(),
});
```

## Quota logic

```ts
if (subscriptionActive) {
  allow unless abusive rate limit exceeded;
} else {
  if (freeVerdictsUsedToday >= config.freeVerdictsPerDay) {
    throw new HttpsError('resource-exhausted', 'Daily free verdict limit reached');
  }
}
```

## PII detection MVP

Implement simple regex flags:

- Email addresses
- Phone numbers
- Street addresses
- URLs
- Social handles

Do not overcomplicate first build. Store `containsPotentialPII` and prevent share card if needed.

## revenueCatWebhook

Later function to sync subscription status.

Responsibilities:

- Validate webhook secret.
- Parse RevenueCat event.
- Update `users/{uid}.subscription`.

## Error handling

Return user-friendly error codes:

```text
invalid_input
quota_exceeded
safety_blocked
ai_generation_failed
ai_validation_failed
not_authenticated
unknown_error
```

Client maps these to friendly messages.

## Logging

Log:

- Function start/end
- Error type
- Safety action
- Prompt version
- Model used

Do not log full raw scenario text in production logs.

