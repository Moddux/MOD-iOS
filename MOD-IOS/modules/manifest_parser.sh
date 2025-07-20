#!/usr/bin/env bash
set -euo pipefail
INPUT=$1; SESSION=$2; BACKID=$3
OUT=$SESSION/manifest
mkdir -p "$OUT"
if [[ -f "$INPUT/Manifest.db" ]]; then
  sqlite3 "$INPUT/Manifest.db" -header -csv \
    "SELECT datetime(ZMANAGEDACCOUNT.ZCREATIONDATE,'unixepoch') AS created, ZNAME.ZTEXT AS contact_name, ZABCDATAMESSAGE.ZTEXT AS message FROM ZABCDATAMESSAGE JOIN ZNAME ON ZABCDATAMESSAGE.Z_SENDER = ZNAME.Z_PK;" \
    > "$OUT/sms_messages.csv"
fi
