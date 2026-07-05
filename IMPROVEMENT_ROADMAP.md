# Settle This — Improvement Roadmap

_Last updated: 2026-06-07. Source: parallel research pass across gameplay/engagement, visual/motion,
performance/code-health, AI-verdict quality, and a cross-project study of the Squishy Smash
character-consistency pipeline._

This roadmap consolidates concrete, code-grounded improvements. Effort is rated **S** (<half day),
**M** (1–3 days), **L** (a week+). Items lead with **highest impact-per-effort first**.

---

## 0. The single biggest theme

Three independent research streams converged on the same conclusion: **the verdict reveal — the
emotional payoff of the entire app — currently just "appears" with no climax.** The loading screen
animates Pip charmingly, then the actual ruling lands flat. Fixing the reveal moment is the highest
felt-quality win available, and most of the plumbing (reduce-motion guards in `verdict_hero.dart`)
already exists.

---

## 1. Sprint 1 — Quick wins (mostly client-side, huge felt impact)

These ship together as one "the app feels alive now" pass.

### 1.1 Gavel-drop verdict reveal — **S** — _flagged by gameplay + visual_
- Replace the bare `CircularProgressIndicator` at the top of `VerdictResultScreen.build` with a
  staggered fade-and-rise: badge → title → summary → section cards cascading over ~600–800ms.
- Fire `HapticFeedback.mediumImpact()` (the "gavel bang") the instant a completed verdict renders.
  Only one haptic exists in the whole app today (`verdict_card_widget.dart:211`).
- Animate `VerdictBadge` with a scale-up-and-settle (`Curves.elasticOut`) + brief color pulse — the
  actual answer currently has the *least* visual emphasis on screen.
- **Files:** `lib/features/verdict/presentation/verdict_result_screen.dart`,
  `verdict_hero.dart`, `lib/shared/widgets/verdict_badge.dart`.
- **Preserve:** the existing `MediaQuery.disableAnimationsOf` pattern (set controller to end-value
  when reduce-motion is on).

### 1.2 Surface `confidence` — **S** — _flagged by gameplay + AI_
- `verdict.confidence` (low/med/high) is parsed from the backend and **thrown away**. Show it as a
  chip / gavel-meter under the badge ("Pip's pretty sure" vs "limited evidence").
- Adds replay tension and a fairness signal for zero backend work.
- **Files:** `verdict_hero.dart`, `verdict_badge.dart`.

### 1.3 Seed / "Surprise me" example prompts — **S** — _gameplay_
- Add 4–6 tappable example chips on the submit screen that prefill the scenario, plus a "🎲 Surprise
  me" that drops a random prebuilt dispute. Examples live in
  `settle_this_claude_pack/11_SAMPLE_TEST_CASES.md`.
- Kills blank-textbox paralysis (backend requires 30+ chars) — the #1 first-run activation leak — and
  enables solo play when the user has no live argument.
- **Files:** `lib/features/submit_case/presentation/submit_case_screen.dart`, new const list under
  `submit_case/domain/`.

### 1.4 Both sides on the share card — **S–M** — _flagged by gameplay + visual_
- `share_card_widget.dart` shows only headline + one-liner. Add a compact "Side A vs Side B →
  Verdict" scoreboard strip (data already exists via `whoWasMoreRight.label`).
- The viral hook is "WE fought, here's who the robot judge sided with." A matchup card invites
  clap-backs and group-chat shares.
- **Files:** `share_card_widget.dart`, `lib/features/verdict/domain/verdict.dart` (thread side labels
  into `ShareCardData`).

### 1.5 Press + selection feedback on big surfaces — **S** — _visual_
- Add subtle scale-down-on-press (`AnimatedScale`) to `_HeroSettleButton` (`home_screen.dart:223`),
  `_ToneCard` (`tone_selector_screen.dart:75`), and `_HistoryTile`. Wrap `_ToneCard`'s selected state
  in `AnimatedContainer` + animate the check with `AnimatedSwitcher`.
- **Files:** `home_screen.dart`, `tone_selector_screen.dart`, `history_screen.dart`.

