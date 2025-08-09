#!/usr/bin/env bash
set -euo pipefail

# Requires: sqlite3
command -v sqlite3 >/dev/null 2>&1 || { echo "sqlite3 is required"; exit 1; }

BASE="MOD-IOS"
TARGET="$BASE/target_"
mkdir -p "$TARGET"

# Helper: write XML plist
write_plist_xml () {
  local path="$1"; shift
  cat > "$path" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
PLIST
  # remaining arguments are alternating <key> <value> pairs, value types guessed
  while (( "$#" )); do
    key="$1"; val="$2"; shift 2
    if [[ "$val" == "true" || "$val" == "false" ]]; then
      echo "  <key>${key}</key><${val}/>" >> "$path"
    elif [[ "$val" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
      echo "  <key>${key}</key><real>${val}</real>" >> "$path"
    else
      echo "  <key>${key}</key><string>${val}</string>" >> "$path"
    fi
  done
  echo "</dict></plist>" >> "$path"
}

# Helper: minimal sqlite with a couple of tables
mk_sqlite() {
  local db="$1"
  sqlite3 "$db" <<'SQL'
PRAGMA journal_mode=WAL;
CREATE TABLE IF NOT EXISTS ZMESSAGE(
  Z_PK INTEGER PRIMARY KEY,
  ZDATE INTEGER,
  ZISFROMME INTEGER,
  ZTEXT TEXT
);
CREATE TABLE IF NOT EXISTS ZCHAT(
  Z_PK INTEGER PRIMARY KEY,
  ZDISPLAYNAME TEXT
);
INSERT INTO ZMESSAGE(ZDATE,ZISFROMME,ZTEXT) VALUES(714000000,1,'hello world');
INSERT INTO ZCHAT(ZDISPLAYNAME) VALUES('Test Chat');
VACUUM;
SQL
}

# 1) Unencrypted backup folder
UUID1="00008101-0012342E36B1201A"
B1="$TARGET/$UUID1"
mkdir -p "$B1"

write_plist_xml "$B1/Manifest.plist" \
  IsEncrypted false \
  WasPasscodeSet false \
  Version 2.0

write_plist_xml "$B1/Info.plist" \
  "Device Name" "Clint iPhone" \
  "Display Name" "Clint iPhone" \
  "Product Version" "17.5.1" \
  "Build Version" "21F90"

write_plist_xml "$B1/Status.plist" \
  "Date" "2025-07-20T12:30:00Z" \
  "SnapshotState" "finished"

mk_sqlite "$B1/Manifest.db"

# Common artifact-like paths
mkdir -p "$B1/Library/SMS" "$B1/Library/Preferences" "$B1/Library/Caches/locationd" "$B1/Library/Health"
mk_sqlite "$B1/Library/SMS/sms.db"
mk_sqlite "$B1/Library/Health/healthdb.sqlite"

write_plist_xml "$B1/Library/Preferences/com.apple.MobileSMS.plist" \
  "UnreadCount" 0 \
  "ShowSubjectField" true

# Location cache placeholder DBs
mk_sqlite "$B1/Library/Caches/locationd/Cache.sqlite"
echo "WALTEST" > "$B1/Library/Caches/locationd/Cache.sqlite-wal"

# 2) Encrypted backup folder (no decrypted mirror)
UUID2="00008110-00ABCDEF1234002E"
B2="$TARGET/$UUID2"
mkdir -p "$B2"

write_plist_xml "$B2/Manifest.plist" \
  IsEncrypted true \
  WasPasscodeSet true \
  Version 2.0

write_plist_xml "$B2/Info.plist" \
  "Device Name" "Partner iPhone" \
  "Product Version" "18.0"

mk_sqlite "$B2/Manifest.db"

# 3) Encrypted backup that already has a __decrypted mirror to test the decoded path
UUID3="00008101-00DEADBEEFCAFE01"
B3="$TARGET/$UUID3"
mkdir -p "$B3"
write_plist_xml "$B3/Manifest.plist" IsEncrypted true WasPasscodeSet true Version 2.0
mk_sqlite "$B3/Manifest.db"
# Decrypted mirror
B3D="${B3}__decrypted"
mkdir -p "$B3D/Library/SMS" "$B3D/Library/Preferences"
write_plist_xml "$B3D/Manifest.plist" IsEncrypted false WasPasscodeSet true Version 2.0
mk_sqlite "$B3D/Library/SMS/sms.db"
write_plist_xml "$B3D/Library/Preferences/com.apple.cellularusage.plist" "CycleStart" "2025-06-01"

# 4) Non-UUID directory to ensure the app still lists directories
B4="$TARGET/misc_backup_like"
mkdir -p "$B4"
write_plist_xml "$B4/Manifest.plist" IsEncrypted false Version 1.0
mk_sqlite "$B4/Manifest.db"

# 5) Loose files at target_ root
mk_sqlite "$TARGET/Manifest.db"
write_plist_xml "$TARGET/index.plist" "IndexState" "ok"
echo "RANDOMWALDATA" > "$TARGET/sms.db.wal"
# Corrupted plist to test failure path
echo -e '\x00\xFF\x00not-a-plist' > "$TARGET/corrupted.plist"
# Empty sqlite file to test robust handling
: > "$TARGET/empty.sqlite"

# 6) Odd filenames and nested media to test inventory counters
mkdir -p "$B1/DCIM/100APPLE" "$B1/Media"
: > "$B1/DCIM/100APPLE/IMG_0001.HEIC"
: > "$B1/DCIM/100APPLE/IMG_0002.JPG"
: > "$B1/Media/VID_0001.MP4"
: > "$B1/Weird Name (1)/[stränge]file.plist"

# 7) Permission edge case (if on Unix; make a file unreadable)
UNREAD="$B1/Library/Preferences/private_unreadable.plist"
write_plist_xml "$UNREAD" "foo" "bar" || true
chmod 000 "$UNREAD" || true

echo "Test fixtures created under $TARGET"
find "$TARGET" -maxdepth 2 -mindepth 1 -type d -printf "[DIR] %p\n" -o -type f -printf "[FILE] %p\n" | head -n 80