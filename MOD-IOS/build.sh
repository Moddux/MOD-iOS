#sh !/bin/bash
# MOD-IOS Enhanced Forensic Dashboard Setup
# Sets up environment and dependencies for the enhanced forensic dashboard

set -e

echo "🚀 MOD-IOS Enhanced Forensic Dashboard Setup"
echo "============================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [[ ! -f "README.md" ]] || [[ ! -d "engine" ]]; then
    echo -e "${RED}Error: Please run this script from the MOD-IOS root directory${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Running from correct directory${NC}"

# Detect OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)     OS_TYPE=Linux;;
    Darwin*)    OS_TYPE=Mac;;
    CYGWIN*)    OS_TYPE=Cygwin;;
    MINGW*)     OS_TYPE=Windows;;
    *)          OS_TYPE="Unknown:${OS}";;
esac

echo -e "${GREEN}✓ Detected OS: ${OS_TYPE}${NC}"

# Check Python version
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>/dev/null || echo "Python3 not found")
    echo -e "${GREEN}✓ Python version: ${PYTHON_VERSION}${NC}"
else
    echo -e "${RED}Error: Python3 not found. Please install Python 3.8 or higher${NC}"
    exit 1
fi

# Create target directory for backups
echo "📁 Creating target directory..."
mkdir -p target_

# Create virtual environment
echo "🐍 Setting up virtual environment..."
if [[ -d ".venv" ]]; then
    echo -e "${YELLOW}Virtual environment already exists${NC}"
else
    python3 -m venv .venv
    echo -e "${GREEN}✓ Virtual environment created${NC}"
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source .venv/bin/activate

# Upgrade pip
echo "📦 Upgrading pip..."
pip install --upgrade pip

# Install core dependencies
echo "📦 Installing core dependencies..."
pip install streamlit pandas biplist

# Install optional dependencies for decryption
echo "📦 Installing optional dependencies..."
pip install iphone_backup_decrypt || echo -e "${YELLOW}Warning: iphone_backup_decrypt not available${NC}"

# Create requirements.txt
echo "📝 Creating requirements.txt..."
cat > requirements.txt << EOF
streamlit>=1.28.0
pandas>=1.5.0
biplist>=1.0.3
iphone_backup_decrypt>=0.9.0
EOF

# Set permissions
echo "🔐 Setting permissions..."
chmod +x engine/dashboard.py
chmod +x engine/modules/*.py

# Create test data directory
echo "📊 Creating test data directory..."
mkdir -p tests/test_data

# Verify installation
echo "🔍 Verifying installation..."
python3 -c "import streamlit; print('Streamlit:', streamlit.__version__)"
python3 -c "import pandas; print('Pandas:', pandas.__version__)"
python3 -c "import biplist; print('Biplist: OK')"

# Create activation script
echo "🎯 Creating activation script..."
cat > activate.sh << 'EOF'
#!/bin/bash
# Quick activation script for MOD-IOS
source .venv/bin/activate
echo "Virtual environment activated. Run 'streamlit run engine/dashboard.py' to start"
EOF
chmod +x activate.sh

# Create quick start guide
cat > QUICK_START.md << 'EOF'
# MOD-IOS Quick Start

## Starting the Dashboard
```bash
./activate.sh
streamlit run engine/dashboard.py
```

## Manual Steps
1. Activate virtual environment: `source .venv/bin/activate`
2. Start dashboard: `streamlit run engine/dashboard.py`
3. Navigate to http://localhost:8501

## Testing
Place iOS backup folders in `target_/` directory
EOF

# Test Streamlit installation
echo "🧪 Testing Streamlit installation..."
python3 -c "import streamlit; print('Streamlit test: OK')"

echo -e "${GREEN}🎉 Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Run './activate.sh' to activate the environment"
echo "2. Run 'streamlit run engine/dashboard.py' to start the dashboard"
echo "3. Place iOS backups in the target_/ directory"
echo ""
echo "For help, see QUICK_START.md"
