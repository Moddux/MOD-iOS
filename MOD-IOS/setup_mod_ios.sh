#!/usr/bin/env bash
set -euo pipefail

# 1. Directory scaffold
mkdir -p ~/MOD-IOS/{backups,cli,engine,modules,tests/test_media_case,reports,gps_map,config,vscode-extension/src,vscode-extension/media,vscode-extension/.vscode,.github/workflows}

touch ~/MOD-IOS/gps_map/.gitkeep
touch ~/MOD-IOS/reports/.gitkeep
touch ~/MOD-IOS/tests/test_media_case/sample.jpg
touch ~/MOD-IOS/tests/test_media_case/sample.mp4

cat <<'EOF' > ~/MOD-IOS/BUILD.md
# BUILD.md

## Purpose
This document provides instructions for setting up the MOD-IOS environment, including installing dependencies and building the Docker container.

---

### Prerequisites
- git
- docker
- docker-compose

---

### Dependency Installation
Run:
```bash
chmod +x install_deps.sh
sudo ./install_deps.sh
```

---

### Docker Build
```bash
docker build -t mod-ios:latest .
```

---

### Docker-Compose
1. Create backups directory:
   ```bash
   mkdir -p ./backups
   ```
2. Run:
   ```bash
   docker-compose up -d
   ```
3. Enter container:
   ```bash
   docker-compose exec mod-ios bash
   ```
EOF

cat <<'EOF' > ~/MOD-IOS/USAGE.md
# USAGE.md

## Purpose
Official CLI reference for cli/meta-ios.sh.

---

## Command Syntax
```bash
./cli/meta-ios.sh --input <path_to_backup> [--module <module_name>]
```

## Flags
- `--input <path>` Required: path to the iOS backup directory.
- `--module <name>` Optional: run only that module.
- `-h, --help` Show help.

---

## Examples

1. Run all modules:
   ```bash
   ./cli/meta-ios.sh --input /data/ios_backup_xyz
   ```

2. Run only exif_audit:
   ```bash
   ./cli/meta-ios.sh --input /data/ios_backup_xyz --module exif_audit
   ```
EOF

cat <<'EOF' > ~/MOD-IOS/README.md
# MOD-IOS: Mobile Off-Device Investigation Suite for iOS

## What is MOD-IOS?
An automated, modular forensic toolkit wrapping industry-standard tools for iOS backups.

## Features
- Automated workflow
- Plugin architecture
- Docker-containerized
- Modular extraction: EXIF, media, carving, timelines
- Structured, timestamped outputs

## Quickstart
```bash
git clone <repo_url> && cd MOD-IOS
cp -r /path/to/ios_backup ./backups/
docker-compose up --build -d
docker-compose exec mod-ios ./cli/meta-ios.sh --input /data/ios_backup
```

## Layout
```
MOD-IOS/
├── cli/           # meta-ios.sh
├── modules/       # extraction scripts
├── engine/        # Python parser
├── reports/       # outputs
├── tests/         # smoke tests & sample media
├── gps_map/       # map HTML
├── .github/       # CI workflows
├── Dockerfile
├── docker-compose.yml
├── install_deps.sh
├── BUILD.md
├── USAGE.md
├── ROADMAP.md
└── README.md
```
EOF

#!/usr/bin/env bash
set -euo pipefail

# Create directory scaffold
mkdir -p ~/MOD-IOS/{backups,cli,engine,modules,tests/test_media_case,reports,gps_map,.github/workflows,config}

# Placeholders for version control
: > ~/MOD-IOS/gps_map/.gitkeep
: > ~/MOD-IOS/reports/.gitkeep
: > ~/MOD-IOS/tests/test_media_case/sample.jpg
: > ~/MOD-IOS/tests/test_media_case/sample.mp4

# BUILD.md
cat <<'EOF' > ~/MOD-IOS/BUILD.md
# BUILD.md

## Purpose
This document provides instructions for setting up the MOD-IOS environment, including installing dependencies and building the Docker container.

---

### Prerequisites
- git
- docker
- docker-compose

---

### Dependency Installation
Run:
```bash
chmod +x install_deps.sh
sudo ./install_deps.sh
```

---

### Docker Build
```bash
docker build -t mod-ios:latest .
```

---

### Docker-Compose
1. Create backups directory:
   ```bash
   mkdir -p ./backups
   ```
2. Run:
   ```bash
   docker-compose up -d
   ```
3. Enter container:
   ```bash
   docker-compose exec mod-ios bash
   ```
EOF

# USAGE.md
cat <<'EOF' > ~/MOD-IOS/USAGE.md
# USAGE.md

## Purpose
Official CLI reference for cli/meta-ios.sh.

---

## Command Syntax
```bash
./cli/meta-ios.sh --input <path_to_backup> [--module <module_name>]
```

## Flags
- `--input <path>`   Required: path to the iOS backup directory.
- `--module <name>`  Optional: run only that module.
- `-h, --help`       Show help.

---

## Examples

1. Run all modules:
   ```bash
   ./cli/meta-ios.sh --input /data/ios_backup_xyz
   ```

2. Run only exif_audit:
   ```bash
   ./cli/meta-ios.sh --input /data/ios_backup_xyz --module exif_audit
   ```
EOF

# README.md
cat <<'EOF' > ~/MOD-IOS/README.md
# MOD-IOS: Mobile Off-Device Investigation Suite for iOS

## What is MOD-IOS?
An automated, modular forensic toolkit wrapping industry-standard tools for iOS backups.

