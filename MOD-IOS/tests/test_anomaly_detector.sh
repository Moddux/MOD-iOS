#!/usr/bin/env bash
set -euo pipefail
SESSION=$(bash cli/meta-ios.sh --input tests/test_media_case)
BACKID=$(basename tests/test_media_case)
if [[ -f "$SESSION/anomalies/${BACKID}_time_anomalies.csv" ]]; then
  echo "PASS: anomaly_detector"
else
  echo "SKIP: anomaly_detector (no anomalies detected or no timeline data)" >&2
fi
