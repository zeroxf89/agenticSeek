#!/bin/bash

# AgenticSeek Simple Deployment Script for Digital Ocean
# Based on original README.md instructions

set -e

# Configuration
SERVER_IP="${SERVER_IP:-159.223.34.36}"
OPENAI_API_KEY="${OPENAI_API_KEY:-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}"

echo "🚀 AgenticSeek Simple Deployment"
echo "================================"
echo "Server IP: $SERVER_IP"
echo "Using OpenAI API"
echo ""

# Step 1: System dependencies
echo "[1/7] Installing system dependencies..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y python3.10 python3.10-venv python3-pip docker.io docker-compose curl wget git

# Fix potential space issues by cleaning package cache
apt-get clean
rm -rf /var/lib/apt/lists/*

# Step 2: Setup Python virtual environment
echo "[2/7] Setting up Python environment..."
python3.10 -m venv agentic_seek_env
source agentic_seek_env/bin/activate

# Step 3: Install Python dependencies with space optimization
echo "[3/7] Installing Python dependencies..."
export TMPDIR=/tmp
pip install --no-cache-dir --upgrade pip
pip install --no-cache-dir -r requirements.txt

# Step 4: Configure for OpenAI API
echo "[4/7] Configuring for OpenAI API..."
cp config.ini config.ini.backup

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

# Step 5: Setup environment variables
echo "[5/7] Setting up environment..."
export OPENAI_API_KEY="$OPENAI_API_KEY"
echo "export OPENAI_API_KEY=\"$OPENAI_API_KEY\"" >> ~/.bashrc

# Create workspace directory
mkdir -p /root/agenticSeek/workspace

# Step 6: Start Docker services
echo "[6/7] Starting Docker services..."
systemctl start docker
systemctl enable docker

# Clean up any existing containers
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true

# Start services using docker-compose
docker-compose up -d

# Wait for services to be ready
echo "Waiting for services to start..."
sleep 15

# Step 7: Configure frontend for server IP
echo "[7/7] Configuring frontend..."
cd frontend/agentic-seek-front

# Install Node.js if not present
if ! command -v npm &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs
fi

# Install frontend dependencies
npm install --production

# Update API URL in frontend
sed -i "s/localhost/$SERVER_IP/g" src/App.js
sed -i "s/127.0.0.1/$SERVER_IP/g" src/App.js

# Build frontend
npm run build

cd ../..

echo ""
echo "✅ Deployment Complete!"
echo "======================="
echo ""
echo "🌐 Access URLs:"
echo "   Frontend: http://$SERVER_IP:3000"
echo "   Backend:  http://$SERVER_IP:8000"
echo ""
echo "🚀 To start AgenticSeek:"
echo "   1. Activate environment: source agentic_seek_env/bin/activate"
echo "   2. Start backend: python3 api.py"
echo "   3. Frontend is served by Docker"
echo ""
echo "📋 Management commands:"
echo "   - View logs: docker-compose logs"
echo "   - Stop services: docker-compose down"
echo "   - Restart: docker-compose restart"
echo ""
echo "🎯 AgenticSeek is ready to use!"