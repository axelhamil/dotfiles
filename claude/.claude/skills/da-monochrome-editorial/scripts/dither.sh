#!/usr/bin/env bash
# Duotone 1-bit dithering — DA monochrome éditoriale.
# Usage: ./dither.sh input.jpg "#1400FF" [output.png] [width]
set -euo pipefail

command -v magick >/dev/null || { echo "ImageMagick (magick) requis"; exit 1; }

src="${1:?image source manquante}"
ink="${2:-#1400FF}"
out="${3:-${src%.*}-dither.png}"
width="${4:-1200}"

magick "$src" \
  -resize "${width}x>" \
  -colorspace Gray \
  -normalize \
  -ordered-dither o8x8 \
  -colorspace sRGB \
  \( -clone 0 -fill "$ink" -colorize 100 \) \
  -compose Screen -composite \
  "$out"

echo "$out"