## Features
- Automated workflow
- Plugin architecture
- Docker-containerized
- Modular extraction: EXIF, media, carving, timelines
- Structured, timestamped outputs

## Quickstart
```bash
git clone <repo_url> && cd MOD-IOS
cp -r /path/to/ios_backup ./backups/
docker-compose up --build -d
docker-compose exec mod-ios ./cli/meta-ios.sh --input /data/ios_backup
```

## Layout
```
MOD-IOS/
├── cli/           # meta-ios.sh
├── modules/       # extraction scripts
├── engine/        # Python parser
├── reports/       # outputs
├── tests/         # smoke tests & sample media
├── gps_map/       # map HTML
├── .github/       # CI workflows
├── Dockerfile
├── docker-compose.yml
├── install_deps.sh
├── BUILD.md
├── USAGE.md
├── ROADMAP.md
└── README.md
```
EOF

# ROADMAP.md
cat <<'EOF' > ~/MOD-IOS/ROADMAP.md
# ROADMAP.md

## Phase 1: Core (✓)
- [x] Scaffold & Docker
- [x] meta-ios.sh entrypoint
- [x] EXIF, FFprobe, MediaInfo, Foremost, FLS

## Phase 2: Parsing & Storage
- [ ] meta_parser.py ingestion
- [ ] SQLite schema

## Phase 3: Reporting & GUI
- [ ] Streamlit dashboard
- [ ] HTML/PDF report
- [ ] GPS map

## Phase 4: Advanced Modules
- [ ] SMS & contacts DB analysis
- [ ] Plist parsing
- [ ] Malware scan

## Phase 5: Polishing
- [ ] Error handling
- [ ] Central config
- [ ] Publish Docker image
EOF

# install_deps.sh
cat <<'EOF' > ~/MOD-IOS/install_deps.sh
#!/usr/bin/env bash
#
# Installs all system and Python dependencies for MOD-IOS.
set -euo pipefail

if [[ "$EUID" -ne 0 ]]; then
  echo "Run as root or via sudo."
  exit 1
fi

apt-get update
apt-get install -y \
  git \
  docker.io \
  docker-compose \
  exiftool \
  ffmpeg \
  mediainfo \
  gpac \
  bulk-extractor \
  foremost \
  sleuthkit \
  shellcheck \
  python3-pip

pip3 install --no-cache-dir pandas streamlit

