#!/usr/bin/env bash
set -euo pipefail
SESSION=$(bash cli/meta-ios.sh --input tests/test_media_case)
if [[ -d "$SESSION/tamper" && -f "$SESSION/tamper/sample.jpg.exif.json" ]]; then
  echo "PASS: image_tamper"
else
  echo "FAIL: image_tamper" >&2
  exit 1
fi
