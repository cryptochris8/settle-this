"""Judge Pip v2 generator — card-as-canon reference-conditioning pipeline.

Applies the consistency method proven on Squishy Smash (see IMPROVEMENT_ROADMAP.md
section 6): one locked hero reference + a canon anchor restated twice + ALL-CAPS
anti-features, with every pose generated FRESH from the hero (never iterative edits).

Two modes:
  hero            Generate N candidate hero Pips (text->image, no reference).
                  Human-pick the best, save it as canon/pip_hero.png. Do this ONCE.
  pose <key>      Generate N candidates of a pose, reference-conditioned on
                  canon/pip_hero.png so identity is preserved.

Two backends:
  genai  (default, the chosen engine) Nano Banana Pro = gemini-3-pro-image-preview.
         Needs a Google GenAI key. Resolution order:
           --key-file PATH  ->  $GEMINI_API_KEY  ->  C:\\Users\\chris\\gemini.key.txt
  fal    Fal.ai. Hero via fal-ai/flux/dev; poses via fal-ai/nano-banana/edit
         (the same Nano Banana model Squishy used for its 48 sprites).
         Needs $FAL_KEY (present in D:\\squishy-smash\\.env).

Canon source of truth: settle_this/assets/pip/PIP_CANON.md. The anchor/poses below
are kept in sync with it by hand — edit both together.

Usage:
  python generate-pip-v2.py hero --n 6
  python generate-pip-v2.py pose gavel_down --n 3
  python generate-pip-v2.py pose listening --n 3 --backend fal
"""
import argparse
import base64
import os
import sys
import time
from pathlib import Path

# --- paths -----------------------------------------------------------------
HERE = Path(__file__).resolve().parent          # tools/pip-gen
CANON_DIR = HERE / "canon"
HERO_REF = CANON_DIR / "pip_hero.png"
OUT_ROOT = HERE / "v2_candidates"

# --- canon (keep in sync with assets/pip/PIP_CANON.md) ---------------------
ANCHOR = (
    "Judge Pip — a plush, slightly stout owl judge. Dome-shaped head merging into an "
    "oval body, about 1:1 head-to-body ratio, short and round. Deep-navy judge's robe "
    "(trapezoid, hides the feet) with a cream Peter Pan collar. Large round symmetrical "
    "eyes: solid navy iris on cream sclera, one small cream highlight dot upper-left of "
    "each iris. Small golden triangular beak centered just below mid-face. Soft coral "
    "cheek blush at about 30% opacity. Holds an oversized golden gavel about the length "
    "of his body: gold head, deep-navy handle, wrapped in a wing (no visible hands). "
    "Palette ONLY: warm cream #FBF6EC (body, collar, sclera), deep navy #1F2452 (robe, "
    "gavel handle, irises), golden #E8B43C (gavel head, beak), coral #EF6F5E (cheeks)."
)

ANTI = (
    "FLAT VECTOR STYLE: solid color fills only, NO outlines, NO line art, NO gradients, "
    "NO shading, NO painterly texture, NO realistic feathers. NOT brown — it is a cream "
    "owl in a navy robe. NOT a barn owl. NOT a wizard or graduate (a JUDGE'S robe, not a "
    "cloak or gown). NO baby-bird features, NO sad huge eyes, NO scary features. "
    "Transparent background. Single centered character. NO text, NO letters, NO words, "
    "NO props beyond the gavel."
)