apt-get clean
rm -rf /var/lib/apt/lists/*
echo "Dependencies installed."
EOF
chmod +x ~/MOD-IOS/install_deps.sh

# Dockerfile
cat <<'EOF' > ~/MOD-IOS/Dockerfile
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

COPY install_deps.sh .
RUN chmod +x install_deps.sh && ./install_deps.sh

COPY . .

RUN find cli/ modules/ tests/ -name "*.sh" -exec chmod +x {} \;
RUN chmod +x engine/meta_parser.py

ENTRYPOINT ["./cli/meta-ios.sh"]
EOF

# docker-compose.yml
cat <<'EOF' > ~/MOD-IOS/docker-compose.yml
version: '3.8'
services:
  mod-ios:
    container_name: mod-ios
    build: .
    volumes:
      - ./backups:/data:ro
      - ./reports:/app/reports
    tty: true
    stdin_open: true
EOF

# Append to setup_mod_ios.sh: All extraction modules, engine scripts, test scripts, configs, and .gitignore/.dockerignore.

cat <<'EOF' > ~/MOD-IOS/modules/identity_fingerprint.sh
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
EOF
chmod +x ~/MOD-IOS/modules/identity_fingerprint.sh

cat <<'EOF' > ~/MOD-IOS/modules/exif_audit.sh
#!/usr/bin/env bash
set -euo pipefail
INPUT=$1 ; SESSION=$2 ; BACKID=$3
OUT=$SESSION/exif_audit
mkdir -p "$OUT"
JSON=$OUT/${BACKID}_exif.json
exiftool -j -r "$INPUT" > "$JSON"
EOF
chmod +x ~/MOD-IOS/modules/exif_audit.sh

cat <<'EOF' > ~/MOD-IOS/modules/ffprobe.sh
#!/usr/bin/env bash
set -euo pipefail
INPUT=$1 ; SESSION=$2 ; BACKID=$3
OUT=$SESSION/ffprobe
mkdir -p "$OUT"
JSON=$OUT/${BACKID}_ffprobe.json
echo "[" > "$JSON"
first=true
find "$INPUT" -type f \( -iname "*.mp4" -o -iname "*.mov" \) -print0 | \
  while IFS= read -r -d '' f; do
    [[ $first == true ]] && first=false || echo "," >> "$JSON"
    ffprobe -v quiet -print_format json -show_format -show_streams "$f" \
      >> "$JSON"
  done
echo "]" >> "$JSON"
EOF
chmod +x ~/MOD-IOS/modules/ffprobe.sh

cat <<'EOF' > ~/MOD-IOS/modules/mediainfo.sh
#!/usr/bin/env bash
set -euo pipefail
INPUT=$1 ; SESSION=$2 ; BACKID=$3
OUT=$SESSION/mediainfo
mkdir -p "$OUT"
find "$INPUT" -type f \( -iname "*.mp4" -o -iname "*.mov" -o -iname "*.mkv" \) -print0 | \
  while IFS= read -r -d '' f; do
    name=$(basename "$f")
    mediainfo --Output=JSON "$f" > "$OUT/${name%.*}_mediainfo.json"
  done
EOF
chmod +x ~/MOD-IOS/modules/mediainfo.sh

cat <<'EOF' > ~/MOD-IOS/modules/mp4dump.sh
#!/usr/bin/env bash
set -euo pipefail
INPUT=$1 ; SESSION=$2 ; BACKID=$3
OUT=$SESSION/mp4dump
mkdir -p "$OUT"
find "$INPUT" -type f \( -iname "*.mp4" -o -iname "*.mov" \) -print0 | \
  while IFS= read -r -d '' f; do
    bn=$(basename "$f" | tr -c 'a-zA-Z0-9._-' '_')
    mp4dump "$f" > "$OUT/${bn}_mp4dump.txt"
  done
EOF
chmod +x ~/MOD-IOS/modules/mp4dump.sh

cat <<'EOF' > ~/MOD-IOS/modules/bulk_extractor.sh
#!/usr/bin/env bash
set -euo pipefail
INPUT=$1 ; SESSION=$2 ; BACKID=$3
OUT=$SESSION/bulk_extractor
bulk_extractor -r "$INPUT" -o "$OUT"
EOF
chmod +x ~/MOD-IOS/modules/bulk_extractor.sh

cat <<'EOF' > ~/MOD-IOS/modules/file_carve.sh
#!/usr/bin/env bash
set -euo pipefail
INPUT=$1 ; SESSION=$2 ; BACKID=$3
OUT=$SESSION/file_carve
mkdir -p "$OUT"
foremost -i "$INPUT" -o "$OUT"
EOF
chmod +x ~/MOD-IOS/modules/file_carve.sh

cat <<'EOF' > ~/MOD-IOS/modules/fs_timeline.sh
#!/usr/bin/env bash
set -euo pipefail
INPUT=$1 ; SESSION=$2 ; BACKID=$3
OUT=$SESSION/fs_timeline
mkdir -p "$OUT"
BODY=$OUT/${BACKID}.body
CSV=$OUT/${BACKID}_timeline.csv
fls -r -m / "$INPUT" > "$BODY"
mactime -b "$BODY" -d > "$CSV"
EOF
chmod +x ~/MOD-IOS/modules/fs_timeline.sh

cat <<'EOF' > ~/MOD-IOS/modules/gps_map.sh
#!/usr/bin/env bash
set -euo pipefail
INPUT=$1; SESSION=$2; BACKID=$3
CSV=$(find "$SESSION/fs_timeline" -name "*_timeline.csv" | head -n1)
OUT=$SESSION/gps_map
mkdir -p "$OUT"
HTML=$OUT/${BACKID}_gps_map.html
python3 - <<PY
import pandas as pd, folium
from pathlib import Path
csv = Path("$CSV")
df = pd.read_csv(csv)
m = folium.Map(location=[0,0], zoom_start=2)
m.save("$HTML")
PY
echo "Map generated at $HTML"
EOF
chmod +x ~/MOD-IOS/modules/gps_map.sh

cat <<'EOF' > ~/MOD-IOS/modules/manifest_parser.sh
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
EOF
chmod +x ~/MOD-IOS/modules/manifest_parser.sh

cat <<'EOF' > ~/MOD-IOS/modules/plist_parser.sh
#!/usr/bin/env bash
set -euo pipefail
INPUT=$1; SESSION=$2; BACKID=$3
OUT=$SESSION/plist
mkdir -p "$OUT"
find "$INPUT" -type f -iname "*.plist" -print0 | \
  while IFS= read -r -d '' file; do
    base=$(basename "$file" .plist)
    plutil -convert json -o "$OUT/${base}.json" "$file"
  done
EOF
chmod +x ~/MOD-IOS/modules/plist_parser.sh

cat <<'EOF' > ~/MOD-IOS/modules/image_tamper.sh
#!/usr/bin/env bash
set -euo pipefail
INPUT=$1; SESSION=$2; BACKID=$3
OUT=$SESSION/tamper
mkdir -p "$OUT"
find "$INPUT" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -print0 | \
  while IFS= read -r -d '' file; do
    fname=$(basename "$file")
    exiftool -d "%Y-%m-%d %H:%M:%S" -a -G1 -json "$file" > "$OUT/${fname}.exif.json"
    identify -verbose "$file" | tee "$OUT/${fname}.identify.txt"
  done
EOF
chmod +x ~/MOD-IOS/modules/image_tamper.sh

cat <<'EOF' > ~/MOD-IOS/modules/misp_export.sh
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
EOF
chmod +x ~/MOD-IOS/modules/misp_export.sh

cat <<'EOF' > ~/MOD-IOS/modules/anomaly_detector.sh
#!/usr/bin/env bash
set -euo pipefail
INPUT=$1; SESSION=$2; BACKID=$3
OUT=$SESSION/anomalies
mkdir -p "$OUT"
python3 - <<PY
import pandas as pd, sqlite3, sys
from pathlib import Path
db = Path("$SESSION/session.sqlite")
if not db.exists():
    sys.exit(0)
conn = sqlite3.connect(str(db))
df = pd.read_sql("SELECT * FROM fs_timeline", conn)
if 'mtime' in df.columns and 'crtime' in df.columns:
    anomalies = df[df['mtime'] < df['crtime']]
    anomalies.to_csv("$OUT/${BACKID}_time_anomalies.csv", index=False)
conn.close()
PY
EOF
chmod +x ~/MOD-IOS/modules/anomaly_detector.sh

cat <<'EOF' > ~/MOD-IOS/engine/meta_parser.py
#!/usr/bin/env python3
import argparse, sqlite3, pandas as pd, json, sys
from pathlib import Path
def main():
    p=argparse.ArgumentParser();
    p.add_argument('--session',required=True); args=p.parse_args()
    sess=Path(args.session); db=sess/'session.sqlite'
    conn=sqlite3.connect(db)
    # exif
    for f in sess.glob('exif_audit/*.json'):
        df=pd.read_json(f); df.to_sql('exif',conn,if_exists='append',index=False)
    # ffprobe
    for f in sess.glob('ffprobe/*.json'):
        df=pd.read_json(f); df.to_sql('ffprobe',conn,if_exists='append',index=False)
    # timeline
    for f in sess.glob('fs_timeline/*_timeline.csv'):
        df=pd.read_csv(f); df.to_sql('timeline',conn,if_exists='append',index=False)
    conn.close()
if __name__=='__main__':
    main()
EOF
chmod +x ~/MOD-IOS/engine/meta_parser.py

cat <<'EOF' > ~/MOD-IOS/engine/anomaly_detector.py
#!/usr/bin/env python3
import argparse, sqlite3, pandas as pd
from pathlib import Path
def detect(session: Path, out: Path):
    db = session / 'session.sqlite'
    if not db.exists(): return
    conn = sqlite3.connect(str(db))
    df = pd.read_sql("SELECT * FROM fs_timeline", conn)
    if 'mtime' in df.columns and 'crtime' in df.columns:
        ann = df[df['mtime'] < df['crtime']]
        out.mkdir(parents=True, exist_ok=True)
        ann.to_csv(out / 'time_anomalies.csv', index=False)
    conn.close()
def main():
    p = argparse.ArgumentParser()
    p.add_argument('--session', required=True)
    args = p.parse_args()
    session = Path(args.session)
    detect(session, session / 'anomalies')
if __name__ == '__main__':
    main()
EOF
chmod +x ~/MOD-IOS/engine/anomaly_detector.py

cat <<'EOF' > ~/MOD-IOS/engine/dashboard.py
#!/usr/bin/env python3
import streamlit as st
import sqlite3, pandas as pd
from pathlib import Path
st.set_page_config(page_title="MOD-IOS Dashboard", layout="wide")
st.title("MOD-IOS Forensic Dashboard")
base = Path(st.text_input("Session directory", "./reports"))
if base.exists():
    db = list(base.glob("*/session.sqlite"))
    if db:
        conn = sqlite3.connect(str(db[0]))
        st.sidebar.subheader("Tables")
        tables = pd.read_sql("SELECT name FROM sqlite_master WHERE type='table';", conn)
        table = st.sidebar.selectbox("Table", tables['name'])
        df = pd.read_sql(f"SELECT * FROM {table} LIMIT 100;", conn)
        st.write(df)
        conn.close()
    else:
        st.warning("No session.sqlite found.")