### 1.6 Soft usage-cap nudge instead of a mid-flow wall — **S** — _gameplay_
- Today the out-of-quota wall (`usage_limit_screen.dart`) appears *during* the exciting loading
  screen on `resource-exhausted`. Add an inline "1 verdict left today" confirm before spending the
  last one, and give the limit screen a non-paywall consolation action.
- **Files:** `verdict_loading_screen.dart`, `usage_limit_screen.dart`, `home_screen.dart` (`_UsageChip`).

---

## 2. Sprint 2 — Backend / AI verdict quality (the "magic")

The verdict generator has two foundational gaps. Fix these before iterating on tone/flavor.

### 2.1 Wire the selected tone into the prompt as an instruction — **S** — _AI, critical_
- **This likely breaks "Try Another Tone" today.** The system prompt defines three rich tone modes
  but never tells the model to read/apply the user's `tone` — it arrives buried inside
  `<USER_CONTENT>`, which the prompt explicitly says to treat as *data, not instructions*
  (`prompts.ts:80`). Lift `tone` (and `relationshipType`) into trusted instruction space (they're
  app-controlled enums, no injection risk).
- **Files:** `functions/src/ai/prompts.ts`, `functions/src/ai/verdictGenerator.ts`.

### 2.2 Name and anchor the "Pip" persona — **S** — _AI_
- The mascot is "Pip" everywhere in the app, but the word **appears nowhere in `functions/src/`**.
  The verdict voice has no name or personality anchor. Open the system prompt with Pip's identity
  (warm, fair, quick-witted, never cruel).
- **Files:** `functions/src/ai/prompts.ts` (also align `SOFT_REDIRECT_SYSTEM_PROMPT`).

### 2.3 Switch to OpenAI structured outputs (`json_schema`, strict) — **S–M** — _AI_
- Both calls use `response_format: { type: 'json_object' }` — guarantees valid JSON, not *your*
  schema. Switch to `json_schema` + `strict: true` derived from the Zod shapes in `schemas.ts`
  (e.g. via `zod-to-json-schema`). gpt-4o-mini supports it.
- Near-eliminates the malformed-output repair round-trip (`verdictGenerator.ts:54-79`) and the
  generic soft-redirect fallback firing on good cases → lower p95 latency + cost.
- **Files:** `functions/src/ai/verdictGenerator.ts`, `safetyClassifier.ts`, `schemas.ts`.

### 2.4 Stand up a verdict eval harness — **M** — _AI, enabling_
- There is **no test for the AI pipeline.** Every prompt change (`PROMPT_VERSION` v1.2.0) ships
  blind. Build ~20–30 curated disputes (one-sided, balanced, abusive, sensitive, absurd, ambiguous)
  + a runner that checks schema validity, `whoWasMoreRight` sanity, length bounds, and an optional
  LLM-judge rubric (funny/fair/safe 1–5). Wire to `PROMPT_VERSION`.
- **Files:** new `functions/eval/` or `functions/src/ai/__tests__/`.

### 2.5 Richer shareable schema fields — **M** — _AI + gameplay_
- Add high-payoff fields: a punchy `ruling` headline, `splitPercentage` ({sideA, sideB} — a number
  people screenshot, far more fun than the 5-way enum), an optional fun `decree`/penalty, and an
  optional `caseName` for courtroom tone. `funnyFinalRuling` already proves the render pattern.
- **Files:** `functions/src/ai/schemas.ts`, `prompts.ts`, `lib/features/verdict/domain/verdict.dart`,
  `verdict_card_widget.dart`, `verdict_result_screen.dart`.

### 2.6 De-fang the keyword post-check — **S–M** — _AI_
- `postCheckIsUnsafe` regex-matches `\bbreak up\b` / `\bdivorce\b` and then `guardOutput` **nukes the
  whole verdict** — so a fair verdict saying *"this isn't a break-up-level problem"* gets destroyed.
  Narrow to recommendation contexts, or downgrade to "drop share card only."
- **Files:** `functions/src/ai/safetyClassifier.ts`, `verdictGenerator.ts`.

