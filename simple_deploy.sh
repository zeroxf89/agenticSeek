#!/bin/bash

# Simple deployment script - fix only broken parts
set -e

echo "🚀 Simple AgenticSeek Deployment"
echo "==============================="

# Configuration
SERVER_IP="${SERVER_IP:-159.223.34.36}"
OPENAI_API_KEY="${OPENAI_API_KEY:-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}"

# Fix TMPDIR globally
export TMPDIR="/root/tmp_pip"
export TEMP="$TMPDIR"
export TMP="$TMPDIR"
mkdir -p "$TMPDIR"
echo "export TMPDIR=\"$TMPDIR\"" >> ~/.bashrc
echo "export TEMP=\"$TMPDIR\"" >> ~/.bashrc
echo "export TMP=\"$TMPDIR\"" >> ~/.bashrc

echo "✅ TMPDIR fixed: $TMPDIR"

# Stop existing services
echo "Stopping existing services..."
pkill -f "python.*api.py" 2>/dev/null || true
pkill -f "npm.*start" 2>/dev/null || true

# Start Docker services
echo "Starting Docker services..."
docker-compose down 2>/dev/null || true
docker-compose up -d
sleep 10

# Check Docker services
echo "Docker services status:"
docker-compose ps

# Activate Python environment
echo "Activating Python environment..."
source agentic_seek_env/bin/activate
export OPENAI_API_KEY="$OPENAI_API_KEY"

# Test backend startup
echo "Testing backend startup..."
python3 -c "
import sys
sys.path.append('.')
try:
    from sources.router import Router
    print('✅ Router import OK')
except Exception as e:
    print(f'❌ Router import failed: {e}')

try:
    import api
    print('✅ API import OK')
except Exception as e:
    print(f'❌ API import failed: {e}')
"

# Start backend
echo "Starting backend..."
nohup python3 api.py > backend.log 2>&1 &
BACKEND_PID=$!
echo "Backend PID: $BACKEND_PID"

# Wait and check backend
sleep 10
if ps -p $BACKEND_PID > /dev/null; then
    echo "✅ Backend started successfully"
    
    # Test backend endpoint
    sleep 5
    if curl -s http://localhost:8000/health > /dev/null 2>&1; then
        echo "✅ Backend health check passed"
    else
        echo "⚠️ Backend health check failed (may be normal)"
    fi
    
    # Test external access
    if curl -s http://$SERVER_IP:8000/docs > /dev/null 2>&1; then
        echo "✅ Backend externally accessible"
    else
        echo "⚠️ Backend external access failed"
    fi
else
    echo "❌ Backend failed to start"
    echo "=== Backend Error Log ==="
    tail -20 backend.log
    exit 1
fi

# Start frontend
echo "Starting frontend..."
cd frontend/agentic-seek-front

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "Installing frontend dependencies..."
    npm install --production --no-optional
fi

# Start frontend with TMPDIR
nohup npm start > ../../frontend.log 2>&1 &
FRONTEND_PID=$!
echo "Frontend PID: $FRONTEND_PID"
cd ../..

# Wait and check frontend
sleep 15
if ps -p $FRONTEND_PID > /dev/null; then
    echo "✅ Frontend started successfully"
else
    echo "❌ Frontend failed to start"
    echo "=== Frontend Error Log ==="
    tail -20 frontend.log
fi

echo ""
echo "🎉 Deployment Summary:"
echo "====================="
echo "Backend PID: $BACKEND_PID"
echo "Frontend PID: $FRONTEND_PID"
echo ""
echo "🌐 Access URLs:"
echo "Frontend: http://$SERVER_IP:3000"
echo "Backend API: http://$SERVER_IP:8000/docs"
echo ""
echo "📋 Debug Commands:"
echo "Backend logs: tail -f backend.log"
echo "Frontend logs: tail -f frontend.log"
echo "Debug backend: ./debug_backend.sh"
echo "Fix issues: ./fix_deployment.sh"
echo ""
echo "🔧 Service Management:"
echo "Kill backend: kill $BACKEND_PID"
echo "Kill frontend: kill $FRONTEND_PID"
echo "Restart: ./simple_deploy.sh"