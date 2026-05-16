"""Build the Settle This app icon from the shipped Pip Triumphant art.

Design (per assets/pip/COMMISSION_BRIEF.md spec for the app icon):
  - 1024x1024 navy canvas (iOS/Android will round corners)
  - cream-filled circle inset from the edges
  - thin gold inner border ring just inside the cream circle
  - Pip's head/bust portrait, cropped from pip_triumph 3x, centered in the cream

Outputs `tools/pip-gen/app_icon_1024.png`. From there, `flutter_launcher_icons`
(declared in pubspec) generates the per-platform launcher icon sets.
"""
from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

PROJECT_ROOT = Path(__file__).resolve().parents[2]
PIP_SRC = PROJECT_ROOT / "settle_this" / "assets" / "pip" / "3.0x" / "pip_triumph.png"
OUT = Path(__file__).resolve().parent / "app_icon_1024.png"

CANVAS = 1024
NAVY = (31, 36, 82, 255)       # #1F2452
CREAM = (251, 246, 236, 255)   # #FBF6EC
GOLD = (232, 180, 60, 255)     # #E8B43C

# Disk geometry (fractions of canvas side).
CREAM_INSET = 0.06   # cream disc inset from canvas edge
GOLD_INSET = 0.055   # gold ring inset (slightly inside cream)
GOLD_WIDTH = 8       # px stroke at 1024


def crop_head(im: Image.Image) -> Image.Image:
    """Crop Pip's head/shoulders bust portrait — top half of the triumph PNG.

    We crop to the bounding box of the upper 55% of opaque pixels, then square
    around the centroid so the head sits centered. The gavel sticks up off the
    head in triumph; we let it crop naturally — only the head/face should
    survive at icon scale.
    """
    arr = np.array(im)
    alpha = arr[:, :, 3]
    h, w = alpha.shape
    # Restrict to head + upper-collar only. Cutting at ~42% of the image
    # height keeps the brown head dome and the top edge of the cream collar
    # but drops shoulders/robe/feet — the face should dominate at favicon
    # scale. The gavel arm extends into the upper region but the centroid
    # weighting below pulls the crop center back onto the face.
    upper = alpha.copy()
    upper[int(h * 0.42):, :] = 0
    ys, xs = np.where(upper > 0)
    if len(ys) == 0:
        return im
    y0, y1 = int(ys.min()), int(ys.max())
    x0, x1 = int(xs.min()), int(xs.max())

    # Find the face by ignoring the gavel/arm column. The face is the
    # densest opaque region in this upper slice; the gavel head is a small
    # offset blob to one side. Use a column-density argmax on a horizontal
    # band that's clearly inside the head (~25-40% of image height) to
    # pinpoint the face center x.
    face_band = alpha[int(h * 0.25):int(h * 0.40), :]
    col_density = (face_band > 0).sum(axis=0)
    cx = int(np.argmax(col_density)) if col_density.max() > 0 else (x0 + x1) // 2
    cy = (y0 + y1) // 2

    # Square crop around the face center, sized just larger than the head
    # bounding box. Tight padding (4%) so the head fills the frame.
    side = int(max(y1 - y0, x1 - x0) * 1.04)
    half = side // 2
    cx0 = max(0, cx - half)
    cy0 = max(0, cy - half)
    cx1 = min(w, cx + half)
    cy1 = min(h, cy + half)
    # Re-square in case clipping made it non-square.
    side = min(cx1 - cx0, cy1 - cy0)
    return im.crop((cx0, cy0, cx0 + side, cy0 + side))


def build_icon() -> Image.Image:
    pip = Image.open(PIP_SRC).convert("RGBA")
    head = crop_head(pip)

    canvas = Image.new("RGBA", (CANVAS, CANVAS), NAVY)
    draw = ImageDraw.Draw(canvas)

    cream_inset = int(CANVAS * CREAM_INSET)
    cream_box = (cream_inset, cream_inset, CANVAS - cream_inset, CANVAS - cream_inset)
    draw.ellipse(cream_box, fill=CREAM)

    gold_inset = int(CANVAS * (CREAM_INSET + 0.015))
    gold_box = (gold_inset, gold_inset, CANVAS - gold_inset, CANVAS - gold_inset)
    draw.ellipse(gold_box, outline=GOLD, width=GOLD_WIDTH)

    # Resize head to fill the cream disc with minimal breathing room — the
    # face should read from a 16px favicon.
    head_target = int((CANVAS - 2 * gold_inset) * 0.92)
    head_resized = head.resize((head_target, head_target), Image.LANCZOS)

    # Mask the head to the cream circle so the gavel doesn't poke out into navy.
    inner_radius = (CANVAS - 2 * gold_inset) // 2 - GOLD_WIDTH
    mask = Image.new("L", (CANVAS, CANVAS), 0)
    ImageDraw.Draw(mask).ellipse(
        (CANVAS // 2 - inner_radius, CANVAS // 2 - inner_radius,
         CANVAS // 2 + inner_radius, CANVAS // 2 + inner_radius),
        fill=255,
    )

    paste_canvas = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    off = (CANVAS - head_target) // 2
    paste_canvas.paste(head_resized, (off, off), head_resized)

    # Apply circular mask to the paste layer so anything outside the cream
    # disc gets clipped (the gavel handle would otherwise stick into navy).
    clipped = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    clipped.paste(paste_canvas, (0, 0), mask)

    return Image.alpha_composite(canvas, clipped)


def main() -> None:
    icon = build_icon()
    icon.save(OUT, "PNG", optimize=True)
    print(f"wrote {OUT.relative_to(PROJECT_ROOT)} ({CANVAS}x{CANVAS})")


if __name__ == "__main__":
    main()
