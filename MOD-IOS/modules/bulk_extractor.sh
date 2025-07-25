#!/usr/bin/env bash
set -euo pipefail

INPUT=$1
SESSION=$2
BACKID=$3
OUT=$SESSION/bulk_extractor
mkdir -p "$OUT"

# Run BE on each file individually
find "$INPUT" -type f | while read -r FILE; do
  FNAME=$(basename "$FILE")
  FOUT="$OUT/${FNAME}_bx"
  mkdir -p "$FOUT"

  echo "[*] Running bulk_extractor on $FILE" >> "$SESSION/audit.log"
  if bulk_extractor -o "$FOUT" "$FILE" >> "$SESSION/audit.log" 2>> "$SESSION/errors.log"; then
    echo "[+] bulk_extractor success: $FILE" >> "$SESSION/audit.log"
  else
    echo "[!] bulk_extractor failed: $FILE" >> "$SESSION/audit.log"
  fi
done

echo "[*] Finished bulk_extractor module." >> "$SESSION/audit.log"
