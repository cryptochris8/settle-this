# Judge Pip — Commission Brief

**Status (2026-05-16):** Pip art has shipped from a Recraft generation pass —
`pip_triumph.png` and `pip_listening.png` are live in `assets/pip/` (plus
`2.0x/` and `3.0x/` for resolution-aware variants) and the `kArtReady` flag
in `lib/shared/widgets/judge_pip.dart` is on. The shipped Pip is brown plumage
with soft outlines and a wooden-handle gavel — a deliberate divergence from
the flat-vector / locked-palette spec below. Keep this brief intact for
posterity (and as a starting point if we later commission a strict-spec
version).

---

This brief is what you hand to a Fiverr illustrator, paste into Midjourney /
DALL-E / Procreate, or pass to your own designer. The end product is a small
suite of files that drop into `settle_this/assets/pip/` and instantly become
the brand identity of the Settle This app.

---

## Character bible

**Judge Pip** is the "tiny judge" referenced throughout Settle This's copy. Pip
is a **plush, slightly stout owl** in a deep-navy judge's robe with a cream
collar, holding a golden gavel that is clearly too big for them.

Pip is:

- Wise without being stern.
- Warm, never cute-baby. (Adult app — owl should read approachable to adults,
  not "preschool mascot.")
- Slightly absurd — the gavel is oversized, the robe drapes a little funny.
- Always rooted in the warm-cream / deep-navy / golden-gavel / coral palette.

Pip is **not**:

- A barn owl with photoreal feathers — flat vector style.
- A "courtroom is serious business" judge. Pip is the *playful referee*.
- A character with a baby-bird beak / huge sad eyes — that's the wrong
  emotional register for an entertainment app aimed at adults.

**Style reference:** "Duolingo's owl meets early Headspace illustration — flat
vector, soft rounded shapes, no outlines, friendly geometry."

---

## Required deliverables

### 1. Pip Triumphant (required)

- **What:** Gavel mid-swing, one eye in a wink, beak in a tiny smirk, head
  tilted slightly to one side.
- **Used in:** Verdict screen hero, home screen "your tiny judge is in" host
  block, share card header, eventually the iOS/Android app icon.
- **File names:**
  - `pip_triumph.png` — 256×256 px @ 1x
  - `pip_triumph@2x.png` — 512×512 px (for high-DPI mobile)
  - `pip_triumph@3x.png` — 768×768 px (for newest iPhones)
  - `pip_triumph.svg` — vector original, optional but nice for app icon export

### 2. Pip Listening (required)

- **What:** Same character, but gavel **set down** on a tiny block beside Pip.
  Wings folded over the body, soft concerned eyebrows, head tilted with the
  "I'm hearing you" posture. Less gold, more empathy.
- **Used in:** Soft-redirect verdict screen, error states, the "this one
  deserves a serious response" empty state. The calmer twin.
- **File names:**
  - `pip_listening.png` — 256×256 px @ 1x
  - `pip_listening@2x.png` — 512×512 px
  - `pip_listening@3x.png` — 768×768 px
  - `pip_listening.svg` — optional vector source

### 3. App icon (nice-to-have, after Triumphant lands)

- **What:** Pip's face only — bust-up portrait, centered in a circular cream
  ring on a navy background with a thin gold inner border. Should read clearly
  at 16×16 px (favicon) and 1024×1024 px (App Store listing).
- **File name:** `pip_app_icon_1024.png`

### 4. Pip Thinking (optional, ships later for the loading screen)

- **What:** Same Pip Triumphant pose but with a small thought bubble above
  containing tiny stars / sparkles / a question mark — used in the
  rotating-quips loading screen while the AI generates a verdict.
- **File name:** `pip_thinking.png` + retina variants

---

## Visual style spec

### Color palette (locked — match exactly)

| Role | Hex | Usage |
|---|---|---|
| Warm cream | `#FBF6EC` | Robe collar, "Pip Listening" background fill |
| Deep navy | `#1F2452` | Robe body, "Pip Triumphant" background ring, eye irises |
| Golden gavel | `#E8B43C` | Gavel head, accent borders, sparkles |
| Coral | `#EF6F5E` | Cheeks blush (subtle — about 30% opacity), "Listening" warmth |
| Ink black | `#1B1B1B` | Beak shadow, eye highlights — sparingly |

No other colors. No gradients (the brand uses solid-fill flat vectors).

### Geometry

- **Body proportions:** ~1:1 head-to-body. Pip is short and round. Owl
  silhouette: dome-shaped head merging into oval body.
- **Eyes:** Large, round, symmetrical. Iris is solid navy `#1F2452`. Sclera
  is cream `#FBF6EC`. A single white-cream highlight dot in the upper-left
  of each iris (decorative, not "anime sparkle").
