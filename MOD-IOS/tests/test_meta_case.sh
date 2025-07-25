#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
CLI="$ROOT/cli/meta-ios.sh"
DATA="$ROOT/tests/test_media_case"

printf "Running smoke test …\n"
OUTPUT=$("$CLI" --input "$DATA")
SESSION=$(echo "$OUTPUT" | awk -F' at ' '{print $2}')

fail(){ echo "❌  $1"; exit 1; }
pass(){ echo "✅  $1"; }

check(){ local glob="$1" desc="$2"
  if compgen -G "$SESSION/$glob" >/dev/null; then pass "$desc"; else fail "$desc missing"; fi; }

check "audit.log"                            "audit log"
check "errors.log"                           "error log"
check "exif_audit/*_exif.json"               "EXIF output"
check "ffprobe/*_ffprobe.json"               "FFprobe output"
check "mediainfo/*_mediainfo.json"           "MediaInfo output"
check "mp4dump/*_mp4dump.txt"                "MP4dump output"
check "timeline/*_timeline.csv"              "timeline CSV"
check "identity_fingerprint/*_identity_fingerprint_accounts.csv" "identity CSV"
check "bulk_extractor/*/email.txt"           "bulk_extractor artefacts"
check "carving/*"                            "Foremost carving output"
check "gps_map/*_gps_map.html"               "GPS map"
check "session.sqlite"                       "SQLite DB"

echo -e "\n🎉  All checks passed!"
