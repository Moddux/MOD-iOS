#!/usr/bin/env bash
set -euo pipefail
INPUT=$1 ; SESSION=$2 ; BACKID=$3
OUT=$SESSION/fs_timeline
mkdir -p "$OUT"
BODY=$OUT/${BACKID}.body
CSV=$OUT/${BACKID}_timeline.csv
fls -r -m / "$INPUT" > "$BODY"
mactime -b "$BODY" -d > "$CSV"
