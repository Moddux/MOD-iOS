#!/usr/bin/env bash
set -euo pipefail
MODS="$(python3 engine/load_config.py)"
[[ "$MODS" == *"exif_audit"* ]] || { echo "Config missing exif_audit"; exit 1; }
echo "PASS: config modules loaded"
