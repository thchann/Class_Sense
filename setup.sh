#!/bin/bash
# Setup script for macOS/Linux
# Uses Docker to install Python packages, then installs system dependencies natively

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}EngageNet Native Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}ERROR: Docker is not installed.${NC}"
    echo "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop"
    exit 1
fi

# Check if Docker Compose is available
if ! docker compose version &> /dev/null && ! docker-compose version &> /dev/null; then
    echo -e "${RED}ERROR: Docker Compose is not available.${NC}"
    exit 1
fi

echo -e "${GREEN}Docker found${NC}"

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo -e "${RED}ERROR: Docker is not running.${NC}"
    echo "Please start Docker Desktop and try again."
    exit 1
fi

echo -e "${GREEN}Docker is running${NC}"

# Check Python version
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}ERROR: Python 3 is not installed.${NC}"
    echo "Please install Python 3.10 or higher from: https://www.python.org/downloads/"
    exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)

if [ "$PYTHON_MAJOR" -lt 3 ] || ([ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -lt 10 ]); then
    echo -e "${RED}ERROR: Python 3.10+ is required. Found Python $PYTHON_VERSION${NC}"
    exit 1
fi

echo -e "${GREEN}Python $PYTHON_VERSION found${NC}"

# Detect OS
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
fi

echo "Detected OS: $OS"
echo ""

# Create venv directory structure
echo -e "${BLUE}Creating virtual environment directory...${NC}"
mkdir -p venv/lib/python3.10/site-packages
echo -e "${GREEN}Created venv directory${NC}"
echo ""

# Build Docker image and extract packages
echo -e "${BLUE}Building Docker image and extracting Python packages...${NC}"
echo "This may take several minutes on first run..."
echo ""

# Determine docker compose command
if docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

if $COMPOSE_CMD -f docker-compose.setup.yml up --build; then
    echo -e "${GREEN}Python packages extracted successfully${NC}"
else
    echo -e "${RED}ERROR: Failed to extract Python packages${NC}"
    exit 1
fi

echo ""

# Create pyvenv.cfg file for proper venv recognition
echo -e "${BLUE}Creating virtual environment configuration...${NC}"
cat > venv/pyvenv.cfg << EOF
home = $(which python3 | xargs dirname | xargs dirname)
include-system-site-packages = false
version = $PYTHON_VERSION
EOF

# Create activation script for venv
echo -e "${BLUE}Creating activation scripts...${NC}"
mkdir -p venv/bin

cat > venv/bin/activate << 'ACTIVATE_EOF'
#!/bin/bash
# Virtual environment activation script

export VIRTUAL_ENV="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="$VIRTUAL_ENV/lib/python3.10/site-packages:$PATH"

# Add site-packages to PYTHONPATH
export PYTHONPATH="$VIRTUAL_ENV/lib/python3.10/site-packages:${PYTHONPATH:-}"

# Modify prompt
if [ -z "${VIRTUAL_ENV_DISABLE_PROMPT:-}" ]; then
    _OLD_VIRTUAL_PS1="${PS1:-}"
    PS1="(engagenet) ${PS1:-}"
    export PS1
fi
ACTIVATE_EOF

chmod +x venv/bin/activate
echo -e "${GREEN}Virtual environment configured${NC}"
echo ""

# Install system dependencies
echo -e "${BLUE}Installing system dependencies...${NC}"

if [ "$OS" == "macos" ]; then
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}WARNING: Homebrew not found. Installing system dependencies manually...${NC}"
        echo "Please install ffmpeg manually:"
        echo "  brew install ffmpeg"
        echo ""
    else
        echo "Checking for ffmpeg..."
        if ! command -v ffmpeg &> /dev/null; then
            echo "Installing ffmpeg via Homebrew..."
            brew install ffmpeg
        else
            echo -e "${GREEN}ffmpeg already installed${NC}"
        fi
    fi
elif [ "$OS" == "linux" ]; then
    if command -v apt-get &> /dev/null; then
        echo "Installing system dependencies via apt..."
        sudo apt-get update
        sudo apt-get install -y ffmpeg libgl1 libglib2.0-0
    elif command -v yum &> /dev/null; then
        echo "Installing system dependencies via yum..."
        sudo yum install -y ffmpeg mesa-libGL mesa-libGLU
    else
        echo -e "${YELLOW}WARNING: Package manager not detected. Please install ffmpeg manually.${NC}"
    fi
fi

echo ""

# Validate installation
echo -e "${BLUE}Validating installation...${NC}"
if python3 -c "import sys; sys.path.insert(0, 'venv/lib/python3.10/site-packages'); import torch; import tensorflow; import cv2; import mediapipe; print('Key packages are importable')" 2>/dev/null; then
    echo -e "${GREEN}Installation validated${NC}"
else
    echo -e "${YELLOW}WARNING: Some packages may not be importable. This is normal if system libraries are missing.${NC}"
    echo "You may need to install additional system dependencies."
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Setup complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Activate the virtual environment:"
echo -e "   ${YELLOW}source venv/bin/activate${NC}"
echo ""
echo "2. Start OBS Studio and enable Virtual Camera:"
echo "   - Open OBS Studio"
echo "   - Tools → Start Virtual Camera"
echo ""
echo "3. Run the live engagement detection:"
echo -e "   ${YELLOW}python live_marlin_openface_combination.py${NC}"
echo ""
echo "The script will automatically detect OBS Virtual Camera (usually camera index 1)."
echo ""
echo -e "${BLUE}Note:${NC} Make sure model files are in place:"
echo "  - models/marlin/marlin_vit_base_ytf.encoder.pt"
echo "  - checkpoints/fusion_best.keras"
echo ""