else:
    st.error("Directory not found.")
EOF
chmod +x ~/MOD-IOS/engine/dashboard.py

cat <<'EOF' > ~/MOD-IOS/engine/load_config.py
#!/usr/bin/env python3
import yaml, sys
from pathlib import Path
cfg = yaml.safe_load(Path(__file__).parent.parent / 'config' / 'config.yaml')
modules = cfg.get('default', {}).get('modules', [])
for m in modules:
    print(m)
EOF
chmod +x ~/MOD-IOS/engine/load_config.py

cat <<'EOF' > ~/MOD-IOS/config/config.yaml
default:
  modules:
    - identity_fingerprint
    - exif_audit
    - ffprobe
    - mediainfo
    - mp4dump
    - bulk_extractor
    - file_carve
    - fs_timeline
    - plist_parser
    - image_tamper
    - gps_map
    - manifest_parser
    - misp_export
  concurrency: 4
  misp:
    url: "https://misp.example.com"
    apikey: "YOUR_API_KEY"
EOF

cat <<'EOF' > ~/MOD-IOS/engine/plugin_registry.json
{
  "modules": [
    {"name": "identity_fingerprint", "version": "1.0.0"},
    {"name": "exif_audit",       "version": "1.0.0"},
    {"name": "ffprobe",          "version": "1.0.0"},
    {"name": "mediainfo",        "version": "1.0.0"},
    {"name": "mp4dump",          "version": "1.0.0"},
    {"name": "bulk_extractor",   "version": "1.0.0"},
    {"name": "file_carve",       "version": "1.0.0"},
    {"name": "fs_timeline",      "version": "1.0.0"},
    {"name": "plist_parser",     "version": "1.0.0"},
    {"name": "image_tamper",     "version": "1.0.0"},
    {"name": "gps_map",          "version": "1.0.0"},
    {"name": "manifest_parser",  "version": "1.0.0"},
    {"name": "misp_export",      "version": "1.0.0"},
    {"name": "anomaly_detector","version": "1.0.0"}
  ]
}
EOF

# Continue appending to setup_mod_ios.sh with test scripts and ignores

cat <<'EOF' > ~/MOD-IOS/tests/test_meta_case.sh
#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
CLI=$ROOT/cli/meta-ios.sh
DATA=$ROOT/tests/test_media_case
# run
OUT=$(bash "$CLI" --input "$DATA")
SESSION=$(echo "$OUT" | awk -F' at ' '{print $2}')
# assertions
[[ -f "$SESSION/audit.log" ]] || exit 1
[[ -s "$SESSION/fs_timeline/*_timeline.csv" ]] || exit 1
[[ -s "$SESSION/exif_audit/*.json" ]] || exit 1
echo "PASS"
EOF
chmod +x ~/MOD-IOS/tests/test_meta_case.sh

