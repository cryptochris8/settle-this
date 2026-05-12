# Settle This

Funny, fair AI referee for everyday low-stakes disagreements. Flutter + Firebase.

## Layout

```
D:\Settle-This\
  settle_this_claude_pack\   spec & product brief (read first)
  settle_this\               Flutter app
  functions\                 Cloud Functions (TypeScript)
  firebase.json              Firebase project config
  firestore.rules            Hardened Firestore rules
  firestore.indexes.json     Composite indexes + TTL fields
  REVIEWER_NOTES.md          App Store / Play reviewer notes
```

## Getting started

### Prerequisites

- Flutter 3.41+ on the stable channel
- Node 20+ for the functions workspace
- Firebase CLI (`npm i -g firebase-tools`) + `flutterfire_cli` (`dart pub global activate flutterfire_cli`)
- A Firebase project (recommended: `settle-this-dev` and `settle-this-prod`)

### Manual setup the user must run once

These steps cannot be automated:

1. **Lock the brand name** before anything else (trademark, App Store, Google Play, domain).
2. **Create Firebase projects** `settle-this-dev` and `settle-this-prod` with: Auth (Anonymous + Email + Apple + Google), Firestore (production-mode), Functions, Analytics, Crashlytics, Remote Config, App Check.
3. **Enable Anonymous auth** in Firebase Console → Authentication → Sign-in method.
4. **Configure App Check** providers (DeviceCheck/App Attest on iOS, Play Integrity on Android, debug providers for local dev).
5. **`flutterfire configure`** from `settle_this/` against the dev project — generates `lib/firebase_options.dart` plus the platform configs.
6. **Set Cloud Functions secrets** in Google Cloud Secret Manager:
   - `OPENAI_API_KEY`
   - `REVENUECAT_WEBHOOK_SECRET`
7. **OpenAI account** — create the org, set a hard usage cap (security finding F2.2).
8. **GCP budget alert** — set a billing alert on the project (security finding F2.2).
9. **RevenueCat account** — create a project, configure offerings (`monthly_plus`, `annual_plus`, optional `lifetime_plus`) under the `default` offering, set the `settle_plus` entitlement, wire the iOS / Play product IDs.
10. **Apple Developer + Google Play** — create the app records, lock the bundle ID (`com.athletedomains.settle_this` by default), enable Sign In with Apple if Google Sign In is shipped.

### Deploy

```bash
# Functions
cd functions
npm install
npm run build
firebase deploy --only functions

# Firestore rules + indexes
firebase deploy --only firestore

# Flutter app
cd settle_this
flutter run --dart-define=REVENUECAT_API_KEY=...
```

### Testing locally

```bash
# Backend typecheck
cd functions
npm run typecheck

# Flutter
cd settle_this
flutter analyze
flutter test
```

## Architecture

- **Client** — Flutter, Riverpod 3, go_router 17. State lives in feature
  folders under `settle_this/lib/features/`.
- **Backend** — Firebase Functions v2 (Node 20, TypeScript). Every AI call is
  server-only; the client never sees the OpenAI key. The pipeline is
  `auth → quota (transactional) → PII detect/redact → safety classifier →
  verdict generator → JSON validate → Firestore write → return`.
- **Firestore rules** are hardened per the pre-Phase-0 security review:
  client cannot create cases (only Cloud Functions can), feedback writes are
  schema-validated, `users/{uid}` updates use an explicit allowlist.
- **Safety** — fail-closed semantics across the AI pipeline: any classifier
  error returns a soft-redirect template rather than letting the generator
  run.

## Phase status

- Phase 0 — project skeleton ✅
- Phase 1 — onboarding + age gate + disclaimer + auth ✅
- Phase 2 — submit dispute flow ✅
- Phase 3 — Cloud Functions backend ✅
- Phase 4 — verdict result + history ✅
- Phase 5 — share cards ✅
- Phase 6 — usage limits + RevenueCat scaffolding ✅
- Phase 7 — analytics, Crashlytics, settings/privacy/delete data ✅

The remaining items are operational (App Store / Google Play submission,
TestFlight, beta testing) and depend on the manual setup steps above.
