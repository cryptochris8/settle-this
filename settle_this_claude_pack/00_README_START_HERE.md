# Settle This — Claude Code Implementation Pack

## Product concept

**Settle This** is a lightweight, funny, App Store-friendly AI referee for everyday disagreements between couples, roommates, friends, family, and coworkers.

The app should feel like:

> A fair friend with a gavel, a sense of humor, and enough emotional intelligence to not make things worse.

The product should **not** feel like therapy, legal advice, public shaming, or a Reddit clone. The MVP should be private-first, PG/PG-13, and focused on fast verdicts that are funny, useful, and shareable.

## Deep research conclusions this plan is based on

The market research found:

1. There is not yet a dominant polished app in the “AI dispute referee” niche.
2. Several direct competitors exist, but many are new, lightly reviewed, and narrow.
3. The strongest indirect competitors are ChatGPT, Reddit AITA, Paired, Ember, and other relationship/advice apps.
4. The behavior is validated: people already ask AI for advice, consume interpersonal conflict content, and share AITA-style disputes.
5. The biggest risks are App Store compliance, privacy, moderation, harmful advice, and looking like therapy or public shaming.
6. The best wedge is: **private, funny, fair, structured verdicts for everyday low-stakes disputes.**

## Recommended MVP

Build a Flutter + Firebase mobile app with:

- Email/Apple/Google auth, plus optional anonymous trial mode.
- One simple “Submit a Dispute” flow.
- Relationship/person involved selector.
- Tone selector:
  - Balanced Referee
  - Playful Roast
  - Courtroom Judge
- Safety classifier before AI response.
- AI verdict output with structured fields.
- Save verdict history.
- Shareable verdict card.
- Feedback buttons.
- Usage limits/free tier.
- RevenueCat-ready subscription structure.
- No public feed in MVP.

## Recommended stack

Use the stack the founder already knows and can ship quickly:

### Mobile app

- **Flutter**
- **Dart**
- **Riverpod** for state management
- **go_router** for navigation
- **Firebase Auth**
- **Cloud Firestore**
- **Firebase Storage** only later, not MVP unless screenshots/audio are added
- **Cloud Functions for Firebase** for secure AI calls
- **Firebase Analytics**
- **Firebase Crashlytics**
- **RevenueCat** for subscriptions/IAP

### AI/backend

- **OpenAI API** called only from Cloud Functions
- Never expose API keys inside Flutter
- Cloud Function pipeline:
  1. Validate auth/user quota
  2. Run safety classifier
  3. If safe, generate verdict
  4. Store sanitized result
  5. Return structured JSON to app

### Design direction

- Warm, modern, playful courtroom aesthetic
- Not dark/edgy/NSFW
- App Store-safe humor
- Rounded cards, bold verdict labels, soft shadows
- Bright but trustworthy palette
- Avoid anything that resembles official court/legal services

## Folder contents

Read in this order:

1. `00_README_START_HERE.md`
2. `01_PRODUCT_BRIEF.md`
3. `02_STACK_AND_ARCHITECTURE.md`
4. `03_FIREBASE_SCHEMA.md`
5. `04_AI_SYSTEM_PROMPTS_AND_OUTPUT_JSON.md`
6. `05_SAFETY_MODERATION_AND_APP_STORE.md`
7. `06_FLUTTER_APP_STRUCTURE.md`
8. `07_UI_UX_SCREENS.md`
9. `08_MONETIZATION_AND_ANALYTICS.md`
10. `09_DEVELOPMENT_PHASES_AND_TASKS.md`
11. `10_CLAUDE_CODE_MASTER_PROMPT.md`
12. `11_SAMPLE_TEST_CASES.md`
13. `12_BRANDING_AND_ASO.md`

## Build instruction for Claude Code

Start by reading `10_CLAUDE_CODE_MASTER_PROMPT.md`. Then build the project in phases from `09_DEVELOPMENT_PHASES_AND_TASKS.md`.

Do not build public community features in the MVP.
Do not build NSFW mode.
Do not store raw sensitive input longer than necessary unless the user explicitly saves the case.
Do not call OpenAI directly from the client.