# pose key -> the only line that varies per pose
POSES = {
    "triumph":
        "POSE: gavel raised mid-swing in one wing, one eye in a confident wink, beak in a "
        "slight smirk, head tilted slightly. A confident 'verdict delivered' stance.",
    "gavel_down":
        "POSE: the gavel has just struck a small block at the bottom, both eyes open and "
        "decisive, a satisfied expression. The exact moment the gavel comes down.",
    "listening":
        "POSE: the gavel is set DOWN beside Pip on a small block (NOT held, NOT raised), "
        "both wings folded gently over the body, soft empathetic eyebrows, head tilted in "
        "an 'I'm hearing you' posture. Calm and warm, less gold emphasis.",
    "thinking":
        "POSE: looking upward thoughtfully, one wing raised to the chin/beak, a few small "
        "golden sparkles floating above the head. Pondering the case.",
    "shrug":
        "POSE: both wings raised outward, palms-up shrug, a gentle 'not enough to call it' "
        "expression with raised brows. Good-natured uncertainty.",
    "oops":
        "POSE: a little flustered and sheepish, a couple of cream papers fluttering around, "
        "an apologetic look. The tiny judge dropped the paperwork.",
}


def build_prompt(pose_key: str, is_hero: bool) -> str:
    pose_line = POSES["triumph"] if is_hero else POSES[pose_key]
    if is_hero:
        framing = (
            "FRAMING: show the FULL BODY from the top of the head down to the small feet "
            "below the robe — nothing cropped or cut off. Center the character with clear "
            "empty margin on all four sides. Standing, facing forward."
        )
        return (
            f"Create a mascot character illustration. {ANCHOR}\n\n{pose_line}\n\n{framing}\n\n"
            f"{ANTI}\n\nReminder: preserve the palette EXACTLY, keep it FLAT VECTOR with NO "
            f"outlines, and keep the WHOLE character visible within the frame."
        )
    # reference-conditioned: anchor stated twice (Squishy pattern)
    return (
        f"The attached image is the canonical reference for a mascot owl named Judge Pip. "
        f"{ANCHOR}\n\n"
        f"Generate a single NEW image of THIS EXACT CHARACTER in a new pose.\n{pose_line}\n\n"
        f"{ANTI}\n\n"
        f"Preserve his exact appearance from the reference: same cream body, same navy robe, "
        f"same eye design, same gold beak, same coral cheeks, same flat-vector no-outline "
        f"style and palette. He must be recognizably the same character as the reference."
    )


# --- backend: Google GenAI (Nano Banana Pro) -------------------------------
def resolve_genai_key(key_file: str | None) -> str:
    if key_file:
        return Path(key_file).read_text(encoding="utf-8").strip()
    if os.environ.get("GEMINI_API_KEY"):
        return os.environ["GEMINI_API_KEY"].strip()
    default = Path(r"C:\Users\chris\gemini.key.txt")
    if default.exists():
        return default.read_text(encoding="utf-8").strip()
    sys.exit(
        "ERROR: no Google GenAI key. Provide --key-file PATH, set $GEMINI_API_KEY, or "
        "place the key at C:\\Users\\chris\\gemini.key.txt. (Or use --backend fal.)"
    )


def gen_genai(prompt: str, ref: Path | None, n: int, out_dir: Path, stem: str, key_file):
    # Schannel SSL workaround — patch httpx before SDK import (from Squishy pipeline)
    import httpx
    _o, _oa = httpx.Client.__init__, httpx.AsyncClient.__init__
    httpx.Client.__init__ = lambda s, *a, **kw: (kw.update(verify=False), _o(s, *a, **kw))[1]
    httpx.AsyncClient.__init__ = lambda s, *a, **kw: (kw.update(verify=False), _oa(s, *a, **kw))[1]
    import warnings
    warnings.filterwarnings("ignore", message="Unverified HTTPS request")
    import PIL.Image
    from google import genai

    client = genai.Client(api_key=resolve_genai_key(key_file))
    contents = [prompt]
    if ref:
        contents.append(PIL.Image.open(ref))

    saved = 0
    for k in range(n):
        print(f"  [genai] candidate {k+1}/{n} ...", flush=True)
        t0 = time.time()
        resp = client.models.generate_content(
            model="gemini-3-pro-image-preview", contents=contents,
        )
        for cand in resp.candidates or []:
            for part in (cand.content.parts if cand.content else []) or []:
                if part.inline_data and part.inline_data.data:
                    out = out_dir / f"{stem}_{k}.png"
                    out.write_bytes(part.inline_data.data)
                    print(f"    saved {out.name} ({len(part.inline_data.data)}B, {int(time.time()-t0)}s)")
                    saved += 1
                elif part.text:
                    print(f"    text: {part.text[:160]}")
    return saved


