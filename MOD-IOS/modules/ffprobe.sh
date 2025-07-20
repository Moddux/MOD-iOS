#!/usr/bin/env bash
set -euo pipefail
INPUT=$1 ; SESSION=$2 ; BACKID=$3
OUT=$SESSION/ffprobe
mkdir -p "$OUT"
JSON=$OUT/${BACKID}_ffprobe.json
echo "[" > "$JSON"
first=true
find "$INPUT" -type f \( -iname "*.mp4" -o -iname "*.mov" \) -print0 | \
  while IFS= read -r -d '' f; do
    [[ $first == true ]] && first=false || echo "," >> "$JSON"
    ffprobe -v quiet -print_format json -show_format -show_streams "$f" \
      >> "$JSON"
  done
echo "]" >> "$JSON"
