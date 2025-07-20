#!/usr/bin/env bash
set -euo pipefail
INPUT=$1 ; SESSION=$2 ; BACKID=$3
OUT=$SESSION/identity_fingerprint
mkdir -p "$OUT"
CSV=$OUT/identity_fingerprint_accounts.csv
echo "accountIdentifier,username" > "$CSV"
if [[ -f "$INPUT/Manifest.db" ]]; then
  sqlite3 "$INPUT/Manifest.db" \
    "SELECT ZMANAGEDACCOUNT.ZOWNER AS accountIdentifier, ZMANAGEDACCOUNT.ZUSERNAME AS username FROM ZMANAGEDACCOUNT;" \
    >> "$CSV"
fi