- **Beak:** Small triangle, golden gavel color. Centered between eyes,
  slightly lower than mid-face.
- **Robe:** Trapezoid-ish shape, deep navy fill, hides the feet. Cream
  collar curves around the neck like a Peter Pan collar.
- **Gavel:** Roughly the length of Pip's full body. Golden head, navy-deep
  handle. Held in a wing (no visible "hand") with the wing wrapped around
  the handle.
- **No outlines.** Solid color shapes only. Color transitions come from
  adjacent shapes, not strokes.

### Typography rule

No text on Pip's assets — labels are added in the Flutter app via Google Fonts
Nunito. Keep the illustrations text-free for translation flexibility.

---

## Midjourney / AI prompt template

If you want to generate this yourself rather than commission:

```
A plush stout owl character wearing a deep navy judge's robe with a cream
Peter Pan collar, holding an oversized golden gavel, flat vector
illustration, no outlines, solid color fill, soft rounded geometry,
friendly adult illustration style. Color palette: warm cream #FBF6EC, deep
navy #1F2452, golden yellow #E8B43C, coral cheek blush #EF6F5E. Wide
symmetrical round eyes with navy iris on cream sclera. Small triangle
beak in gold. Style reference: Duolingo owl meets early Headspace
illustration. Transparent background, square aspect ratio, centered,
character pose: gavel mid-swing with a confident wink and slight smirk.
--no text --no outlines --no realistic feathers --no scary --no baby
features --ar 1:1 --style raw
```

Two variants to generate:

- **Triumphant**: append "gavel mid-swing, confident wink, slight smirk" to
  the pose line.
- **Listening**: replace the pose line with "gavel set down beside the
  character, wings folded over the body, soft concerned eyebrows, head
  tilted listening, calmer expression."

Generate 4-8 attempts per variant. Pick the one with:

1. The cleanest geometry (no extra limbs, weird beak shapes).
2. Eyes that read as warm, not creepy.
3. Robe that reads as a judge's robe, not a wizard cloak or graduation gown.

Run the chosen image through a background remover (remove.bg, Photoshop
"select subject") for the transparent PNG.

---

## Fiverr brief (paste this verbatim)

> I need a custom illustrated mascot for a mobile app called Settle This — a
> playful AI-referee app for everyday low-stakes disagreements. The mascot is
> a plush owl judge named "Judge Pip" — round body, oversized golden gavel,
> deep navy judge's robe with cream collar.
>
> Style: flat vector, no outlines, solid colors only. Reference: Duolingo's
> owl meets early Headspace illustration. Adult-but-warm, NOT cute-baby-app.
>
> Color palette is locked: warm cream #FBF6EC, deep navy #1F2452, golden
> gavel #E8B43C, coral #EF6F5E. Please don't introduce other colors.
>
> Deliverables — two character variants:
> 1. **Pip Triumphant** — gavel mid-swing, wink, smirk. (Hero pose.)
> 2. **Pip Listening** — gavel set down, wings folded, soft empathetic
>    expression. (Calmer twin for sensitive moments.)
>
> File formats per variant:
> - PNG @ 256×256, 512×512, 768×768 (transparent background, all)
> - SVG source (vector original)
>
> Optional add-on if available: a square app icon (1024×1024 PNG) of Pip's
> face centered in a cream/navy/gold circular frame.
>
> Budget: $50-150 depending on the illustrator. Deliver within 5 business
> days preferred.

---

## Once art arrives — drop files here, then ping me

1. Drop all PNG / SVG files into `D:\Settle-This\settle_this\assets\pip\` —
   exact filenames from the lists above.
2. Tell me "Pip art is in" and I'll:
   - Declare the assets in `pubspec.yaml`
   - Flip the asset-ready flag in `lib/shared/widgets/judge_pip.dart`
   - Verify rendering in Chrome
   - Commit + push so the next Codemagic build picks up the new look
3. After that, every place that currently renders the stub circle gold-glyph
   automatically renders the real Pip — verdict hero, home screen host,
   share card, error states, and (after the app icon variant arrives) the
   actual iOS/Android home-screen icon.

---

## What's still on the queue while Pip is being commissioned

We don't need to block on art. Coming up next:

1. Share card visual polish (#2)
2. Submit flow visual polish (#3)
3. Verdict loading screen with bobbing Pip stub (#4)
4. Onboarding screens with Pip hosting (#5)
5. Wire the `getUserUsage` callable so the home counter is live (#6)
6. "Try Another Tone" feature on verdict screen (#7)

All can happen with the current stub. Real Pip drops in on the same day the
art arrives.
