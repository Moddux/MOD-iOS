#!/usr/bin/env bash
set -euo pipefail
INPUT=$1 ; SESSION=$2 ; BACKID=$3
OUT=$SESSION/file_carve
mkdir -p "$OUT"

# Foremost can't take a directory, so run it on each file individually
find "$INPUT" -type f | while read -r file; do
  foremost -i "$file" -o "$OUT/$(basename "$file")_carve" || echo "[!] Skipped: $file" >> "$SESSION/errors.log"
done
