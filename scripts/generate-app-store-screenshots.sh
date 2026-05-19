#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/assets/screenshot.png"
OUT="$ROOT/fastlane/screenshots/en-US"
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"

if ! command -v magick >/dev/null 2>&1; then
  echo "ImageMagick is required: brew install imagemagick" >&2
  exit 1
fi

if [[ ! -x "$CHROME" ]]; then
  echo "Google Chrome is required to render the portrait iPhone screenshot." >&2
  echo "Set CHROME=/path/to/chrome if it is installed somewhere else." >&2
  exit 1
fi

mkdir -p "$OUT"

"$CHROME" \
  --headless \
  --disable-gpu \
  --hide-scrollbars \
  --screenshot="$OUT/01_iphone_65.png" \
  --window-size=1242,2688 \
  "file://$ROOT/index.html" >/dev/null 2>&1
magick "$OUT/01_iphone_65.png" -strip "$OUT/01_iphone_65.png"

magick "$SRC" -resize 2732x2048 -background "#090909" -gravity center -extent 2732x2048 -strip "$OUT/02_ipad_129.png"

echo "Wrote App Store screenshots to $OUT"
