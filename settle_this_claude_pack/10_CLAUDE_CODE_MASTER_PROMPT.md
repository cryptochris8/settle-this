# Claude Code Master Prompt

Copy/paste this into Claude Code after placing this folder in the project directory.

---

You are acting as the lead Flutter/Firebase engineer for a new mobile app called **Settle This**.

Read all markdown files in the `settle_this_claude_pack` folder before coding.

## Product summary

Settle This is a private, App Store-friendly AI referee for everyday low-stakes disputes. Users submit a scenario, choose a tone, and receive a funny, fair, practical verdict. The MVP must be PG by default, private-first, and safe. No public feed. No NSFW mode. No therapy/legal/medical positioning.

## Technical stack to use

- Flutter
- Dart
- Riverpod
- go_router
- Firebase Auth
- Cloud Firestore
- Cloud Functions for Firebase, TypeScript
- Firebase Analytics
- Firebase Crashlytics
- Firebase Remote Config
- RevenueCat subscription scaffolding
- OpenAI API from Cloud Functions only

## Core MVP requirements

Build a Flutter app with:

1. Onboarding
2. 18+ age gate
3. Disclaimer acceptance
4. Auth gate, anonymous auth acceptable for MVP
5. Home screen
6. Submit dispute flow
7. Relationship type selector
8. Tone selector with:
   - Balanced Referee
   - Playful Roast
   - Courtroom Judge
9. Cloud Function `createVerdict`
10. AI safety classification before verdict generation
11. Structured verdict JSON validation
12. Verdict result screen
13. History screen
14. Share card generation
15. Feedback buttons
16. Usage limit scaffolding
17. RevenueCat scaffolding
18. Settings/privacy/delete data screens

## Critical safety rules

- Do not build public feed in MVP.
- Do not build anonymous social posting.
- Do not build NSFW mode.
- Do not provide therapy/legal/medical advice.
- Serious content must get soft redirect or block.
- Humor must be PG and not cruel.
- Do not expose OpenAI API key in Flutter.
- Do not allow client to directly create AI verdict documents.
- Avoid storing raw sensitive inputs unless user saves the case.

## Build phases

Follow `09_DEVELOPMENT_PHASES_AND_TASKS.md`.

Start with Phase 0 and Phase 1. Do not skip architecture. Create clean, production-ready folders and placeholder screens first, then wire backend.

## First implementation task

1. Inspect the existing project if one exists.
2. If no Flutter project exists, create one.
3. Add the recommended folder structure.
4. Add dependencies.
5. Build the app shell with routing, theme, onboarding, age gate, disclaimer, auth gate, and home screen.
6. Keep code clean and documented.
7. After completing each phase, summarize files changed and next steps.

## Output expectations

When coding:

- Make small coherent commits/steps.
- Do not create giant unreviewable files.
- Prefer reusable widgets.
- Use strongly typed models.
- Validate input.
- Add TODO comments only where necessary.
- Keep copy aligned with the markdown pack.

## Design style

Warm, playful, modern. Think:

- Tiny courtroom energy
- Rounded cards
- Friendly mobile UX
- Strong verdict headers
- Clean readable copy
- Not legal-serious
- Not therapy-heavy
- Not edgy/NSFW

## Begin now

Read the markdown files and begin Phase 0.

---

