# BUILD.md

## Purpose
This document provides instructions for setting up the MOD-IOS environment, including installing dependencies and building the Docker container.

---

### Prerequisites
- git
- docker
- docker-compose

---

### Dependency Installation
Run:
```bash
chmod +x install_deps.sh
sudo ./install_deps.sh
```

---

### Docker Build
```bash
docker build -t mod-ios:latest .
```

---

### Docker-Compose
1. Create backups directory:
   ```bash
   mkdir -p ./backups
   ```
2. Run:
   ```bash
   docker-compose up -d
   ```
3. Enter container:
   ```bash
   docker-compose exec mod-ios bash
   ```

Ubuntu 24.04+ Notes

If you see errors related to containerd.io, do the following before installing Docker:

sudo apt-get remove containerd
sudo apt-get autoremove --purge
sudo apt-get install docker.io

For bulk_extractor, see UPGRADE_NOTES.md for manual build instructions.
