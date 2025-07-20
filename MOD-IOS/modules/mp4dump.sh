#!/usr/bin/env bash
set -euo pipefail
INPUT=$1 ; SESSION=$2 ; BACKID=$3
OUT=$SESSION/mp4dump
mkdir -p "$OUT"
find "$INPUT" -type f \( -iname "*.mp4" -o -iname "*.mov" \) -print0 | \
  while IFS= read -r -d '' f; do
    bn=$(basename "$f" | tr -c 'a-zA-Z0-9._-' '_')
    mp4dump "$f" > "$OUT/${bn}_mp4dump.txt"
  done