### 2.7 Variety + one-sided-input handling — **S** — _AI_
- Bump verdict temperature ~0.6 → 0.8–0.9, add an anti-stock-opener line, and add explicit guidance:
  on one-sided input, lower `confidence` and lean on `whatWasMissed` rather than declaring a winner.
- **Files:** `verdictGenerator.ts`, `prompts.ts`.

### 2.8 Few-shot roast exemplars + prompt-cache hygiene — **S–M** — _AI_
- Add 1–2 full input→output exemplars for the `playful_roast` mic-drop at the stable prompt prefix
  (cacheable). Verify the long static system prompt is actually hitting OpenAI's prefix cache.
- **Files:** `prompts.ts`, `verdictGenerator.ts`.

---

## 3. Sprint 3 — Launch hardening (real store-launch blockers)

### 3.1 Wire up Crashlytics — **S** — _performance, important_
- **Crashlytics is dead code.** It ships in the bundle but `main.dart` never sets
  `FlutterError.onError` / `PlatformDispatcher.instance.onError`. **You have zero crash visibility in
  production.** Wire both, and call `recordError` in catch blocks (e.g. `verdict_loading_screen.dart:81`
  currently swallows the error to a string).
- **Files:** `lib/main.dart`, plus catch sites.

### 3.2 Verdict latency: minInstances + parallelize + client timeout — **M** — _performance_
- A normal verdict is **3 sequential OpenAI calls** (moderation → classifier → generator) plus
  serial Firestore writes, with **no `minInstances`** (2–5s cold starts) and **no OpenAI client
  timeout** (a hung socket rides the full 60s). All in front of the spinner.
  - Add `minInstances: 1` to `createVerdict` + `getUserUsage`.
  - `Promise.all` the independent post-gen writes (`persistCase`, `moderationLogs.add`, counter).
  - Consider collapsing moderation + bespoke classifier for low-risk inputs (saves one LLM hop).
  - `new OpenAI({ apiKey, timeout: 20_000, maxRetries: 1 })`.
- **Files:** `functions/src/cases/createVerdict.ts`, `getUserUsage.ts`, `ai/openaiClient.ts`,
  `safetyClassifier.ts`, `verdictGenerator.ts`.

### 3.3 Bundle the Nunito font — **S** — _performance + visual_
- `google_fonts` fetches Nunito at runtime; nothing is bundled. Risks the **share-card PNG rendering
  with the wrong font** (a viral surface — `share_card_widget.dart` hardcodes `fontFamily: 'Nunito'`)
  and a first-launch font flash. Bundle the weights (w700/w800/w900) in `pubspec.yaml` + set
  `GoogleFonts.config.allowRuntimeFetching = false`.
- **Files:** `pubspec.yaml`, `theme.dart`.

### 3.4 Tame the history stream — **M** — _performance_
- `historyStreamProvider` is a live `.snapshots()` listener watched by both Home (just to show 2
  recent) and History, kept alive for the whole session, with **no `.limit()`** (streams every case).
  Use a one-shot `.get()` future for the Home preview; cap `watchHistory()` with `.limit(N)`.
- **Files:** `lib/features/history/data/history_repository.dart`, `home_screen.dart`.

### 3.5 Smaller code-health fixes — **S each** — _performance_
- `RemoteConfigService` default factory returns a second uninitialized instance — make it
  `throw UnimplementedError` so a missing override fails loudly (`remote_config_service.dart:53`).
- `userUsageProvider` re-fetches on every auth emission — depend on
  `authStateProvider.select((a) => a.value?.uid)`.
- Add `cacheWidth` to `JudgePip._buildAsset` `Image.asset` (decodes full 580KB bitmap for a 120px
  render); replace `IntrinsicHeight` in `VerdictSection` with a border decoration.
- Centralize the copy-pasted `_resolveFunctions/_resolveFirestore` Firebase-client boilerplate (~7
  files) + the hardcoded `'us-central1'` region (3 places) into one `firebase_clients.dart`.

---

## 4. Differentiated bets (uniquely on-brand for an AI *judge*)

