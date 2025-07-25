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

[!NOTE] Ubuntu 24.04+ Docker/Container Notes

containerd.io from Docker will conflict with Ubuntu 24.04 default containerd. Use docker.io from Ubuntu repositories only. Remove old containerd if needed.

bulk-extractor must be built manually (see UPGRADE_NOTES.md).

---
## [!NOTE] Ubuntu 24.04+ Onboarding

- Remove any conflicting `containerd.io` (`sudo apt-get remove containerd`).
- Use only Ubuntu repo Docker (`sudo apt-get install docker.io`).
- Manually build `bulk_extractor` (see `install_bulk_extractor.sh`).
- Always run: `python3 -m venv .venv && . .venv/bin/activate && pip install --no-cache-dir pandas streamlit`

---

## 📦 Integrated EXIF & Metadata Forensics (MOD-IOS)

This subsystem integrates a standalone EXIF metadata audit pipeline previously under the `SHARE/` directory.

### 🧰 Components

- `engine/meta_parser.py` – SQLite-based EXIF consistency/diff analyzer
- `scripts/meta_audit_advanced.sh` – Bulk EXIF + SQLite population
- `scripts/meta_deep_audit.sh` – Deep metadata inspector
- `engine/launch-gui.py` – Streamlit GUI

### 📈 Reports

Reports are saved to:

~/MOD-IOS/REPORTS/
├── inconsistent_field_presence.csv
├── conflicting_field_values.csv
├── gps_overlay_map.html

### 🔧 To Run CLI

```bash
# Full audit + DB
bash scripts/meta_audit_advanced.sh ~/MOD-IOS/INPUT/

# Run metadata consistency parser
python3 engine/meta_parser.py


# To launch:
streamlit run engine/launch-gui.py



## Metadata and EXIF Analysis Tools

### meta_deep_audit.sh
Performs a deep metadata extraction on all images in a directory using `exiftool`.
- **Input:** path to image directory
- **Output:** Per-image `.meta.txt` reports in `reports/meta_deep_audit/`

```bash
./scripts/meta_deep_audit.sh backups/backup-ios1/
