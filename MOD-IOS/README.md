# MOD-IOS Enhanced Forensic Dashboard
## Enhanced iOS Forensic Analysis Platform

### Overview
This is the enhanced MOD-IOS forensic dashboard with complete Parse_Decode.py integration, providing a comprehensive forensic analysis platform for iOS backups.

### Features
- **Complete iOS backup parsing and decoding**
- **Interactive Streamlit dashboard**
- **Modular architecture for forensic analysis**
- **Cross-platform support (macOS, Linux, Windows)**

### Quick Start
```bash
# Activate virtual environment
source .venv/bin/activate

# Start the dashboard
streamlit run engine/dashboard.py
```

### Installation
```bash
# Clone repository
git clone <repo_url> && cd MOD-IOS

# Install dependencies
pip install -r requirements.txt

# Start dashboard
streamlit run engine/dashboard.py
```

### Features
- **iOS Backup Scanner**: Automatic detection of backup folders
- **Decryption Support**: Integrated iphone_backup_decrypt functionality
- **Interactive Analysis**: Streamlit-based forensic dashboard
- **Cross-platform Support**: Works on macOS, Linux, Windows

### Testing
Place iOS backups in the target_/ directory and run the dashboard to start analysis.

### License
MIT License
