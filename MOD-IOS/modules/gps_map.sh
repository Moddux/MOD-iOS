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
