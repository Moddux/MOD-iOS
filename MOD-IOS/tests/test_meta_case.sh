#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
CLI=$ROOT/cli/meta-ios.sh
DATA=$ROOT/tests/test_media_case
OUT=$(bash "$CLI" --input "$DATA")
SESSION=$(echo "$OUT" | awk -F' at ' '{print $2}')
[[ -f "$SESSION/audit.log" ]] || exit 1
[[ -s "$SESSION/fs_timeline/*_timeline.csv" ]] || exit 1
[[ -s "$SESSION/exif_audit/*.json" ]] || exit 1
echo "PASS"
