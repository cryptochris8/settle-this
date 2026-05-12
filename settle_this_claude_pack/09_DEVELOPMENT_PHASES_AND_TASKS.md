# Development Phases and Tasks

## Phase 0 — Project setup

Goal: Create a clean Flutter + Firebase foundation.

Tasks:

- Create Flutter project `settle_this`.
- Add Firebase project for dev.
- Configure iOS bundle ID.
- Configure Android package.
- Add Firebase Core/Auth/Firestore/Analytics/Crashlytics/Remote Config.
- Add Riverpod and go_router.
- Create base theme.
- Create folder structure.
- Add linting.
- Add environment config pattern.

Deliverable:

- App launches to placeholder home screen.
- Firebase initializes without error.

## Phase 1 — Onboarding, auth, and app shell

Goal: Build safe App Store-friendly entry flow.

Tasks:

- Build onboarding screens.
- Build 18+ age gate.
- Build disclaimer acceptance.
- Add anonymous auth or sign-in flow.
- Add Apple Sign In and/or Google Sign In if time allows.
- Add auth gate route.
- Add home screen layout.
- Store user profile in Firestore.

Deliverable:

- New user can onboard, accept disclaimers, and reach home screen.

## Phase 2 — Submit dispute flow

Goal: Let user create a structured dispute request.

Tasks:

- Build submit screen.
- Add relationship type selector.
- Add optional side A/side B fields.
- Add tone selector.
- Add review screen.
- Add client validation.
- Add warning against PII.
- Add loading screen.

Deliverable:

- User can enter a dispute and trigger a placeholder verdict flow.

## Phase 3 — Firebase Functions AI backend

Goal: Securely generate real verdicts.

Tasks:

- Initialize Firebase Functions with TypeScript.
- Add OpenAI API config.
- Create `createVerdict` callable function.
- Add input validation with Zod.
- Add user quota lookup.
- Add safety classifier call.
- Add verdict generation call.
- Add output JSON validation.
- Save case to Firestore.
- Return structured verdict to Flutter.
- Add error handling.

Deliverable:

- App receives real AI verdicts from secure backend.

## Phase 4 — Verdict result and history

Goal: Make the core loop delightful.

Tasks:

- Build verdict result screen.
- Render all structured verdict fields.
- Add verdict badge component.
- Add copy text button.
- Add feedback buttons.
- Add history screen.
- Add case detail screen.
- Add delete case.

Deliverable:

- User can submit, view, save, revisit, and delete verdicts.

## Phase 5 — Share cards

Goal: Build viral loop.

Tasks:

- Design share card widget.
- Generate image from widget.
- Add native share sheet.
- Add watermark/footer.
- Add share analytics event.
- Prevent sharing unsafe/soft-redirect cases.

Deliverable:

- User can share a clean verdict card to text/social.

## Phase 6 — Usage limits and paywall scaffolding

Goal: Prepare monetization.

Tasks:

- Add usage tracking collection.
- Enforce daily free limit in backend.
- Build usage limit screen.
- Add RevenueCat SDK.
- Create subscription repository.
- Build paywall screen.
- Add entitlement checks.
- Add restore purchases.

Deliverable:

- Free tier and Plus tier behavior are functional.

## Phase 7 — Polish and App Store readiness

Goal: Prepare TestFlight build.

Tasks:

- Add Crashlytics logs.
- Add analytics events.
- Add privacy policy screen.
- Add terms screen.
- Add delete account/data flow.
- Add app icon placeholder.
- Add splash screen.
- Add app review notes.
- Add screenshots copy.
- Test safety redirects.
- Test with 30+ sample disputes.

Deliverable:

- TestFlight-ready MVP.

## MVP Definition of Done

- User can onboard safely.
- User can submit a low-stakes dispute.
- Backend blocks or redirects unsafe topics.
- User receives structured verdict.
- User can share verdict card.
- User can save/delete verdicts.
- Free usage limits work.
- AI key is not exposed in client.
- App includes disclaimers and delete data controls.
- No public feed exists.

## Post-MVP roadmap

### V1.1

- Try Another Tone
- Better share-card templates
- Judge/persona pack structure
- More analytics dashboards

### V1.2

- Voice input transcription
- Screenshot/text-message analyzer with redaction
- More relationship contexts

### V1.3

- Couple/roommate invite link
- Shared private case room
- Second opinion unlock via invite

### V2

- Creator packs
- Public gallery only if moderation resources exist
- Localization
- Video verdict generation

