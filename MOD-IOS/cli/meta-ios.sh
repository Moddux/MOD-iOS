#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
MODULES=$ROOT/modules
REPORTS=$ROOT/reports

usage(){
  echo "Usage: $0 --input <backup_dir> [--module <name>]"
  exit 1
}

INPUT="" ; MOD=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --input) INPUT=$2; shift 2 ;;
    --module) MOD=$2; shift 2 ;;
    -h|--help) usage ;;
    *) usage ;;
  esac
done

[[ -d $INPUT ]] || { echo "Input not found"; exit 1; }

BACKID=$(basename "$INPUT")
TS=$(date +%Y%m%d_%H%M%S)
SESSION=$REPORTS/${BACKID}_$TS
mkdir -p "$SESSION"
:> "$SESSION/audit.log"
:> "$SESSION/errors.log"

run_module(){
  local name=$1
  echo "[$(date)] START $name" | tee -a "$SESSION/audit.log"
  if ! bash "$MODULES/$name" "$INPUT" "$SESSION" "$BACKID" >>"$SESSION/audit.log" 2>>"$SESSION/errors.log"; then
    echo "[!] $name failed" | tee -a "$SESSION/audit.log"
  fi
  echo "[$(date)] END $name" | tee -a "$SESSION/audit.log"
}

if [[ -n $MOD ]]; then
  [[ "$MOD" == *.sh ]] || MOD="$MOD.sh"
  run_module "$MOD"
else
  for m in "$MODULES"/*.sh; do
    run_module "$(basename "$m")"
  done
fi

echo "Output at $SESSION"
