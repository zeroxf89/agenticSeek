#!/bin/bash

# AgenticSeek Fixed Deployment Script
# Handles Python 3.12 compatibility issues

set -e

# Configuration
SERVER_IP="${SERVER_IP:-159.223.34.36}"
OPENAI_API_KEY="${OPENAI_API_KEY:-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}"

echo "🚀 AgenticSeek Fixed Deployment"
echo "==============================="
echo "Server IP: $SERVER_IP"
echo "Using OpenAI API (no local LLM needed)"
echo ""

# Step 1: Install system dependencies
echo "[1/7] Installing system dependencies..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq

# Install Python 3.10 specifically to avoid 3.12 issues
apt-get install -y software-properties-common
add-apt-repository ppa:deadsnakes/ppa -y
apt-get update -qq

apt-get install -y \
    python3.10 \
    python3.10-venv \
    python3.10-dev \
    python3-pip \
    docker.io \
    docker-compose \
    curl \
    wget \
    git \
    nodejs \
    npm \
    build-essential \
    pkg-config \
    portaudio19-dev \
    libsndfile1-dev \
    ffmpeg

# Clean up
apt-get clean && rm -rf /var/lib/apt/lists/*

# Step 2: Setup Python 3.10 environment
echo "[2/7] Setting up Python 3.10 environment..."
python3.10 -m venv agentic_seek_env
source agentic_seek_env/bin/activate

# Upgrade pip and install wheel
pip install --no-cache-dir --upgrade pip wheel setuptools

# Step 3: Install core dependencies first
echo "[3/7] Installing core dependencies..."
pip install --no-cache-dir \
    fastapi>=0.115.12 \
    uvicorn>=0.34.0 \
    pydantic>=2.10.6 \
    requests>=2.31.0 \
    python-dotenv>=1.0.0 \
    openai \
    aiofiles>=24.1.0

# Step 4: Install optional dependencies (skip problematic ones for OpenAI-only setup)
echo "[4/7] Installing additional dependencies..."
pip install --no-cache-dir \
    numpy>=1.24.4 \
    colorama>=0.4.6 \
    termcolor>=2.4.0 \
    pypdf>=5.4.0 \
    ipython>=8.13.0 \
    selenium>=4.27.1 \
    markdownify>=1.1.0 \
    httpx>=0.27,<0.29 \
    anyio>=3.5.0,<5 \
    fake_useragent>=2.1.0 \
    selenium_stealth>=1.0.6 \
    undetected-chromedriver>=3.5.5 \
    tqdm \
    sniffio \
    ordered_set

# Skip heavy ML packages for OpenAI-only deployment
echo "Skipping heavy ML packages (torch, transformers, etc.) - not needed for OpenAI API"

# Step 5: Configure for OpenAI
echo "[5/7] Configuring for OpenAI API..."
cat > config.ini << EOF
[MAIN]
is_local = False
provider_name = openai
provider_model = gpt-4o-mini
provider_server_address = 127.0.0.1:5000
agent_name = Jarvis
recover_last_session = True
save_session = True
speak = False
listen = False
work_dir = /root/agenticSeek/workspace
jarvis_personality = False
languages = en
[BROWSER]
headless_browser = True
stealth_mode = True
EOF

# Set environment
export OPENAI_API_KEY="$OPENAI_API_KEY"
echo "export OPENAI_API_KEY=\"$OPENAI_API_KEY\"" >> ~/.bashrc
mkdir -p /root/agenticSeek/workspace

# Step 6: Start Docker services
echo "[6/7] Starting Docker services..."
systemctl start docker
systemctl enable docker

# Clean existing containers
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true

# Start services
docker-compose up -d
sleep 10

# Step 7: Configure frontend
echo "[7/7] Configuring frontend..."
cd frontend/agentic-seek-front

# Install frontend dependencies
npm install --production

# Update API URLs for server IP
if [ -f "src/App.js" ]; then
    sed -i "s/localhost/$SERVER_IP/g" src/App.js
    sed -i "s/127.0.0.1/$SERVER_IP/g" src/App.js
fi

cd ../..

echo ""
echo "✅ Deployment Complete!"
echo "======================="
echo ""
echo "🚀 Starting AgenticSeek backend..."

# Start backend
source agentic_seek_env/bin/activate
export OPENAI_API_KEY="$OPENAI_API_KEY"

# Start backend in background
nohup python3 api.py > backend.log 2>&1 &
BACKEND_PID=$!

echo "Backend started with PID: $BACKEND_PID"
echo ""
echo "🌐 Access URLs:"
echo "   Frontend: http://$SERVER_IP:3000"
echo "   Backend:  http://$SERVER_IP:8000"
echo ""
echo "📋 Management commands:"
echo "   View backend logs: tail -f backend.log"
echo "   Stop backend: kill $BACKEND_PID"
echo "   Docker logs: docker-compose logs"
echo ""
echo "🎉 AgenticSeek is running!"

# Show initial logs
sleep 3
echo ""
echo "📋 Backend startup logs:"
tail -5 backend.log 2>/dev/null || echo "Backend starting..."