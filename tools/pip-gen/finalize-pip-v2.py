"""Finalize chosen Pip v2 candidates into shippable Flutter assets.

For each picked pose: remove the (baked-in) background with rembg -> tight-crop to
the character bbox with a small pad -> center on a square transparent canvas ->
downscale to 768/512/256 px -> save compressed into the Flutter resolution-aware
asset layout:
    assets/pip/pip_<pose>.png        (256 px, 1x)
    assets/pip/2.0x/pip_<pose>.png   (512 px, 2x)
    assets/pip/3.0x/pip_<pose>.png   (768 px, 3x)

The model draws a literal gray/white checkerboard to mean "transparent", so a real
salient-object cutout (rembg) is required — the raw PNGs have no alpha.
"""
from pathlib import Path
from PIL import Image
import numpy as np
from rembg import remove, new_session

HERE = Path(__file__).resolve().parent
CAND = HERE / "v2_candidates"
CANON = HERE / "canon"
ASSETS = HERE.parent.parent / "settle_this" / "assets" / "pip"

# pose -> chosen source (confirmed 2026-06-07)
PICKS = {
    "triumph":    CANON / "pip_hero.png",
    "gavel_down": CAND / "gavel_down" / "gavel_down_0.png",
    "listening":  CAND / "listening" / "listening_0.png",
    "thinking":   CAND / "thinking" / "thinking_1.png",
    "shrug":      CAND / "shrug" / "shrug_0.png",
    "oops":       CAND / "oops" / "oops_0.png",
}

SIZES = {"3.0x": 768, "2.0x": 512, "": 256}  # subdir -> px ("" = base/1x)
PAD_FRAC = 0.04
ALPHA_THRESH = 12

session = new_session("isnet-general-use")  # clean edges for flat illustration


def cutout(src: Path) -> Image.Image:
    im = Image.open(src).convert("RGBA")
    return remove(im, session=session, post_process_mask=True)


def tight_square(im: Image.Image) -> Image.Image:
    a = np.array(im)[:, :, 3]
    ys, xs = np.where(a > ALPHA_THRESH)
    if len(xs) == 0:
        return im
    x0, x1, y0, y1 = xs.min(), xs.max(), ys.min(), ys.max()
    crop = im.crop((x0, y0, x1 + 1, y1 + 1))
    w, h = crop.size
    side = int(max(w, h) * (1 + 2 * PAD_FRAC))
    canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    canvas.paste(crop, ((side - w) // 2, (side - h) // 2), crop)
    return canvas


def main():
    for pose, src in PICKS.items():
        if not src.exists():
            print(f"!! missing {src}")
            continue
        print(f">>> {pose}: {src.name}")
        sq = tight_square(cutout(src))
        for subdir, px in SIZES.items():
            out_dir = ASSETS / subdir if subdir else ASSETS
            out_dir.mkdir(parents=True, exist_ok=True)
            out = out_dir / f"pip_{pose}.png"
            sq.resize((px, px), Image.LANCZOS).save(out, optimize=True)
            kb = out.stat().st_size // 1024
            print(f"    {out.relative_to(ASSETS.parent.parent)}  ({px}px, {kb}KB)")
    print(">>> DONE")


if __name__ == "__main__":
    main()
