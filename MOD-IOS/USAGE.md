# MOD-iOS Usage Guide

## Quick Start
1. Place your iOS backup in `backups/<backup_id>`
2. Build & run with Docker Compose:
   docker compose up --build -d
3. Enter the running container:
   docker compose exec mod-ios bash
4. Run analysis (all-in-one or by module):
   ./cli/meta-ios.sh --input /data/<backup_id>
   ./modules/<module>.sh --input /data/<backup_id>
5. Reports are written to /app/reports/ (container) and mapped to ./reports/ (host)

## Troubleshooting
- See UPGRADE_NOTES.md and BUILD.md for Ubuntu 24.04+ or Docker errors.
- If `bulk-extractor` is missing, see UPGRADE_NOTES.md for manual build steps.
