#!/usr/bin/env python3
"""Render a full-bleed 1024x1024 app icon PNG from the Chrome logo webp."""

from __future__ import annotations

import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("Pillow is required: python3 -m pip install Pillow", file=sys.stderr)
    sys.exit(1)


def is_background_pixel(r: int, g: int, b: int) -> bool:
    """Replace neutral checkerboard / white backdrop pixels with solid white."""
    spread = max(r, g, b) - min(r, g, b)
    if spread > 28:
        return False
    return min(r, g, b) >= 120


def render_icon(source: Path, output: Path, size: int = 1024) -> None:
    image = Image.open(source).convert("RGBA")
    pixels = image.load()
    width, height = image.size

    for y in range(height):
        for x in range(width):
            r, g, b, _ = pixels[x, y]
            if is_background_pixel(r, g, b):
                pixels[x, y] = (255, 255, 255, 255)

    # Trim a small outer margin, then scale to fill the icon canvas.
    margin = int(min(width, height) * 0.02)
    cropped = image.crop((margin, margin, width - margin, height - margin))

    canvas = Image.new("RGBA", (size, size), (255, 255, 255, 255))
    logo = cropped.resize((size, size), Image.Resampling.LANCZOS)
    canvas.alpha_composite(logo)

    output.parent.mkdir(parents=True, exist_ok=True)
    canvas.convert("RGB").save(output, format="PNG")
    print(f"Wrote {output} ({size}x{size})")


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    source = root / "scripts" / "icon-sources" / "5963_hm4I.webp"
    output = Path("/tmp/stealth_icon_source_1024.png")

    if not source.exists():
        print(f"Missing source image: {source}", file=sys.stderr)
        sys.exit(1)

    render_icon(source, output)


if __name__ == "__main__":
    main()
