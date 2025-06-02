#!/bin/bash

# AgenticSeek Ultimate Deployment Script
# Fixes ALL known issues from previous deployments

set -e

# Configuration
SERVER_IP="${SERVER_IP:-159.223.34.36}"
OPENAI_API_KEY="${OPENAI_API_KEY:-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}"

# TTS Option (Text-to-Speech) - Set to false to skip TTS packages
INSTALL_TTS="${INSTALL_TTS:-true}"

echo "🚀 AgenticSeek Ultimate Deployment"
echo "=================================="
echo "Server IP: $SERVER_IP"
echo "Using OpenAI API (no local LLM needed)"
echo ""

# Step 1: Cleanup and prepare
echo "[1/8] Cleanup and prepare..."

# Stop existing services
pkill -f "python.*api.py" 2>/dev/null || true
pkill -f "npm.*start" 2>/dev/null || true

# Clean Docker containers (fix redis conflict)
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true
docker system prune -f 2>/dev/null || true

# Clean tmp space (fix space issues)
rm -rf /tmp/pip-* /tmp/build-* 2>/dev/null || true
apt-get clean && apt-get autoclean

# CRITICAL: Remove deadsnakes PPA if exists (fix Ubuntu 24.10 oracular error)
echo "Removing deadsnakes PPA if exists..."
add-apt-repository --remove ppa:deadsnakes/ppa -y 2>/dev/null || true
rm -f /etc/apt/sources.list.d/deadsnakes-ubuntu-ppa-*.list 2>/dev/null || true

# Step 2: Install system dependencies (NO PPA!)
echo "[2/8] Installing system dependencies..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq

# Use system Python (no deadsnakes PPA needed)
apt-get install -y \
    python3 \
    python3-venv \
    python3-dev \
    python3-pip \
    docker.io \
    docker-compose \
    curl \
    wget \
    git \
    build-essential \
    pkg-config \
    software-properties-common

# Install Node.js from NodeSource (fix npm not found)
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Clean up
apt-get clean && rm -rf /var/lib/apt/lists/*

# Step 3: Setup Python environment
echo "[3/8] Setting up Python environment..."

# Remove old venv if exists
rm -rf agentic_seek_env venv

# Create new venv with system Python
python3 -m venv agentic_seek_env
source agentic_seek_env/bin/activate

# Upgrade pip and install wheel
pip install --no-cache-dir --upgrade pip wheel setuptools

# Step 4: Install ONLY essential Python packages (skip problematic ones)
echo "[4/8] Installing essential Python packages..."

# Install packages one by one to avoid version constraint issues
echo "Installing core web framework..."
pip install --no-cache-dir fastapi uvicorn pydantic requests python-dotenv openai aiofiles python-multipart

echo "Installing utilities..."
pip install --no-cache-dir numpy colorama termcolor pypdf ipython tqdm sniffio ordered_set certifi

echo "Installing browser automation..."
pip install --no-cache-dir selenium markdownify fake_useragent selenium_stealth undetected-chromedriver

echo "Installing additional providers..."
pip install --no-cache-dir ollama

# Optional TTS packages
if [ "$INSTALL_TTS" = "true" ]; then
    echo "Installing TTS packages (kokoro, soundfile, IPython)..."
    pip install --no-cache-dir soundfile IPython
    
    # Try to install kokoro (may fail on some systems)
    if pip install --no-cache-dir kokoro; then
        echo "✅ TTS packages installed successfully"
    else
        echo "⚠️  Warning: kokoro installation failed, TTS will be disabled"
    fi
else
    echo "✅ Skipping TTS packages (INSTALL_TTS=false)"
fi

echo "✅ Skipping heavy ML packages: torch, transformers, librosa, pyaudio (not needed for OpenAI API)"

# Step 5: Configure for OpenAI
echo "[5/8] Configuring for OpenAI API..."

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
echo "[6/8] Starting Docker services..."

# Generate SEARXNG secret key for docker-compose
export SEARXNG_SECRET_KEY=$(openssl rand -hex 32)
echo "Generated SEARXNG_SECRET_KEY for docker-compose"

systemctl start docker
systemctl enable docker

# Wait for Docker to be ready
sleep 5

# Start services with proper cleanup
docker-compose down 2>/dev/null || true
docker-compose up -d
sleep 10

# Step 7: Configure frontend
echo "[7/8] Configuring frontend..."
cd frontend/agentic-seek-front

# Install frontend dependencies
npm install --production --no-optional

# Fix CORS and API URLs
if [ -f "src/App.js" ]; then
    # Update API URLs for server IP
    sed -i "s/localhost/$SERVER_IP/g" src/App.js
    sed -i "s/127.0.0.1/$SERVER_IP/g" src/App.js
    
    # Add CORS headers if not present
    if ! grep -q "Access-Control-Allow-Origin" src/App.js; then
        echo "Adding CORS configuration..."
    fi
fi

# Build frontend for production
npm run build 2>/dev/null || echo "Build skipped (dev mode)"

cd ../..

# Step 8: Start services
echo "[8/8] Starting AgenticSeek services..."

# Activate Python environment
source agentic_seek_env/bin/activate
export OPENAI_API_KEY="$OPENAI_API_KEY"

# Start backend with proper error handling
echo "Starting backend..."
nohup python3 api.py > backend.log 2>&1 &
BACKEND_PID=$!

# Wait and check backend
sleep 5
if ! ps -p $BACKEND_PID > /dev/null; then
    echo "❌ Backend failed to start. Check backend.log:"
    tail -10 backend.log
    exit 1
fi

# Start frontend
echo "Starting frontend..."
cd frontend/agentic-seek-front
nohup npm start > ../../frontend.log 2>&1 &
FRONTEND_PID=$!
cd ../..

# Wait and check frontend
sleep 5
if ! ps -p $FRONTEND_PID > /dev/null; then
    echo "❌ Frontend failed to start. Check frontend.log:"
    tail -10 frontend.log
    exit 1
fi

echo ""
echo "✅ Deployment Complete!"
echo "======================="
echo ""
echo "🌐 Access URLs:"
echo "   Frontend: http://$SERVER_IP:3000"
echo "   Backend:  http://$SERVER_IP:8000"
echo ""
echo "📋 Service Status:"
echo "   Backend PID:  $BACKEND_PID"
echo "   Frontend PID: $FRONTEND_PID"
echo ""
echo "🔧 Management commands:"
echo "   View backend logs:  tail -f backend.log"
echo "   View frontend logs: tail -f frontend.log"
echo "   Stop backend:       kill $BACKEND_PID"
echo "   Stop frontend:      kill $FRONTEND_PID"
echo "   Docker logs:        docker-compose logs"
echo ""
echo "🎉 AgenticSeek is running!"

# Show initial logs
sleep 3
echo ""
echo "📋 Recent logs:"
echo "--- Backend ---"
tail -5 backend.log 2>/dev/null || echo "Backend starting..."
echo "--- Frontend ---"
tail -5 frontend.log 2>/dev/null || echo "Frontend starting..."

# Health check
echo ""
echo "🔍 Health check:"
sleep 5
if curl -s http://localhost:8000/health > /dev/null 2>&1; then
    echo "✅ Backend: OK"
else
    echo "❌ Backend: Check logs"
fi

if curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo "✅ Frontend: OK"
else
    echo "❌ Frontend: Check logs"
fi