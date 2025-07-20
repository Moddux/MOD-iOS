#!/usr/bin/env bash
set -euo pipefail
INPUT=$1 ; SESSION=$2 ; BACKID=$3
OUT=$SESSION/file_carve
mkdir -p "$OUT"
foremost -i "$INPUT" -o "$OUT"
