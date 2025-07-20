#!/usr/bin/env bash
set -euo pipefail
INPUT=$1 ; SESSION=$2 ; BACKID=$3
OUT=$SESSION/mediainfo
mkdir -p "$OUT"
find "$INPUT" -type f \( -iname "*.mp4" -o -iname "*.mov" -o -iname "*.mkv" \) -print0 | \
  while IFS= read -r -d '' f; do
    name=$(basename "$f")
    mediainfo --Output=JSON "$f" > "$OUT/${name%.*}_mediainfo.json"
  done
