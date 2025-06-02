#!/bin/bash

# Script to check deployment status and troubleshoot issues

echo "🔍 Checking deployment status..."

# Check if processes are running
echo "📊 Process status:"
echo "Backend (uvicorn):"
ps aux | grep uvicorn | grep -v grep || echo "❌ Backend not running"

echo "Frontend (node/react-scripts):"
ps aux | grep -E "(node.*3000|react-scripts)" | grep -v grep || echo "❌ Frontend not running"

# Check ports
echo "🔌 Port status:"
echo "Port 8000 (Backend):"
netstat -tlnp | grep :8000 || echo "❌ Port 8000 not listening"

echo "Port 3000 (Frontend):"
netstat -tlnp | grep :3000 || echo "❌ Port 3000 not listening"

# Test backend health
echo "🏥 Backend health check:"
if curl -f http://localhost:8000/health > /dev/null 2>&1; then
    echo "✅ Backend health check passed"
else
    echo "❌ Backend health check failed"
fi

# Test frontend
echo "🌐 Frontend check:"
if curl -f http://localhost:3000 > /dev/null 2>&1; then
    echo "✅ Frontend is accessible"
else
    echo "❌ Frontend is not accessible"
fi

# Check logs for errors
echo "📋 Recent backend logs:"
if [ -f backend.log ]; then
    echo "Last 10 lines of backend.log:"
    tail -10 backend.log
else
    echo "❌ backend.log not found"
fi

echo "📋 Recent frontend logs:"
if [ -f frontend.log ]; then
    echo "Last 10 lines of frontend.log:"
    tail -10 frontend.log
else
    echo "❌ frontend.log not found"
fi

# Check disk space
echo "💾 Disk space:"
df -h /

# Check memory usage
echo "🧠 Memory usage:"
free -h

# Check Python packages
echo "🐍 Python package check:"
python3 -c "
try:
    from sources.router import AgentRouter
    print('✅ AgentRouter import successful')
except Exception as e:
    print(f'❌ AgentRouter import failed: {e}')

try:
    import torch
    print('✅ torch available')
except ImportError:
    print('⚠️ torch not available (optional)')

try:
    import librosa
    print('✅ librosa available')
except ImportError:
    print('⚠️ librosa not available (optional)')

try:
    import langid
    print('✅ langid available')
except ImportError:
    print('❌ langid not available')
"

echo "🔍 Deployment check completed!"