#!/usr/bin/env bash
set -euo pipefail
INPUT=$1; SESSION=$2; BACKID=$3
OUT=$SESSION/plist
mkdir -p "$OUT"
find "$INPUT" -type f -iname "*.plist" -print0 | \
  while IFS= read -r -d '' file; do
    base=$(basename "$file" .plist)
    plutil -convert json -o "$OUT/${base}.json" "$file"
  done
