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
