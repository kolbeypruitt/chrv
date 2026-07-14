#!/usr/bin/env bash
# Dev-time only. Regenerates optimized web assets from img/park/original/*.jpg
# and img/logo.svg. Requires macOS built-ins: sips, cwebp (brew install webp), qlmanage.
set -euo pipefail

SRC_DIR="img/park/original"
OUT_DIR="img/park"

resize_and_convert() {
  local name="$1" width="$2"
  local src="$SRC_DIR/${name}.jpg"
  local jpg_out="$OUT_DIR/${name}-${width}.jpg"
  local webp_out="$OUT_DIR/${name}-${width}.webp"
  sips -Z "$width" "$src" --out "$jpg_out" >/dev/null
  cwebp -quiet -q 78 "$jpg_out" -o "$webp_out"
}

for name in image0 image1 image2 image3 image4; do
  resize_and_convert "$name" 800
done
resize_and_convert image0 1600

# Favicons from the SVG logo
qlmanage -t -s 512 -o "$OUT_DIR/.." img/logo.svg >/dev/null
mv "img/logo.svg.png" img/favicon-512.png
sips -Z 180 img/favicon-512.png --out img/apple-touch-icon.png >/dev/null
sips -Z 32 img/favicon-512.png --out img/favicon-32.png >/dev/null

echo "Done. Generated files:"
ls -la "$OUT_DIR"/*.webp "$OUT_DIR"/*-800.jpg "$OUT_DIR"/*-1600.jpg img/favicon-*.png img/apple-touch-icon.png
