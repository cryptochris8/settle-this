# Settle This — Codebase Review Summary

_Generated 2026-07-05 via a full parallel read of every subsystem (9 subsystem maps + a security/privacy pass + a quality/readiness pass). File:line citations were valid at the time of writing — verify against current code before acting._

## 1. What it is

**Settle This** is a Flutter + Firebase mobile app: a "funny, fair AI referee" that issues structured verdicts on low-stakes everyday disputes (chores, leftovers, roommate/partner spats). Positioning is deliberately **entertainment-first** — "a fair friend with a gavel," explicitly _not_ therapy/legal/medical/crisis support, no public feed, no NSFW, 18+ launch. Mascot is **Judge Pip**, a flat-vector owl judge.

**Scale:** ~7,100 lines of Dart (client), ~1,500 lines of TypeScript (Cloud Functions), ~150 lines of tests, ~2,900 lines of spec docs. Version `1.0.0+1`, pre-store-submission.

The repo is unusually well-documented: the 13-file spec pack (`settle_this_claude_pack/`) captures the original product/architecture intent, and `IMPROVEMENT_ROADMAP.md` already catalogs many known gaps.

## 2. Architecture

```
Flutter client (Riverpod 3 + go_router 17)
    │  cloud_functions (callable)          Firestore (stream reads)
    ▼                                            ▲
Cloud Functions v2 (Node 20, TS) ── Admin SDK ──┘
    │
    ├─ OpenAI (gpt-4o-mini): moderation → safety classifier → verdict generator
    └─ RevenueCat webhook → subscription sync
```

**Core pipeline** (`functions/src/cases/createVerdict.ts`):
`auth → Zod-validate → normalize + PII detect/redact → transactional quota reserve → safety classify → (block | soft-redirect | generate verdict) → gate shareCard → persist case → moderation log → return`. The OpenAI key never touches the client. The safety chain is **fail-closed**: any classifier/parse/generation error degrades to a calm `SOFT_REDIRECT_TEMPLATE` rather than shipping an unfiltered joke.

**State/data:** feature-first folders (`features/<name>/{domain,application,data,presentation}`). Firestore holds `users/{uid}` (profile + subscription + counters), `users/{uid}/cases/{caseId}` (verdict record), `users/{uid}/usage/{yyyyMMdd}` (quota counters), plus top-level `feedback`, `moderationLogs`, `processedEvents`, `appConfig`.

## 3. Subsystem walkthrough

- **Client scaffolding** (`lib/app`, `lib/core`) — Bootstrap-then-inject: `main.dart` builds SharedPreferences + RemoteConfig and supplies them via `ProviderScope` overrides. App Check: debug providers in dev, Play Integrity / App Attest in release. `router.dart` is a single go_router redirect gate: **splash → onboarding → age-gate → disclaimer → sign-in → home**. Every Firebase service degrades gracefully (no-ops if `Firebase.apps` empty). Analytics/Crashlytics wrappers accept only scalar values + opaque IDs — free-text (scenarios/verdicts) can never leak into telemetry.
- **Auth / onboarding / settings** — Firebase auth is **anonymous-only in practice**; Apple/Google buttons are stubs. Age gate is client-side DOB self-attestation in local prefs. Disclaimer is versioned (bump = re-prompt everyone). Settings exposes GDPR delete-data + delete-account.
- **Submit → verdict (core loop)** — 4-step wizard (scenario+relationship → sides → tone → review) backed by one immutable Riverpod `DisputeCaseInput`. `verdict_repository` calls `createVerdict`; the loading screen navigates by `caseId` and **re-reads the case from Firestore** (command-via-function, query-via-stream). Rich result rendering (badge, tone-tinted section cards, "text to send," funny ruling) plus a fixed 1080×1350 off-screen share card captured to PNG. Tolerant wire enums with `fromWire` fallbacks throughout.
- **Home / paywall / history** — Server-authoritative quota (client chip is a reflection). RevenueCat wrapper handles configure/identify/purchase/restore around the `settle_plus` entitlement. History is a soft-delete model (`deletedAt == null`). `JudgePip` maps 6 poses to assets with a procedural stub fallback + memory-capped decode.
- **Cloud Functions AI** (`functions/src/ai`) — OpenAI only. Versioned prompts (`PROMPT_VERSION v1.2.0`), 4 system prompts (safety classifier / verdict generator / soft-redirect / repair). Prompt-injection defense is delimiter-based (`<USER_CONTENT>` wrapping + tag stripping). Zod-validated output with **one non-echoing repair pass**, then static safe fallback. A regex `guardOutput` scrubs self-harm/doxx/breakup/divorce terms.
- **Backend functions** (`functions/src`) — 5 App-Check-enforced callables (`createVerdict`, `getUserUsage`, `submitFeedback`, `deleteCase`, `deleteAccount`) + 1 public HTTP webhook. Quota is a **genuine Firestore transaction**. `deleteAccount` is a GDPR-compliant, idempotent, batched cascade. The RevenueCat webhook uses `crypto.timingSafeEqual` + a `processedEvents` replay ledger.
- **Firebase config** — Deny-by-default rules: clients can't create cases (Functions-only), `usage` backend-write-only, `users` updates allowlisted, `moderationLogs`/`processedEvents` fully locked. Composite index on `cases(deletedAt ASC, createdAt DESC)`; TTL on `moderationLogs.createdAt`. Dev/prod split via `.firebaserc` (dev is default). Secrets in Google Secret Manager.
- **Build / tooling** — Strict analyzer (~25 extra lints). Codemagic CI: iOS→TestFlight is real; **Android only builds a debug APK** (no release AAB/signing). `tools/pip-gen/` is a multi-model mascot generator (Recraft v1 → Nano Banana Pro / Fal v2, reference-conditioned "card-as-canon" method, rembg cutout, resolution-aware export).