# --- backend: Fal.ai -------------------------------------------------------
def gen_fal(prompt: str, ref: Path | None, n: int, out_dir: Path, stem: str):
    import requests  # noqa
    key = os.environ.get("FAL_KEY")
    if not key:
        sys.exit("ERROR: $FAL_KEY not set (see D:\\squishy-smash\\.env). Or use --backend genai.")
    headers = {"Authorization": f"Key {key}", "Content-Type": "application/json"}

    if ref:  # reference-conditioned pose -> nano-banana/edit (Gemini image edit)
        data_uri = "data:image/png;base64," + base64.b64encode(ref.read_bytes()).decode()
        url = "https://fal.run/fal-ai/nano-banana/edit"
        payload = {"prompt": prompt, "image_urls": [data_uri], "num_images": n}
    else:    # hero text->image -> flux/dev (high quality, then locked as canon)
        url = "https://fal.run/fal-ai/flux/dev"
        payload = {"prompt": prompt, "num_images": n, "image_size": "square_hd",
                   "num_inference_steps": 28, "guidance_scale": 3.5}

    print(f"  [fal] POST {url} (n={n}) ...", flush=True)
    r = requests.post(url, json=payload, headers=headers, timeout=300)
    r.raise_for_status()
    imgs = r.json().get("images", [])
    saved = 0
    for k, im in enumerate(imgs):
        content = requests.get(im["url"], timeout=120).content if im.get("url") else \
            base64.b64decode(im["data"])
        out = out_dir / f"{stem}_{k}.png"
        out.write_bytes(content)
        print(f"    saved {out.name} ({len(content)}B)")
        saved += 1
    return saved


# --- main ------------------------------------------------------------------
def main():
    ap = argparse.ArgumentParser(description="Judge Pip v2 reference-conditioned generator")
    ap.add_argument("mode", choices=["hero", "pose"])
    ap.add_argument("pose", nargs="?", help="pose key (required for mode=pose)")
    ap.add_argument("--n", type=int, default=4, help="candidates to generate")
    ap.add_argument("--backend", choices=["genai", "fal"], default="genai")
    ap.add_argument("--key-file", help="path to a Google GenAI key file (genai backend)")
    args = ap.parse_args()

    is_hero = args.mode == "hero"
    if not is_hero:
        if not args.pose or args.pose not in POSES:
            sys.exit(f"ERROR: mode=pose needs a valid pose key. Options: {', '.join(POSES)}")
        if not HERO_REF.exists():
            sys.exit(f"ERROR: no canon hero at {HERO_REF}. Run 'hero' first, pick one, save it there.")

    stem = "hero" if is_hero else args.pose
    out_dir = OUT_ROOT / stem
    out_dir.mkdir(parents=True, exist_ok=True)
    ref = None if is_hero else HERO_REF
    prompt = build_prompt(args.pose, is_hero)

    print(f">>> {args.mode} '{stem}' | backend={args.backend} | n={args.n}")
    print(f">>> reference: {ref or '(none — text->image)'}")
    if args.backend == "genai":
        saved = gen_genai(prompt, ref, args.n, out_dir, stem, args.key_file)
    else:
        saved = gen_fal(prompt, ref, args.n, out_dir, stem)

    print(f">>> DONE — {saved} candidate(s) in {out_dir}")
    if is_hero and saved:
        print(f">>> NEXT: pick the best and save it as {HERO_REF}, then generate poses.")


if __name__ == "__main__":
    main()
