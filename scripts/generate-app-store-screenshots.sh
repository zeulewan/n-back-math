#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/assets/screenshot.png"
OUT="$ROOT/fastlane/screenshots/en-US"

if ! command -v magick >/dev/null 2>&1; then
  echo "ImageMagick is required: brew install imagemagick" >&2
  exit 1
fi

mkdir -p "$OUT"

magick "$SRC" -resize 2688x1242 -background "#090909" -gravity center -extent 2688x1242 -strip "$OUT/01_iphone_65.png"
magick "$SRC" -resize 2732x2048 -background "#090909" -gravity center -extent 2732x2048 -strip "$OUT/02_ipad_129.png"

echo "Wrote App Store screenshots to $OUT"
