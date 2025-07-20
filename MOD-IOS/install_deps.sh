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
