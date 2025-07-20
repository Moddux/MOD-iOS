#!/usr/bin/env bash
set -euo pipefail
INPUT=$1 ; SESSION=$2 ; BACKID=$3
OUT=$SESSION/bulk_extractor
bulk_extractor -r "$INPUT" -o "$OUT"