touch ~/MOD-IOS/tests/test_media_case/sample.jpg
touch ~/MOD-IOS/tests/test_media_case/sample.mp4

touch ~/MOD-IOS/reports/.gitkeep
touch ~/MOD-IOS/gps_map/.gitkeep

cat <<'EOF' > ~/MOD-IOS/tests/test_plist_parser.sh
#!/usr/bin/env bash
set -euo pipefail
SESSION=$(bash cli/meta-ios.sh --input tests/test_media_case)
if [[ -d "$SESSION/plist" && -n $(ls "$SESSION/plist") ]]; then
  echo "PASS: plist_parser"
else
  echo "FAIL: plist_parser" >&2
  exit 1
fi
EOF
chmod +x ~/MOD-IOS/tests/test_plist_parser.sh

cat <<'EOF' > ~/MOD-IOS/tests/test_image_tamper.sh
#!/usr/bin/env bash
set -euo pipefail
SESSION=$(bash cli/meta-ios.sh --input tests/test_media_case)
if [[ -d "$SESSION/tamper" && -f "$SESSION/tamper/sample.jpg.exif.json" ]]; then
  echo "PASS: image_tamper"
else
  echo "FAIL: image_tamper" >&2
  exit 1
fi
EOF
chmod +x ~/MOD-IOS/tests/test_image_tamper.sh

cat <<'EOF' > ~/MOD-IOS/tests/test_anomaly_detector.sh
#!/usr/bin/env bash
set -euo pipefail
SESSION=$(bash cli/meta-ios.sh --input tests/test_media_case)
BACKID=$(basename tests/test_media_case)
if [[ -f "$SESSION/anomalies/${BACKID}_time_anomalies.csv" ]]; then
  echo "PASS: anomaly_detector"
else
  echo "SKIP: anomaly_detector (no anomalies detected or no timeline data)" >&2
fi
EOF
chmod +x ~/MOD-IOS/tests/test_anomaly_detector.sh

cat <<'EOF' > ~/MOD-IOS/tests/test_config.sh
#!/usr/bin/env bash
set -euo pipefail
MODS="$(python3 engine/load_config.py)"
[[ "$MODS" == *"exif_audit"* ]] || { echo "Config missing exif_audit"; exit 1; }
echo "PASS: config modules loaded"
EOF
chmod +x ~/MOD-IOS/tests/test_config.sh

cat <<'EOF' > ~/MOD-IOS/.gitignore
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class
# SQLite DB
*.sqlite
# Logs & outputs
reports/
backups/
*.log
# Environment files
.env
EOF

cat <<'EOF' > ~/MOD-IOS/.dockerignore
.git
__pycache__
*.pyc
tests/
.github/
.gitignore
docker-compose.yml
install_deps.sh
BUILD.md
USAGE.md
ROADMAP.md
EOF
# Tests, versioning, and ignore files for MOD-IOS

cat <<'EOF' > ~/MOD-IOS/tests/test_meta_case.sh
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
EOF
chmod +x ~/MOD-IOS/tests/test_meta_case.sh

cat <<'EOF' > ~/MOD-IOS/tests/test_plist_parser.sh
#!/usr/bin/env bash
set -euo pipefail
SESSION=$(bash cli/meta-ios.sh --input tests/test_media_case)
if [[ -d "$SESSION/plist" && -n $(ls "$SESSION/plist") ]]; then
  echo "PASS: plist_parser"
else
  echo "FAIL: plist_parser" >&2
  exit 1
fi
EOF
chmod +x ~/MOD-IOS/tests/test_plist_parser.sh

cat <<'EOF' > ~/MOD-IOS/tests/test_image_tamper.sh
#!/usr/bin/env bash
set -euo pipefail
SESSION=$(bash cli/meta-ios.sh --input tests/test_media_case)
if [[ -d "$SESSION/tamper" && -f "$SESSION/tamper/sample.jpg.exif.json" ]]; then
  echo "PASS: image_tamper"
else
  echo "FAIL: image_tamper" >&2
  exit 1
fi
EOF
chmod +x ~/MOD-IOS/tests/test_image_tamper.sh

cat <<'EOF' > ~/MOD-IOS/tests/test_anomaly_detector.sh
#!/usr/bin/env bash
set -euo pipefail
SESSION=$(bash cli/meta-ios.sh --input tests/test_media_case)
BACKID=$(basename tests/test_media_case)
if [[ -f "$SESSION/anomalies/${BACKID}_time_anomalies.csv" ]]; then
  echo "PASS: anomaly_detector"
else
  echo "SKIP: anomaly_detector (no anomalies detected or no timeline data)" >&2
fi
EOF
chmod +x ~/MOD-IOS/tests/test_anomaly_detector.sh

cat <<'EOF' > ~/MOD-IOS/tests/test_config.sh
#!/usr/bin/env bash
set -euo pipefail
MODS="$(python3 engine/load_config.py)"
[[ "$MODS" == *"exif_audit"* ]] || { echo "Config missing exif_audit"; exit 1; }
echo "PASS: config modules loaded"
EOF
chmod +x ~/MOD-IOS/tests/test_config.sh

touch ~/MOD-IOS/reports/.gitkeep

# MOD-IOS ignore files and VSCode scaffold

cat <<'EOF' > ~/MOD-IOS/.gitignore
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# SQLite DB
*.sqlite

