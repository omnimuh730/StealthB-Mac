#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/dist"
APP_NAME="StealthBrowser.app"

"$ROOT/scripts/generate-app-icon.sh"

cd "$ROOT"
xcodebuild \
  -scheme StealthBrowser \
  -configuration Release \
  -derivedDataPath "$ROOT/.derivedData" \
  build

BUILT_APP="$ROOT/.derivedData/Build/Products/Release/$APP_NAME"
rm -rf "$DIST"
mkdir -p "$DIST"
ditto "$BUILT_APP" "$DIST/$APP_NAME"

LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Versions/Current/Frameworks/LaunchServices.framework/Versions/Current/Support/lsregister"
if [ -x "$LSREGISTER" ]; then
  "$LSREGISTER" -f -R -trusted "$DIST/$APP_NAME"
fi

echo ""
echo "Release app ready:"
echo "  $DIST/$APP_NAME"
echo ""
echo "Run with:"
echo "  open \"$DIST/$APP_NAME\""
