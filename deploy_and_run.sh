#!/bin/bash

# AgenticSeek One-Click Deployment & Run Script
# For Digital Ocean Ubuntu 24.10

set -e

# Configuration
SERVER_IP="${SERVER_IP:-159.223.34.36}"
OPENAI_API_KEY="${OPENAI_API_KEY:-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}"

echo "🚀 AgenticSeek One-Click Deployment"
echo "==================================="
echo "Server IP: $SERVER_IP"
echo "Using OpenAI API"
echo ""

# Step 1: Install system dependencies
echo "[1/6] Installing system dependencies..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y python3 python3-venv python3-pip docker.io docker-compose curl wget git nodejs npm
apt-get clean && rm -rf /var/lib/apt/lists/*

# Step 2: Setup Python environment
echo "[2/6] Setting up Python environment..."
python3 -m venv agentic_seek_env
source agentic_seek_env/bin/activate
pip install --no-cache-dir --upgrade pip

# Step 3: Install Python dependencies
echo "[3/6] Installing Python dependencies..."
export TMPDIR=/tmp
pip install --no-cache-dir -r requirements.txt

# Step 4: Configure for OpenAI
echo "[4/6] Configuring for OpenAI API..."
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

# Step 5: Start Docker services
echo "[5/6] Starting Docker services..."
systemctl start docker
systemctl enable docker

# Clean existing containers
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true

# Start services
docker-compose up -d
sleep 10

# Step 6: Configure and start frontend
echo "[6/6] Configuring frontend..."
cd frontend/agentic-seek-front
npm install --production

# Update API URLs
sed -i "s/localhost/$SERVER_IP/g" src/App.js 2>/dev/null || true
sed -i "s/127.0.0.1/$SERVER_IP/g" src/App.js 2>/dev/null || true

cd ../..

echo ""
echo "✅ Deployment Complete!"
echo "======================="
echo ""
echo "🚀 Starting AgenticSeek backend..."

# Start backend automatically
source agentic_seek_env/bin/activate
export OPENAI_API_KEY="$OPENAI_API_KEY"

echo ""
echo "🌐 Access URLs:"
echo "   Frontend: http://$SERVER_IP:3000"
echo "   Backend:  http://$SERVER_IP:8000"
echo ""
echo "🎯 Starting backend server..."

# Start backend in background and show logs
nohup python3 api.py > backend.log 2>&1 &
BACKEND_PID=$!

echo "Backend started with PID: $BACKEND_PID"
echo "View logs: tail -f backend.log"
echo ""
echo "🎉 AgenticSeek is running!"
echo "Access the web interface at: http://$SERVER_IP:3000"

# Show initial logs
sleep 3
echo ""
echo "📋 Backend logs:"
tail -10 backend.log || echo "Backend starting..."