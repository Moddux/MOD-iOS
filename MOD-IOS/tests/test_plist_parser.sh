#!/usr/bin/env bash
set -euo pipefail
SESSION=$(bash cli/meta-ios.sh --input tests/test_media_case)
if [[ -d "$SESSION/plist" && -n $(ls "$SESSION/plist") ]]; then
  echo "PASS: plist_parser"
else
  echo "FAIL: plist_parser" >&2
  exit 1
fi