# Logs & outputs
reports/
backups/
*.log

# Environment files
.env
EOF

cat <<'EOF' > ~/MOD-IOS/.dockerignore
.git
__pycache__
*.pyc
tests/
.github/
.gitignore
docker-compose.yml
install_deps.sh
BUILD.md
USAGE.md
ROADMAP.md
EOF

# VSCode extension scaffold (optional, for timeline visualizer)
mkdir -p ~/MOD-IOS/vscode-extension/{src,media,.vscode}

touch ~/MOD-IOS/vscode-extension/tsconfig.json

touch ~/MOD-IOS/vscode-extension/package.json

touch ~/MOD-IOS/vscode-extension/src/extension.ts

touch ~/MOD-IOS/vscode-extension/.vscode/launch.json

touch ~/MOD-IOS/vscode-extension/.vscode/tasks.json
# Ignore files for MOD-IOS

cat <<'EOF' > ~/MOD-IOS/.gitignore
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# SQLite DB
*.sqlite

# Logs & outputs
reports/
backups/
*.log

# Environment files
.env
EOF

cat <<'EOF' > ~/MOD-IOS/.dockerignore
.git
__pycache__
*.pyc
tests/
.github/
.gitignore
docker-compose.yml
install_deps.sh
BUILD.md
USAGE.md
ROADMAP.md
EOF

# VSCode extension scaffolding (optional, skip if not used)

mkdir -p ~/MOD-IOS/vscode-extension/{src,media,.vscode}

cat <<'EOF' > ~/MOD-IOS/vscode-extension/package.json
{
  "name": "mod-ios-forensic-visualizer",
  "displayName": "MOD-IOS Forensic Visualizer",
  "publisher": "moddux",
  "version": "0.1.0",
  "engines": {
    "vscode": "^1.60.0"
  },
  "categories": ["Other"],
  "activationEvents": ["onCommand:extension.showTimeline"],
  "main": "./src/extension.js",
  "contributes": {
    "commands": [{
      "command": "extension.showTimeline",
      "title": "Show Forensic Timeline"
    }]
  },
  "scripts": {
    "vscode:prepublish": "npm run compile",
    "compile": "tsc -p ./",
    "watch": "tsc -watch -p ./"
  },
  "devDependencies": {
    "typescript": "^4.5.2",
    "vscode": "^1.1.37"
  }
}
EOF

cat <<'EOF' > ~/MOD-IOS/vscode-extension/tsconfig.json
{
  "compilerOptions": {
    "module": "commonjs",
    "target": "es6",
    "outDir": "src",
    "rootDir": "src",
    "sourceMap": true,
    "strict": true
  },
  "exclude": ["node_modules", ".vscode-test"]
}
EOF

cat <<'EOF' > ~/MOD-IOS/vscode-extension/src/extension.ts
import * as vscode from 'vscode';
import * as path from 'path';
import * as fs from 'fs';

export function activate(context: vscode.ExtensionContext) {
  const disposable = vscode.commands.registerCommand('extension.showTimeline', () => {
    const options: vscode.OpenDialogOptions = {
      canSelectFiles: false,
      canSelectFolders: true,
      openLabel: 'Select Session Folder'
    };
    vscode.window.showOpenDialog(options).then(folder => {
      if (folder && folder[0]) {
        const session = folder[0].fsPath;
        const dbPath = path.join(session, 'session.sqlite');
        if (fs.existsSync(dbPath)) {
          vscode.window.showInformationMessage('Session DB found: ' + dbPath);
          // Further implementation: launch webview with timeline
        } else {
          vscode.window.showErrorMessage('session.sqlite not found in selected folder');
        }
      }
    });
  });
  context.subscriptions.push(disposable);
}
export function deactivate() {}
EOF

cat <<'EOF' > ~/MOD-IOS/vscode-extension/.vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Run Extension",
      "type": "extensionHost",
      "request": "launch",
      "runtimeExecutable": "${execPath}",
      "args": ["--extensionDevelopmentPath=${workspaceFolder}"],
      "outFiles": ["${workspaceFolder}/out/**/*.js"],
      "preLaunchTask": "npm: compile"
    }
  ]
}
EOF

cat <<'EOF' > ~/MOD-IOS/vscode-extension/.vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "npm: compile",
      "type": "shell",
      "command": "npm run compile",
      "group": {
        "kind": "build",
        "isDefault": true
      },
      "problemMatcher": ["$tsc"]
    }
  ]
}
EOF

# Additional workflows and config scaffolding

cat <<'EOF' > ~/MOD-IOS/.github/workflows/extension-ci.yml
name: Extension CI

on:
  push:
    paths:
      - 'vscode-extension/**'
  pull_request:
    paths:
      - 'vscode-extension/**'

jobs:
  build:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: vscode-extension
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '16'
      - name: Install deps
        run: npm install
      - name: Compile extension
        run: npm run compile
      - name: VSCE package
        run: |
          npm install -g vsce
          vsce package
EOF

cat <<'EOF' > ~/MOD-IOS/config/config.yaml
default:
  modules:
    - identity_fingerprint
    - exif_audit
    - ffprobe
    - mediainfo
    - mp4dump
    - bulk_extractor
    - file_carve
    - fs_timeline
    - plist_parser
    - image_tamper
    - gps_map
    - manifest_parser
    - misp_export
  concurrency: 4
  misp:
    url: "https://misp.example.com"
    apikey: "YOUR_API_KEY"
EOF

