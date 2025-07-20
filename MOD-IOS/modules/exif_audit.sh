#!/usr/bin/env bash
set -euo pipefail
INPUT=$1 ; SESSION=$2 ; BACKID=$3
OUT=$SESSION/exif_audit
mkdir -p "$OUT"
JSON=$OUT/${BACKID}_exif.json
exiftool -j -r "$INPUT" > "$JSON"