### 4.1 "Appeal the Verdict" — **M** — _the flagship retention/virality mechanic_
- Add an **Appeal** button: the user/partner submits a one-line rebuttal, Pip issues a revised ruling
  ("On appeal, the court revises..."), chained to the original case. No competitor has this. Doubles
  session length, gives the losing side agency, natural two-player loop, premium-worthy (free = 1
  appeal, Plus = unlimited).
- **Files:** verdict prompts, `verdict_repository.dart`/`createVerdict`, `verdict_result_screen.dart`,
  `dispute_case.dart` (appeal thread field).

### 4.2 "Pass the Phone" two-player mode — **M** — _gameplay_
- Toggle on submit → Side A types, blind handoff interstitial ("Pass to [them]"), Side B types blind,
  then the verdict. Perfect fit for the "Petty Couple" persona; the data model already supports
  optional sides.
- **Files:** `side_input_screen.dart`, `submit_case_form.dart`, `submit_case_screen.dart`.

### 4.3 Streaks + daily prompt ("Today's Tiny Trial") — **M** — _gameplay_
- A rotating daily prompt on Home (ship via `remote_config_service.dart` so it updates without
  releases) + a settle-streak counter via `preferences_service.dart`. Currently there is **zero**
  reason to open the app without a live argument.
- **Files:** `home_screen.dart`, `preferences_service.dart`, `remote_config_service.dart`.

### 4.4 Free same-case re-tone — **S–M** — _gameplay_
- `_tryAnotherTone` currently re-runs the full wizard AND silently burns a daily verdict. Make
  re-rolling the *same* case in a new tone free/cheapest and skip the wizard. Trying all 3 tones on
  one juicy argument is the funnest, most shareable loop and the best converter.
- **Files:** `verdict_result_screen.dart`, `verdict_repository.dart`, `createVerdict`.

### 4.5 Verdict reactions + share-to-vote tie-breaker — **M** — _gameplay_
- Playful emoji reactions (😤 I object / 😂 fair / 👑 vindicated), distinct from the existing QA
  feedback chips. Plus "send to a friend to break the tie" → viral acquisition loop.
- **Files:** `verdict_result_screen.dart` (`_FeedbackBlock`), `share_service.dart`.

---

## 5. Polish backlog (lower priority)

- **Dark mode** — the app is light-only (`theme.dart` `Brightness.light`); L effort, ripples through
  every hardcoded `Colors.white`/`SettleThisColors.*`. Prereq: route colors through
  `Theme.of(context).colorScheme`.
- Wizard page transitions + animated `WizardSteps` progress fill — **M**.
- Themed `SnackBarThemeData` (all snackbars are stock Material) — **S**.
- Unify the two inconsistent "no verdicts" empty states; show Pip in both — **S**.
- Differentiate "what you got right" vs "what they got right" (currently visually identical) — **M**.
- Share-card preview frame + scale-in; loading-screen stock spinner → bespoke "scales tipping" — **S–M**.
- History "Hall of Fame": pin/favorite, filter by who-won, re-share old verdicts — **M–L**.
- Judge persona packs as additive IAP (Grandma Judge, Tiny Tyrant, Bard) — **L**.

---

## 6. Pip mascot redo — apply the Squishy Smash consistency pipeline

