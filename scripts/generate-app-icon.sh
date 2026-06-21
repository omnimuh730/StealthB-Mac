#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SVG="$ROOT/StealthBrowser/Google_Chrome_Logo.svg"
ICNS="$ROOT/StealthBrowser/AppIcon.icns"
TMPPNG="/tmp/stealth_icon_source_1024.png"
TMPICONSET="/tmp/StealthAppIcon.iconset"

rm -rf "$TMPICONSET"
mkdir -p "$TMPICONSET"

# Prefer vector source (no checkerboard artifacts from webp).
if command -v rsvg-convert >/dev/null 2>&1; then
  rsvg-convert -w 1024 -h 1024 "$SVG" -o "$TMPPNG"
else
  qlmanage -t -s 1024 -o /tmp "$SVG" >/dev/null 2>&1
  mv "/tmp/$(basename "$SVG").png" "$TMPPNG"
fi

for size in 16 32 128 256 512; do
  sips -z "$size" "$size" "$TMPPNG" --out "$TMPICONSET/icon_${size}x${size}.png" >/dev/null
  double=$((size * 2))
  sips -z "$double" "$double" "$TMPPNG" --out "$TMPICONSET/icon_${size}x${size}@2x.png" >/dev/null
done

iconutil -c icns "$TMPICONSET" -o "$ICNS"
echo "Generated $ICNS ($(file -b "$ICNS"))"
