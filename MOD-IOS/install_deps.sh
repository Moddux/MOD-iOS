#!/bin/bash
set -euxo pipefail

echo "[INFO] Updating package lists..."
apt update

echo "[INFO] Installing base system-level dependencies..."
apt install -y --no-install-recommends \
    software-properties-common \
    ca-certificates \
    gnupg \
    wget \
    curl \
    build-essential \
    cmake \
    git \
    python3-pip \
    unzip \
    jq \
    lsb-release \
    pkg-config \
    libimage-exiftool-perl \
    ffmpeg \
    mediainfo \
    gpac \
    foremost \
    sleuthkit \
    shellcheck \
    flake8 \
    python3-venv \
    parallel \
    autoconf \
    automake \
    libtool \
    libssl-dev \
    libboost-all-dev \
    libexpat1-dev \
    zlib1g-dev \
    libcppunit-dev \
    libewf-dev \
    g++ \
    python3 \
    flex \
    bison \
    libre2-dev \
    libpcre3-dev \
    libsqlite3-dev \
    libpcap-dev

BULK_EXTRACTOR_SRC="/opt/bulk_extractor"

echo "[INFO] Building bulk_extractor from source..."
if [ ! -d "$BULK_EXTRACTOR_SRC" ]; then
    git clone --recurse-submodules https://github.com/simsong/bulk_extractor.git "$BULK_EXTRACTOR_SRC"
    cd "$BULK_EXTRACTOR_SRC"

    echo "[INFO] Verifying GNU flex installation..."
    if ! command -v flex &> /dev/null; then
        echo "[ERROR] flex not found after installation."
        exit 1
    fi
    echo "[INFO] flex version: $(flex --version)"

    ./bootstrap.sh
    ./configure
    make -j"$(nproc)"
    make install
    ldconfig
else
    echo "[INFO] bulk_extractor already exists at $BULK_EXTRACTOR_SRC. Skipping build."
fi

echo "[INFO] Cleaning up..."
rm -rf "$BULK_EXTRACTOR_SRC"
apt clean
rm -rf /var/lib/apt/lists/*
