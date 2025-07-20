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
