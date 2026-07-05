# Judge Pip — Canonical Character Definition (v2)

_Created 2026-06-07. This is the **single source of truth** for Pip's appearance. Every Pip image is
generated **fresh** from the locked hero reference (`tools/pip-gen/canon/pip_hero.png`) conditioned on
the anchor string below — never by editing a previous output. This file supersedes the generation
guidance in `COMMISSION_BRIEF.md` (kept for posterity)._

Method: the **card-as-canon reference-conditioning** pipeline proven on Squishy Smash (see
`IMPROVEMENT_ROADMAP.md` §6). Reference image + anchor text restated twice + ALL-CAPS anti-features +
LLM vision judge gate + BiRefNet cutout + normalize.

---

## The reconciliation decision (why this canon)

Two incompatible Pips existed: the **flat-vector brand spec** (cream/navy/gold/coral, no outlines,
"Duolingo-meets-Headspace") and the **shipped brown painted owl** (warm brown plumage, soft outlines,
painted shading, wooden gavel). They were generated from contradictory prompts and never matched.

**Locked direction: the flat-vector brand system, warmed.** Rationale:
- It **is** the app's real palette — `theme.dart` already runs on cream `#FBF6EC` / navy `#1F2452` /
  gold `#E8B43C` / coral `#EF6F5E`. The mascot should match the UI it lives in.
- Flat solid shapes scale crisply to every size we render (56–120px in-app) **and** to the 1024px app
  icon, with no outline-mush at small sizes.
- It reads as a modern *app* mascot (the target), not a storybook illustration.
- **Carried over from the brown owl:** its genuine *warmth* — soft cheek blush, friendly rounded
  forms, an approachable (not stern, not creepy) expression. We keep the feeling, not the rendering.

If you'd rather canon the brown painted look instead, this is the one decision to flip before any art
is generated — everything downstream conditions on the chosen hero reference.

---

## Canon anchor (the load-bearing string — restated twice in every prompt, verbatim)

> **Judge Pip** — a plush, slightly stout owl judge. Dome-shaped head merging into an oval body,
> ~1:1 head-to-body ratio, short and round. Deep-navy judge's robe (trapezoid, hides the feet) with a
> cream Peter Pan collar. Large round symmetrical eyes: solid navy iris on cream sclera, one small
> cream highlight dot upper-left of each iris. Small golden triangular beak centered just below
> mid-face. Soft coral cheek blush (~30% opacity). Holds an oversized golden gavel (about the length
> of his body): gold head, deep-navy handle, wrapped in a wing (no visible hands).
> **FLAT VECTOR STYLE: solid color fills only, NO outlines, NO line art, NO gradients, NO shading, NO
> painterly texture, NO realistic feathers. NOT brown — navy robe on a cream owl. NOT a barn owl. NOT
> a wizard or graduate (it is a JUDGE'S robe, not a cloak or gown). NO baby-bird features, NO sad huge
> eyes, NO scary features. NO text, NO letters, NO props beyond the gavel.**

Structure (Squishy pattern): `[name] — [shape] + [color] + [signature features] + ALL-CAPS anti-features`.

---

## Locked palette (match exactly — no other colors, no gradients)

| Role | Hex |
|---|---|
| Warm cream — owl body, collar, sclera, "Listening" bg | `#FBF6EC` |
| Deep navy — robe, gavel handle, eye irises, "Triumph" bg ring | `#1F2452` |
| Golden gavel — gavel head, beak, accents, sparkles | `#E8B43C` |
| Coral — cheek blush (~30% opacity) | `#EF6F5E` |
| Ink black — eye/beak micro-shadow, sparingly | `#1B1B1B` |

## Locked geometry
- ~1:1 head-to-body; short, round; dome head into oval body.
- Eyes: large, round, symmetrical; navy iris, cream sclera, single cream upper-left highlight dot
  (decorative, not anime sparkle).
- Beak: small gold triangle, centered, slightly below mid-face.
- Robe: navy trapezoid hiding the feet; cream Peter Pan collar at the neck.
- Gavel: ~body length; gold head, navy handle; held in a wing, no visible hand.
- **No outlines. Solid color shapes only.** Transitions come from adjacent shapes, never strokes.
- Transparent background. Single centered character. No text.

---

## Pose library

**v2 core batch** (generate these first — they directly unblock roadmap items 1.1, 5, and the
verdict-reactive UI):

| Pose key | Description | Used in |
|---|---|---|
| `triumph` | Gavel mid-swing, one-eye wink, slight smirk, head tilted. Confident "winner declared." | Home host block, verdict hero (winner), share card, app-icon source |
| `gavel_down` | Gavel just struck a small block, both eyes open, decisive. The "gavel drops" reveal beat. | Verdict reveal animation (roadmap 1.1) |
| `listening` | Gavel set down beside Pip on a small block, wings folded, soft empathetic brows, head tilted. | Soft-redirect verdict, sensitive cases |
| `thinking` | Looking up, one wing to chin/beak, small gold thought-sparkles above. | Verdict loading screen |
| `shrug` | Wings raised palms-out, gentle "not enough to call it" expression. | `neither` / `unclear` outcomes, ambiguous verdicts |
| `oops` | Flustered, a couple of papers fluttering, sheepish look. ("The tiny judge dropped the paperwork.") | Error states |

**Later (optional):** `pointing_left` / `pointing_right` (lean toward Side A / Side B for
`whoWasMoreRight`), `scales_even` (both sides equally right), a thought-bubble variant of `thinking`.

---

## How the pipeline uses this file
1. Generate hero candidates for `triumph` → human-pick one → save as `tools/pip-gen/canon/pip_hero.png`
   (the immutable anchor; never edited).
2. For every other pose: a **fresh** generation passing `pip_hero.png` as the reference image + this
   anchor (twice) + the pose's description line + the ALL-CAPS anti-features.
3. LLM vision judge gate: "obviously the same character as the hero? ≥3/5 or reroll."
4. BiRefNet background cutout → tight-crop (4% pad) → square canvas → 256/512/768 px (1x/2x/3x) into
   `assets/pip/`, `assets/pip/2.0x/`, `assets/pip/3.0x/` (existing Flutter convention).
5. `judge_pip.dart` migrates from the `quiet` bool to a `PipPose` enum addressing these keys.

## Locked v2 assets (2026-06-07)
Generated via `tools/pip-gen/generate-pip-v2.py` (Nano Banana Pro =
`gemini-3-pro-image-preview`), cut out + resized via `finalize-pip-v2.py` (rembg
`isnet-general-use`). Confirmed picks:
- **canon hero** = `hero_1` → `canon/pip_hero.png` (no monocle; flat-vector spec)
- triumph = hero · gavel_down = `gavel_down_0` · listening = `listening_0` ·
  thinking = `thinking_1` · shrug = `shrug_0` · oops = `oops_0`

Shipped at 256/512/768 px into `assets/pip/`, `2.0x/`, `3.0x/`. `judge_pip.dart`
now uses `PipPose`; the loading screen uses `thinking`; the app icon is rebuilt
from the new hero. To add a pose later: add it to `POSES` here + in the generator,
run `pose <key>`, pick, `finalize`, add the enum case.