### 6.1 Why redo Pip
The current Pip pipeline (`tools/pip-gen/`) is **pure text-to-image via Recraft with zero reference
conditioning.** Its only consistency lever is the literal phrase *"Same character as Pip Triumphant"*
— which text-to-image cannot honor. Worse, the two existing poses were generated from **contradictory
style prompts** (Triumph = "flat vector, no outlines, no shading"; Listening = "children's-book,
soft outlines, painted shading, brown plumage"), so they don't read as one character. Only 2 poses
exist; "Pip Thinking" was never made. This blocks roadmap items 1.1, 5 (Pip in empty states), and the
verdict-reactive poses that would map to the 5 `WhoWasMoreRight` outcomes.

### 6.2 The proven recipe (extracted from Squishy Smash, `D:\squishy-smash`)
What won there, after LoRA / Kontext / ControlNet all failed:
1. **One canonical reference = single source of truth.** Every asset derives from it, never from a
   derivative.
2. **Every pose is a FRESH generation conditioned on the canon reference** — never an iterative edit
   (iterative editing is what causes drift, degrading after ~6 edits).
3. **Reference-image conditioning via Nano Banana Pro** (`gemini-3-pro-image-preview`), passing the
   canon image(s) as `contents=[prompt, *ref_imgs]`. (~$0.13/image; 18 book spreads in a day for ~$12.)
4. **A "canon anchor" text string**, restated **twice** per prompt, structured:
   `[name] — [shape] + [color] + [signature features] + [ALL-CAPS anti-features]`.
   ALL-CAPS negatives are load-bearing (positive description alone lets the model add wrong features).
5. **LLM vision judge gate** ("obviously the same character? ≥3/5 or reroll").
6. **BiRefNet background cutout → normalize to a fixed centered canvas.**
   No seeds, no LoRA, no actual 3D models.

### 6.3 Decisions locked (2026-06-07)
- **Canonical look:** reconcile into a **fresh canon** — generate one new "hero" Pip as the deliberate
  anchor (strongest of the brown-painted shipped look vs. the flat-vector brand spec), then lock it.
- **Engine:** **Nano Banana Pro** (`gemini-3-pro-image-preview`), the engine that won for Squishy's
  book/marketing art. Uses the Google GenAI key Squishy already uses (read from `C:\Users\chris\`).

### 6.4 Build plan for `tools/pip-gen/` v2
1. **Author the canonical Pip anchor + brief.** Reconcile `COMMISSION_BRIEF.md` into a single
   `PIP_CANON.md` with the locked anchor string, palette hexes, proportions, and ALL-CAPS
   anti-features. Resolve the brown-vs-flat-vector conflict explicitly.
2. **Generate & lock the hero reference.** Produce candidate hero Pips, human-pick one, save as
   `tools/pip-gen/canon/pip_hero.png` (the immutable anchor).
3. **Build the reference-conditioned pose generator** (Python, Google GenAI SDK) that, for each pose,
   does a fresh generation passing `pip_hero.png` + the canon anchor (restated twice) + the pose-
   specific scene line + ALL-CAPS anti-features. Mirror Squishy's
   `book2_pipeline_2026_05_29/04_production_batch_21x9.py` structure.
4. **Pose set mapped to app needs:** triumph (winner), listening (calm/soft-redirect), thinking
   (loading), and ideally outcome-reactive poses for the 5 `WhoWasMoreRight` values + a
   "dropped-the-paperwork" error pose. (Confirm final list before generating.)
5. **LLM vision judge gate** on candidates (port Squishy's `sprite_judge_workflow.js` idea).
6. **Cutout + normalize** via BiRefNet → tight-crop → 256/512/768 (1x/2x/3x) matching the existing
   `process-pip.py` output convention + Flutter resolution subdirs.
7. **Refactor `judge_pip.dart`** from the `quiet` bool to a `PipPose` enum so the app can address the
   new poses; update render sites; regenerate the app icon from the new canon head.

### 6.5 Open items before generating art
- Confirm the Google GenAI key path/availability (Squishy reads it from `C:\Users\chris\`, not from a
  repo `.env`).
- Confirm the final pose list (§6.4 step 4).
- Budget: ~$0.13/image × (candidates × poses) — trivial, but worth noting cost is API-metered.

---

## Appendix — research provenance
- **Gameplay/engagement, visual/motion, performance, AI-quality:** four parallel research agents over
  `D:\Settle-This` (2026-06-07).
- **Consistency pipeline:** three parallel agents over `D:\squishy-smash` — book art recipe
  (`book/book2_pipeline_2026_05_29/`, `book/research_2026_05_25/`), sprite/tooling pipeline
  (`_sprite_restyle_proto/`, `tools/`), and the current Pip state (`tools/pip-gen/`,
  `assets/pip/COMMISSION_BRIEF.md`).
