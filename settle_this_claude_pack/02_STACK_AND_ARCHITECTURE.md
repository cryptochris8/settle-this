# Stack and Architecture

## Recommended technical stack

### Client

- Flutter stable channel
- Dart
- Riverpod for state management
- go_router for navigation
- Firebase Core
- Firebase Auth
- Cloud Firestore
- Firebase Analytics
- Firebase Crashlytics
- Firebase Remote Config
- RevenueCat Flutter SDK
- share_plus for native sharing
- screenshot or custom painter package for verdict card image export

### Backend

- Firebase Cloud Functions, TypeScript
- Firebase Admin SDK
- OpenAI API
- Zod for runtime validation
- Optional: Cloud Tasks later for async processing if outputs become slower

### Data

- Firestore for app data
- No Storage in MVP unless image/audio evidence is added
- Store AI responses as structured JSON
- Avoid storing raw user input unless user saves the case

## Why Flutter + Firebase

This founder already uses Flutter/Firebase, and the app is consumer mobile-first. Flutter gives a fast path to iOS and Android. Firebase gives auth, database, analytics, crash reporting, remote config, and serverless functions without a custom backend.

## High-level architecture

```text
Flutter App
  |
  | HTTPS callable function
  v
Firebase Cloud Function: createVerdict
  |
  | Validate auth + quota
  v
Safety classifier / rule filter
  |
  | If safe
  v
OpenAI verdict generation
  |
  | structured JSON response
  v
Firestore save + return to app
```

## Core backend functions

### createVerdict

Purpose: create a new verdict from user input.

Input:

```json
{
  "scenario": "string",
  "sideA": "string optional",
  "sideB": "string optional",
  "relationshipType": "partner|roommate|friend|family|coworker|other",
  "tone": "balanced_referee|playful_roast|courtroom_judge",
  "saveCase": true
}
```

Output:

```json
{
  "caseId": "string",
  "status": "completed|blocked|needs_soft_redirect",
  "verdict": {
    "title": "string",
    "summaryVerdict": "string",
    "whoWasMoreRight": "side_a|side_b|both|neither|unclear",
    "confidence": "low|medium|high",
    "sideAGotRight": "string",
    "sideBGotRight": "string",
    "whatWasMissed": "string",
    "practicalFix": "string",
    "funnyFinalRuling": "string",
    "textToSend": "string",
    "safetyNote": "string optional"
  }
}
```

### getUserUsage

Purpose: return remaining free verdict count and subscription status.

### submitFeedback

Purpose: record whether verdict was helpful, funny, fair, or unsafe.

### deleteCase

Purpose: delete a saved case.

### generateShareCardData

Optional backend function if share-card copy should be separately generated.

## Client architecture pattern

Use feature-based folders:

```text
lib/
  app/
  core/
  features/
    auth/
    onboarding/
    submit_case/
    verdict/
    history/
    paywall/
    settings/
  shared/
```

## Security rules philosophy

- Users can read/write only their own cases.
- Client cannot create verdicts directly in Firestore without backend validation.
- All AI generation happens through Cloud Functions.
- Client cannot modify verdict fields after creation.
- Users can delete their own cases.
- Admin-only moderation fields are not client writable.

## Data retention

MVP recommendation:

- If user chooses “quick verdict only,” store minimal analytics and do not save raw scenario text.
- If user chooses “save case,” store sanitized scenario and verdict.
- Add delete-all-data setting.
- Avoid screenshots/audio in MVP.

## Environments

Use separate Firebase projects:

- `settle-this-dev`
- `settle-this-prod`

Use `.env` or Firebase function config for:

- OpenAI API key
- Model selection
- Daily free quota
- Prompt version
- Safety thresholds

## Suggested AI model setup

Use a cost-effective text model for MVP. Store model choice behind Remote Config or function config so it can be changed without app updates.

Backend should support:

- `AI_MODEL_VERDICT`
- `AI_MODEL_SAFETY`
- `PROMPT_VERSION`
- `MAX_INPUT_CHARS`
- `MAX_OUTPUT_TOKENS`

## Cost-control rules

- Limit scenario length.
- Limit free verdicts per day.
- Require auth after trial uses.
- Cache/reuse saved verdicts.
- Do not allow repeated regeneration loops without quota.
- Consider cheaper model for safety classification.

