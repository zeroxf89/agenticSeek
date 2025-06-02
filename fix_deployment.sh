#!/bin/bash

# Quick fix for deployment issues
set -e

echo "🔧 Fixing deployment issues..."

# Fix 1: Create TMPDIR and set for all processes
export TMPDIR="/root/tmp_pip"
mkdir -p "$TMPDIR"
echo "export TMPDIR=\"$TMPDIR\"" >> ~/.bashrc

# Fix 2: Stop all services
echo "Stopping services..."
pkill -f "python.*api.py" 2>/dev/null || true
pkill -f "npm.*start" 2>/dev/null || true
docker-compose down 2>/dev/null || true

# Fix 3: Check backend logs first
echo "Checking backend logs..."
if [ -f "backend.log" ]; then
    echo "=== Backend Log (last 20 lines) ==="
    tail -20 backend.log
    echo "=================================="
fi

# Fix 4: Test backend manually
echo "Testing backend startup..."
source agentic_seek_env/bin/activate
export OPENAI_API_KEY="${OPENAI_API_KEY:-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}"

# Test import issues
python3 -c "
import sys
sys.path.append('.')
try:
    from sources.router import Router
    print('✅ Router import successful')
except Exception as e:
    print(f'❌ Router import failed: {e}')
    
try:
    import uvicorn
    print('✅ Uvicorn available')
except Exception as e:
    print(f'❌ Uvicorn missing: {e}')
"

# Fix 5: Start backend with verbose logging
echo "Starting backend with verbose logging..."
python3 api.py &
BACKEND_PID=$!

# Wait and check
sleep 10
if ps -p $BACKEND_PID > /dev/null; then
    echo "✅ Backend started successfully (PID: $BACKEND_PID)"
    
    # Test backend endpoint
    sleep 5
    if curl -s http://localhost:8000/health > /dev/null; then
        echo "✅ Backend health check passed"
    else
        echo "❌ Backend health check failed"
    fi
else
    echo "❌ Backend failed to start"
    echo "=== Backend Error Log ==="
    tail -20 backend.log
fi

# Fix 6: Start Docker services
echo "Starting Docker services..."
docker-compose up -d
sleep 10

# Fix 7: Start frontend with TMPDIR fix
echo "Starting frontend..."
cd frontend/agentic-seek-front

# Set TMPDIR for npm
export TMPDIR="/root/tmp_pip"
export TEMP="$TMPDIR"
export TMP="$TMPDIR"

# Start frontend
npm start > ../../frontend.log 2>&1 &
FRONTEND_PID=$!
cd ../..

sleep 10
if ps -p $FRONTEND_PID > /dev/null; then
    echo "✅ Frontend started successfully (PID: $FRONTEND_PID)"
else
    echo "❌ Frontend failed to start"
    echo "=== Frontend Error Log ==="
    tail -20 frontend.log
fi

echo ""
echo "🔍 Service Status:"
echo "Backend PID: $BACKEND_PID"
echo "Frontend PID: $FRONTEND_PID"
echo ""
echo "🌐 Access URLs:"
echo "Frontend: http://159.223.34.36:3000"
echo "Backend API: http://159.223.34.36:8000/docs"
echo ""
echo "📋 Logs:"
echo "Backend: tail -f backend.log"
echo "Frontend: tail -f frontend.log"