cat <<'EOF' > ~/MOD-IOS/engine/plugin_registry.json
{
  "modules": [
    {"name": "identity_fingerprint", "version": "1.0.0"},
    {"name": "exif_audit",       "version": "1.0.0"},
    {"name": "ffprobe",          "version": "1.0.0"},
    {"name": "mediainfo",        "version": "1.0.0"},
    {"name": "mp4dump",          "version": "1.0.0"},
    {"name": "bulk_extractor",   "version": "1.0.0"},
    {"name": "file_carve",       "version": "1.0.0"},
    {"name": "fs_timeline",      "version": "1.0.0"},
    {"name": "plist_parser",     "version": "1.0.0"},
    {"name": "image_tamper",     "version": "1.0.0"},
    {"name": "gps_map",          "version": "1.0.0"},
    {"name": "manifest_parser",  "version": "1.0.0"},
    {"name": "misp_export",      "version": "1.0.0"},
    {"name": "anomaly_detector", "version": "1.0.0"}
  ]
}
EOF

cat <<'EOF' > ~/MOD-IOS/engine/load_config.py
#!/usr/bin/env python3
import yaml, sys
from pathlib import Path

cfg = yaml.safe_load(open(Path(__file__).parent.parent / 'config' / 'config.yaml'))
modules = cfg.get('default', {}).get('modules', [])
for m in modules:
    print(m)
EOF
chmod +x ~/MOD-IOS/engine/load_config.py

# README, .gitignore, .dockerignore, VSCode extension, misc

cat <<'EOF' > ~/MOD-IOS/README.md
# MOD-IOS: Mobile Off-Device Investigation Suite for iOS

## What is MOD-IOS?
An automated, modular forensic toolkit wrapping industry-standard tools for iOS backups.

## Features
- Automated workflow
- Plugin architecture
- Docker-containerized
- Modular extraction: EXIF, media, carving, timelines
- Structured, timestamped outputs
- Comprehensive Data Extraction: Gathers everything from media metadata and filesystem timelines to carved deleted files and Plist & image anomaly detection.

## Quickstart
```
git clone <repo_url> && cd MOD-IOS
cp -r /path/to/ios_backup ./backups/
docker-compose up --build -d
docker-compose exec mod-ios ./cli/meta-ios.sh --input /data/ios_backup
```

## Layout
```
MOD-IOS/
├── cli/           # meta-ios.sh
├── modules/       # extraction scripts
├── engine/        # Python parser
├── reports/       # outputs
├── tests/         # smoke tests & sample media
├── gps_map/       # map HTML
├── .github/       # CI workflows
├── Dockerfile
├── docker-compose.yml
├── install_deps.sh
├── BUILD.md
├── USAGE.md
├── ROADMAP.md
├── vscode-extension/    # VSCode extension scaffold for timeline visualizer
└── README.md
```
EOF

cat <<'EOF' > ~/MOD-IOS/.gitignore
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# SQLite DB
*.sqlite

# Logs & outputs
reports/
backups/
*.log

# Environment files
.env
EOF

cat <<'EOF' > ~/MOD-IOS/.dockerignore
.git
__pycache__
*.pyc
tests/
.github/
.gitignore
docker-compose.yml
install_deps.sh
BUILD.md
USAGE.md
ROADMAP.md
EOF

mkdir -p ~/MOD-IOS/vscode-extension/{src,media,.vscode}

cat <<'EOF' > ~/MOD-IOS/vscode-extension/package.json
{
  "name": "mod-ios-forensic-visualizer",
  "displayName": "MOD-IOS Forensic Visualizer",
  "publisher": "moddux",
  "version": "0.1.0",
  "engines": {
    "vscode": "^1.60.0"
  },
  "categories": ["Other"],
  "activationEvents": ["onCommand:extension.showTimeline"],
  "main": "./src/extension.js",
  "contributes": {
    "commands": [{
      "command": "extension.showTimeline",
      "title": "Show Forensic Timeline"
    }]
  },
  "scripts": {
    "vscode:prepublish": "npm run compile",
    "compile": "tsc -p ./",
    "watch": "tsc -watch -p ./"
  },
  "devDependencies": {
    "typescript": "^4.5.2",
    "vscode": "^1.1.37"
  }
}
EOF

cat <<'EOF' > ~/MOD-IOS/vscode-extension/tsconfig.json
{
  "compilerOptions": {
    "module": "commonjs",
    "target": "es6",
    "outDir": "src",
    "rootDir": "src",
    "sourceMap": true,
    "strict": true
  },
  "exclude": ["node_modules", ".vscode-test"]
}
EOF

cat <<'EOF' > ~/MOD-IOS/vscode-extension/src/extension.ts
import * as vscode from 'vscode';
import * as path from 'path';
import * as fs from 'fs';

export function activate(context: vscode.ExtensionContext) {
  const disposable = vscode.commands.registerCommand('extension.showTimeline', () => {
    const options: vscode.OpenDialogOptions = {
      canSelectFiles: false,
      canSelectFolders: true,
      openLabel: 'Select Session Folder'
    };
    vscode.window.showOpenDialog(options).then(folder => {
      if (folder && folder[0]) {
        const session = folder[0].fsPath;
        const dbPath = path.join(session, 'session.sqlite');
        if (fs.existsSync(dbPath)) {
          vscode.window.showInformationMessage('Session DB found: ' + dbPath);
          // Further implementation: launch webview with timeline
        } else {
          vscode.window.showErrorMessage('session.sqlite not found in selected folder');
        }
      }
    });
  });
  context.subscriptions.push(disposable);
}
export function deactivate() {}
EOF

