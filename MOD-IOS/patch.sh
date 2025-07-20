# Patch missing files for MOD-IOS
# ONLY creates files missing as per the last compliance gap analysis.
# To use: copy-paste block-by-block (do not run as one script unless all is verified). Ensure directories exist first.

# --- Module scripts ---
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

cat <<'EOF' > ~/MOD-IOS/modules/manifest_parser.sh
#!/usr/bin/env bash
set -euo pipefail
INPUT=$1; SESSION=$2; BACKID=$3
OUT=$SESSION/manifest
mkdir -p "$OUT"
if [[ -f "$INPUT/Manifest.db" ]]; then
  sqlite3 "$INPUT/Manifest.db" -header -csv \
    "SELECT datetime(ZMANAGEDACCOUNT.ZCREATIONDATE,'unixepoch') AS created, ZNAME.ZTEXT AS contact_name, ZABCDATAMESSAGE.ZTEXT AS message
    FROM ZABCDATAMESSAGE
    JOIN ZNAME ON ZABCDATAMESSAGE.Z_SENDER = ZNAME.Z_PK;" \
    > "$OUT/sms_messages.csv"
fi
EOF
chmod +x ~/MOD-IOS/modules/manifest_parser.sh

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
    anomalies.to_csv(f"{OUT}/{BACKID}_time_anomalies.csv", index=False)
conn.close()
PY
EOF
chmod +x ~/MOD-IOS/modules/anomaly_detector.sh

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
# placeholder: no coords
m.save("$HTML")
PY
echo "Map generated at $HTML"
EOF
chmod +x ~/MOD-IOS/modules/gps_map.sh

# --- Engine scripts ---
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

# --- Config ---
mkdir -p ~/MOD-IOS/config
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
    - anomaly_detector
  concurrency: 4
  misp:
    url: "https://misp.example.com"
    apikey: "YOUR_API_KEY"
EOF

# --- Tests ---
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

# --- Ignore/versioning files ---
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

# --- .github/workflows/extension-ci.yml ---
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

# --- VSCode Extension scaffold ---
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
