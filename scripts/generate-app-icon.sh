#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ICNS="$ROOT/Chrome/AppIcon.icns"
CHROME_ICNS="/Applications/Google Chrome.app/Contents/Resources/app.icns"
TMPICONSET="/tmp/StealthAppIcon.iconset"
SOURCE_PNG="/tmp/stealth_icon_source_1024.png"

rm -rf "$TMPICONSET"
mkdir -p "$TMPICONSET"

if [ -f "$CHROME_ICNS" ]; then
  CHROME_ICONSET="/tmp/ChromeSource.iconset"
  rm -rf "$CHROME_ICONSET"
  iconutil --convert iconset "$CHROME_ICNS" --output "$CHROME_ICONSET"

  # Chrome ships ic13 with only 256px artwork; upscale for a full Dock-friendly ic12.
  sips -z 1024 1024 "$CHROME_ICONSET/icon_128x128@2x.png" --out "$SOURCE_PNG" >/dev/null
else
  python3 "$ROOT/scripts/render_app_icon.py"
fi

for size in 16 32 128 256 512; do
  sips -z "$size" "$size" "$SOURCE_PNG" --out "$TMPICONSET/icon_${size}x${size}.png" >/dev/null
  double=$((size * 2))
  sips -z "$double" "$double" "$SOURCE_PNG" --out "$TMPICONSET/icon_${size}x${size}@2x.png" >/dev/null
done

iconutil -c icns "$TMPICONSET" -o "$ICNS"
echo "Generated $ICNS ($(file -b "$ICNS"))"
