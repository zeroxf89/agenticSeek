#!/bin/bash

# Final deployment script with all fixes applied
# This script includes all the fixes for Digital Ocean deployment

set -e  # Exit on any error

echo "🚀 Starting final deployment with all fixes..."

# Set environment variables for proper package installation
export TMPDIR="/root/tmp_pip"
export NODE_OPTIONS="--max-old-space-size=2048"
export PYTHONPATH="/root/agenticSeek:$PYTHONPATH"

# Create temporary directory for pip
mkdir -p "$TMPDIR"
echo "✅ Created TMPDIR: $TMPDIR"

# Kill any existing processes on ports we need
echo "🔄 Cleaning up existing processes..."
pkill -f "uvicorn" || true
pkill -f "node.*3000" || true
pkill -f "npm.*start" || true
sleep 2

# Update system packages
echo "📦 Updating system packages..."
apt-get update -qq

# Install system dependencies
echo "🔧 Installing system dependencies..."
apt-get install -y -qq \
    python3-pip \
    python3-dev \
    nodejs \
    npm \
    wget \
    curl \
    unzip \
    chromium-browser \
    net-tools \
    xvfb \
    portaudio19-dev \
    libsndfile1 \
    ffmpeg \
    build-essential

# Install all missing Python packages
echo "🐍 Installing Python packages..."
pip3 install --upgrade pip
pip3 install uvicorn fastapi
chmod +x install_all_missing.sh
./install_all_missing.sh

# Install frontend dependencies
echo "📱 Installing frontend dependencies..."
cd frontend/agentic-seek-front

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "📝 Creating .env file..."
    cat > .env << EOF
HOST=0.0.0.0
PORT=3000
GENERATE_SOURCEMAP=false
REACT_APP_API_URL=http://localhost:8000
EOF
fi

npm install --no-optional --legacy-peer-deps
cd ../..

# Build frontend
echo "🏗️ Building frontend..."
cd frontend/agentic-seek-front
TMPDIR="$TMPDIR" npm run build
cd ../..

# Start backend
echo "🔧 Starting backend..."
cd /root/agenticSeek
# Try virtual environment first, fallback to system python with uvicorn
if [ -d "agentic_seek_env" ]; then
    nohup ./agentic_seek_env/bin/python -m uvicorn api:app --host 0.0.0.0 --port 8000 > backend.log 2>&1 &
else
    nohup python3 -m uvicorn api:app --host 0.0.0.0 --port 8000 > backend.log 2>&1 &
fi
BACKEND_PID=$!
echo "Backend started with PID: $BACKEND_PID"

# Wait for backend to start
echo "⏳ Waiting for backend to start..."
sleep 10

# Check if backend is running
if curl -f http://localhost:8000/health > /dev/null 2>&1; then
    echo "✅ Backend is running on port 8000"
else
    echo "❌ Backend failed to start. Checking logs..."
    tail -20 backend.log
    exit 1
fi

# Start frontend
echo "🌐 Starting frontend..."
cd frontend/agentic-seek-front
nohup npm start > ../../frontend.log 2>&1 &
FRONTEND_PID=$!
echo "Frontend started with PID: $FRONTEND_PID"
cd ../..

# Wait for frontend to start
echo "⏳ Waiting for frontend to start..."
sleep 15

# Check if frontend is running
if curl -f http://localhost:3000 > /dev/null 2>&1; then
    echo "✅ Frontend is running on port 3000"
else
    echo "❌ Frontend failed to start. Checking logs..."
    tail -20 frontend.log
    exit 1
fi

echo "🎉 Deployment completed successfully!"
echo "📊 Backend: http://your-server-ip:8000"
echo "🌐 Frontend: http://your-server-ip:3000"
echo "📋 Backend logs: tail -f /root/agenticSeek/backend.log"
echo "📋 Frontend logs: tail -f /root/agenticSeek/frontend.log"

# Show process status
echo "📈 Process status:"
ps aux | grep -E "(uvicorn|node)" | grep -v grep || echo "No processes found"

echo "✅ All services are running!"