## 4. Built vs. spec

The build **closely matches the spec** — every planned feature folder/screen exists, the Functions layout matches `13_BACKEND_FUNCTIONS_SPEC` (plus an added `deleteAccount`), and all 6 canonical Pip poses ship at 1x/2x/3x (the roadmap's note that only 2 poses exist is now **stale**). Phases 0–7 are marked ✅.

## 5. Security posture

**Strong:** App Check on every callable; transactional quota; Zod validation at every trust boundary; server-side PII redaction before the model and before persistence; Functions-only verdict writes; constant-time webhook secret compare + replay ledger; secrets in Secret Manager; telemetry hardened against free-text leaks.

**One HIGH-severity hole (verified against source):** **client-controlled subscription bypass.** `firestore.rules:26` allows `create: if isOwner(userId)` with _no field validation_ (the allowlist on lines 27–35 guards only `update`). `getUserUsage.ts:28-31` and `createVerdict.ts:51-53` both trust `subscription.status` straight from that client-writable doc to compute `isPaid`. A client can create `users/{uid}` with `{subscription:{status:'plus'}}` via the Firestore SDK and pull up to 100 real-OpenAI-cost verdicts/day, bypassing RevenueCat and the free cap. **Fix:** never let clients write `subscription`; source paid status only from a webhook-written, client-unwritable field (or reject `create` payloads that include `subscription`/`counters`).

**Medium/low:** over-broad direct-write `/feedback` rule (unredacted `freeText`, unverified `caseId` ownership) parallel to the callable; anonymous cap resettable by deleting the user doc; unvalidated `feedback`/`share`/`settings` client writes; webhook trusts `app_user_id`; `BILLING_ISSUE` → `expired` may prematurely revoke access during a grace period; `deleteAccount` retains `feedback.freeText` and returns `ok:true` even if `auth().deleteUser` fails.

## 6. Launch blockers (prioritized)

1. **🔴 Paywall bypass** — client can self-grant `plus` (see §5).
2. **🔴 Anonymous "2 verdicts for life" vs "3/day" UI** — `quota.ts:15,58` hard-caps anonymous users at 2 lifetime verdicts (an intentional launch value), but `getUserUsage.ts:38` reports `remaining = 3 - free` and never reads the anon cap. Because Apple/Google sign-in are stubs, **every real user is anonymous and dead-ends after 2 verdicts** with a misleading "courtroom reopens tomorrow" wall and a "Sign in to keep going" message pointing at non-existent auth. Fix requires _either_ shipping real auth (so the 3/day tier is reachable) _or_ reconciling the cap with the UI copy.
3. **🔴 "Save to history = off" → broken result screen** — the client discards the inline verdict and re-reads Firestore, but `createVerdict` only persists when `saveCase || status != completed`, so a completed+unsaved case is never written → "We couldn't find that case." Quota is already spent and the form already reset. Fix: use the inline verdict as fallback, persist transiently, or remove the toggle.
4. **🔴 Selected tone never reaches the model** — tone/relationship sit inside `<USER_CONTENT>` (which the prompt is told to ignore), so the 3 tone modes and "Try Another Tone" likely do nothing. Lift these app-controlled enums into instruction space (no injection risk — they're enums).
5. **🔴 Analytics + Crashlytics are dead code** — both services are fully built but _never invoked_, and `main.dart` never installs `FlutterError.onError`/`PlatformDispatcher.onError`. You'd launch with zero crash visibility and zero funnel data despite Phase 7 being "done."

**Medium:** Nunito font not bundled (share card — the viral surface — can render with the wrong font); RevenueCat→backend status lag can quota-block fresh subscribers; over-broad safety scrub nukes verdicts that merely _mention_ "break up"/"divorce"; account deletion leaves DOB/consent in local prefs; delete-all-cases loop has no try/finally (can hang the UI); thin tests (3 client files, **zero** backend/AI tests).

**Low/polish:** Android release still signs with the debug keystore + no release CI; web `index.html`/`manifest.json` are unbranded Flutter defaults; Android label `settle_this` vs iOS `Settle This`; light-theme only; no in-app privacy-policy link (common App Review rejection); Firebase wired to the **dev** project; ~3 sequential OpenAI calls with no `minInstances`/client timeout in front of the spinner; dead helpers (`phase_placeholder.dart`, `reservedReasons`/`flagsForBlockedShare`/`unused()`).

## 7. Bottom line

Architecturally this is a **mature, well-structured, security-conscious codebase** — clean layering, a real fail-closed safety pipeline, hardened rules, GDPR deletion, thoughtful defensive degradation. It reads like a spec-faithful, phase-complete build.

But it is **not store-ready**, and the gap is larger than "only store submission remains." Five code-level blockers break the core loop or the business model — most critically that **every anonymous user (the only working sign-in) hits a hard wall after 2 verdicts**, a **paywall that can be bypassed from the client**, and **no crash/analytics telemetry despite the plumbing existing**. None are architectural; they're concentrated, fixable defects. Realistically ~1 focused sprint on blockers 1–5 plus the medium items gets this to a credible TestFlight beta.
