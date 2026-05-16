"""Promote chosen Recraft draft owls into shippable pip_triumph / pip_listening
asset variants.

- For triumph: removes books / ground shadow / sprout below y=780 using
  largest-connected-component masking on the fully-opaque pixels (the owl is
  one big blob; props are separate blobs that share the same anti-aliased
  alpha skirt). Pip's anti-aliased edges are recovered with a 3px dilation.
- For listening: kept as-is (the stump is structural to the pose).
- Both: re-cropped to a tight transparent bounding box with a small padding,
  then downscaled with LANCZOS to 768 / 512 / 256 px and written using
  Flutter's resolution-aware subdirectory convention:
    settle_this/assets/pip/pip_<pose>.png         (256, 1x)
    settle_this/assets/pip/2.0x/pip_<pose>.png    (512, 2x)
    settle_this/assets/pip/3.0x/pip_<pose>.png    (768, 3x)
"""
from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

PROJECT_ROOT = Path(__file__).resolve().parents[2]
ASSETS_DIR = PROJECT_ROOT / "settle_this" / "assets" / "pip"
DRAFTS_DIR = ASSETS_DIR / "_recraft_drafts"

TRIUMPH_SRC = DRAFTS_DIR / "triumph_2026-05-14T02-35-08_2.png"
LISTENING_SRC = DRAFTS_DIR / "listening_2026-05-16T06-43-40_2.png"

# Triumph: mask everything below this y that isn't part of Pip's main blob.
TRIUMPH_PROP_Y_THRESHOLD = 780

# Resolution-aware variants Flutter looks up by subdirectory (1x lives in the
# base dir, 2x in 2.0x/, 3x in 3.0x/).
VARIANTS = [
    (768, "3.0x"),
    (512, "2.0x"),
    (256, ""),
]
PAD_PCT = 0.04  # transparent padding around tight bbox, as fraction of side


def mask_owl_only(im: Image.Image, y_threshold: int) -> Image.Image:
    arr = np.array(im)
    alpha = arr[:, :, 3]
    solid = alpha >= 250
    labeled, n = ndimage.label(solid)
    if n == 0:
        return im
    sizes = ndimage.sum(solid, labeled, range(1, n + 1))
    main_id = int(np.argmax(sizes)) + 1
    main = labeled == main_id
    main_dilated = ndimage.binary_dilation(main, iterations=3)

    out = arr.copy()
    below = np.zeros_like(alpha, dtype=bool)
    below[y_threshold:, :] = True
    wipe = below & ~main_dilated
    out[wipe, 3] = 0
    return Image.fromarray(out)


def crop_to_content(im: Image.Image, pad_pct: float) -> Image.Image:
    arr = np.array(im)
    alpha = arr[:, :, 3]
    ys, xs = np.where(alpha > 0)
    if len(ys) == 0:
        return im
    y0, y1 = int(ys.min()), int(ys.max()) + 1
    x0, x1 = int(xs.min()), int(xs.max()) + 1
    h, w = y1 - y0, x1 - x0
    side = max(h, w)
    pad = int(side * pad_pct)
    cy, cx = (y0 + y1) // 2, (x0 + x1) // 2
    half = side // 2 + pad
    box_y0 = max(0, cy - half)
    box_y1 = min(alpha.shape[0], cy + half)
    box_x0 = max(0, cx - half)
    box_x1 = min(alpha.shape[1], cx + half)
    return im.crop((box_x0, box_y0, box_x1, box_y1))


def emit_variants(im: Image.Image, base: str) -> None:
    canvas_side = max(im.size)
    square = Image.new("RGBA", (canvas_side, canvas_side), (0, 0, 0, 0))
    off_x = (canvas_side - im.size[0]) // 2
    off_y = (canvas_side - im.size[1]) // 2
    square.paste(im, (off_x, off_y), im)

    for size, subdir in VARIANTS:
        out = square.resize((size, size), Image.LANCZOS)
        target_dir = ASSETS_DIR / subdir if subdir else ASSETS_DIR
        target_dir.mkdir(parents=True, exist_ok=True)
        path = target_dir / f"{base}.png"
        out.save(path, "PNG", optimize=True)
        print(f"  wrote {path.relative_to(PROJECT_ROOT)} ({size}x{size})")


def process(src: Path, base: str, *, mask: bool) -> None:
    print(f"\n{base}: {src.name}")
    im = Image.open(src).convert("RGBA")
    if mask:
        im = mask_owl_only(im, TRIUMPH_PROP_Y_THRESHOLD)
        print("  masked props (books / shadow / sprout)")
    im = crop_to_content(im, PAD_PCT)
    print(f"  cropped to content: {im.size}")
    emit_variants(im, base)


def main() -> None:
    ASSETS_DIR.mkdir(parents=True, exist_ok=True)
    process(TRIUMPH_SRC, "pip_triumph", mask=True)
    process(LISTENING_SRC, "pip_listening", mask=False)
    print("\nDone.")


if __name__ == "__main__":
    main()