cat <<'EOF' > ~/MOD-IOS/vscode-extension/.vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Run Extension",
      "type": "extensionHost",
      "request": "launch",
      "runtimeExecutable": "${execPath}",
      "args": ["--extensionDevelopmentPath=${workspaceFolder}"],
      "outFiles": ["${workspaceFolder}/out/**/*.js"],
      "preLaunchTask": "npm: compile"
    }
  ]
}
EOF

cat <<'EOF' > ~/MOD-IOS/vscode-extension/.vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "npm: compile",
      "type": "shell",
      "command": "npm run compile",
      "group": {
        "kind": "build",
        "isDefault": true
      },
      "problemMatcher": ["$tsc"]
    }
  ]
}
EOF

cat <<'EOF' > ~/MOD-IOS/.github/workflows/extension-ci.yml
name: Extension CI

on:
  push:
    paths:
      - 'vscode-extension/**'
  pull_request:
    paths:
      - 'vscode-extension/**'

jobs:
  build:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: vscode-extension
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '16'
      - name: Install deps
        run: npm install
      - name: Compile extension
        run: npm run compile
      - name: VSCE package
        run: |
          npm install -g vsce
          vsce package
EOF

cat <<'EOF' > ~/MOD-IOS/README.md
# MOD-IOS: Mobile Off-Device Investigation Suite for iOS

## What is MOD-IOS?
An automated, modular forensic toolkit wrapping industry-standard tools for iOS backups.

## Features
- Automated workflow
- Plugin architecture
- Docker-containerized
- Modular extraction: EXIF, media, carving, timelines
- Structured, timestamped outputs
- Plist & image anomaly detection

## Quickstart
```bash
git clone <repo_url> && cd MOD-IOS
cp -r /path/to/ios_backup ./backups/
docker-compose up --build -d
docker-compose exec mod-ios ./cli/meta-ios.sh --input /data/ios_backup
```

## Layout
```
MOD-IOS/
├── cli/           # meta-ios.sh
├── modules/       # extraction scripts
├── engine/        # Python parser
├── reports/       # outputs
├── tests/         # smoke tests & sample media
├── gps_map/       # map HTML
├── .github/       # CI workflows
├── vscode-extension/ # VSCode extension for timeline visualizer
├── Dockerfile
├── docker-compose.yml
├── install_deps.sh
├── BUILD.md
├── USAGE.md
├── ROADMAP.md
└── README.md
```
EOF

cat <<'EOF' > ~/MOD-IOS/.gitignore
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# SQLite DB
*.sqlite

# Logs & outputs
reports/
backups/
*.log

# Environment files
.env
EOF

cat <<'EOF' > ~/MOD-IOS/.dockerignore
.git
__pycache__
*.pyc
tests/
.github/
.gitignore
docker-compose.yml
install_deps.sh
BUILD.md
USAGE.md
ROADMAP.md
EOF

mkdir -p ~/MOD-IOS/vscode-extension/{src,media,.vscode}

cat <<'EOF' > ~/MOD-IOS/vscode-extension/package.json
{
  "name": "mod-ios-forensic-visualizer",
  "displayName": "MOD-IOS Forensic Visualizer",
  "publisher": "moddux",
  "version": "0.1.0",
  "engines": {
    "vscode": "^1.60.0"
  },
  "categories": ["Other"],
  "activationEvents": ["onCommand:extension.showTimeline"],
  "main": "./src/extension.js",
  "contributes": {
    "commands": [{
      "command": "extension.showTimeline",
      "title": "Show Forensic Timeline"
    }]
  },
  "scripts": {
    "vscode:prepublish": "npm run compile",
    "compile": "tsc -p ./",
    "watch": "tsc -watch -p ./"
  },
  "devDependencies": {
    "typescript": "^4.5.2",
    "vscode": "^1.1.37"
  }
}
EOF

cat <<'EOF' > ~/MOD-IOS/vscode-extension/tsconfig.json
{
  "compilerOptions": {
    "module": "commonjs",
    "target": "es6",
    "outDir": "src",
    "rootDir": "src",
    "sourceMap": true,
    "strict": true
  },
  "exclude": ["node_modules", ".vscode-test"]
}
EOF

cat <<'EOF' > ~/MOD-IOS/vscode-extension/.vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Run Extension",
      "type": "extensionHost",
      "request": "launch",
      "runtimeExecutable": "${execPath}",
      "args": ["--extensionDevelopmentPath=${workspaceFolder}"],
      "outFiles": ["${workspaceFolder}/out/**/*.js"],
      "preLaunchTask": "npm: compile"
    }
  ]
}
EOF

cat <<'EOF' > ~/MOD-IOS/vscode-extension/.vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "npm: compile",
      "type": "shell",
      "command": "npm run compile",
      "group": {
        "kind": "build",
        "isDefault": true
      },
      "problemMatcher": ["$tsc"]
    }
  ]
}
EOF

cat <<'EOF' > ~/MOD-IOS/.github/workflows/extension-ci.yml
name: Extension CI

on:
  push:
    paths:
      - 'vscode-extension/**'
  pull_request:
    paths:
      - 'vscode-extension/**'

jobs:
  build:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: vscode-extension
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '16'
      - name: Install deps
        run: npm install
      - name: Compile extension
        run: npm run compile
      - name: VSCE package
        run: |
          npm install -g vsce
          vsce package
EOF
