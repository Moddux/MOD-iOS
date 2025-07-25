#!/usr/bin/env bash
#
# gps_map.sh
#
# Purpose : Parse all EXIF JSON files produced by exif_audit.sh, extract
#           latitude / longitude, and create an interactive HTML map
#           (Leaflet via Python/Folium).
#

set -euo pipefail
INPUT_DIR="$1"   # (unused – kept for interface consistency)
SESSION_DIR="$2"
BACKUP_ID="$3"

MODULE_NAME="gps_map"
EXIF_DIR="${SESSION_DIR}/exif_audit"
OUT_DIR="${SESSION_DIR}/${MODULE_NAME}"
MAP_HTML="${OUT_DIR}/${BACKUP_ID}_gps_map.html"

mkdir -p "${OUT_DIR}"

# ---------- generate the map via an embedded Python one‑liner ----------
python3 - <<PY
import json, sys
from pathlib import Path
import pandas as pd
import folium                    # installed by install_deps.sh
from folium.plugins import MarkerCluster

exif_dir = Path("${EXIF_DIR}")
points   = []

for jf in exif_dir.glob("*.json"):
    with jf.open() as f:
        try:
            # exiftool -j outputs a list with one dict per file
            data = json.load(f)[0]
        except Exception:
            continue
        lat = data.get("GPSLatitude")
        lon = data.get("GPSLongitude")
        if lat is None or lon is None:
            continue
        # exiftool returns e.g. "48 deg 51' 30.12\" N" – convert to decimal:
        def dms_to_dec(val):
            parts = val.replace("deg","").replace("\"","").split("'")
            d = float(parts[0])
            m = float(parts[1])
            s, hemi = parts[2].split()
            s = float(s)
            dec = d + m/60 + s/3600
            if hemi in ("S","W"): dec *= -1
            return dec
        try:
            lat_dec = dms_to_dec(lat)
            lon_dec = dms_to_dec(lon)
        except Exception:
            continue
        points.append({"file": jf.name, "lat": lat_dec, "lon": lon_dec})

if not points:
    sys.stderr.write("INFO: [gps_map] No GPS data found – skipping map.\n")
    sys.exit(0)

df = pd.DataFrame(points)
center = [df.lat.mean(), df.lon.mean()]
m = folium.Map(location=center, zoom_start=4)
mc = MarkerCluster().add_to(m)
for _, row in df.iterrows():
    folium.Marker([row.lat, row.lon],
                  tooltip=row.file).add_to(mc)
Path("${MAP_HTML}").write_text(m._repr_html_(), encoding="utf‑8")
print(f"INFO: [gps_map] Map created → {Path('${MAP_HTML}').relative_to(Path.cwd())}")
PY
