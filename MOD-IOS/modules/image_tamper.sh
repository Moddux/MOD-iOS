#!/usr/bin/env bash
set -euo pipefail
INPUT=$1; SESSION=$2; BACKID=$3
OUT=$SESSION/tamper
mkdir -p "$OUT"
find "$INPUT" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -print0 | \
  while IFS= read -r -d '' file; do
    fname=$(basename "$file")
    exiftool -d "%Y-%m-%d %H:%M:%S" -a -G1 -json "$file" > "$OUT/${fname}.exif.json"
    identify -verbose "$file" | tee "$OUT/${fname}.identify.txt"
  done
