#!/usr/bin/env bash
set -euo pipefail
# Usage: misp_export.sh <csv_dir> <misp_url> <api_key>
CSV_DIR=$1; URL=$2; KEY=$3
for csv in "$CSV_DIR"/*.csv; do
  while IFS=, read -r type value _; do
    curl -X POST "$URL/attributes" \
      -H "Authorization: $KEY" \
      -H "Content-Type: application/json" \
      -d '{ "Event": { "id": 1 }, "Attribute": { "type": "'"$type"'", "value": "'"$value"'", "to_ids": true } }'
  done < <(tail -n +2 "$csv")
done
