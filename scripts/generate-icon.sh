#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ICON="$ROOT/ios/App/App/Assets.xcassets/AppIcon.appiconset/AppIcon-512@2x.png"
FONT="/System/Library/Fonts/Supplemental/Arial Black.ttf"

if ! command -v magick >/dev/null 2>&1; then
  echo "ImageMagick is required: brew install imagemagick" >&2
  exit 1
fi

magick -size 1024x1024 xc:"#090909" \
  -fill "#111111" -stroke "#303030" -strokewidth 8 -draw "roundrectangle 66,66 958,958 88,88" \
  -stroke none -font "$FONT" -gravity center \
  -fill "#f4f4f4" -pointsize 174 -annotate +0-92 "N BACK" \
  -fill "#b8b8b8" -pointsize 170 -annotate +0+132 "MATH" \
  -alpha off -colorspace sRGB -type TrueColor -depth 8 -strip "$ICON"

echo "Wrote $ICON"
