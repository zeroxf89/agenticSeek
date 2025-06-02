#!/bin/bash

echo "🔧 Quick fix for deployment issues..."

# Kill existing processes
echo "🔄 Stopping existing processes..."
pkill -f "uvicorn" || true
pkill -f "node.*3000" || true
pkill -f "npm.*start" || true
sleep 2

# Install missing system packages
echo "📦 Installing missing system packages..."
apt-get update -qq
apt-get install -y net-tools

# Install uvicorn globally if not available
echo "🐍 Ensuring uvicorn is available..."
if ! python3 -c "import uvicorn" 2>/dev/null; then
    pip3 install uvicorn fastapi
fi

# Create .env file if missing
echo "📝 Ensuring .env file exists..."
cd frontend/agentic-seek-front
if [ ! -f ".env" ]; then
    cat > .env << EOF
HOST=0.0.0.0
PORT=3000
GENERATE_SOURCEMAP=false
REACT_APP_API_URL=http://localhost:8000
EOF
    echo "✅ Created .env file"
else
    echo "✅ .env file already exists"
fi
cd ../..

# Test imports
echo "🧪 Testing critical imports..."
PYTHON_CMD="python3"
if [ -d "agentic_seek_env" ]; then
    PYTHON_CMD="./agentic_seek_env/bin/python"
fi

$PYTHON_CMD -c "
import sys
sys.path.append('.')

# Test uvicorn
try:
    import uvicorn
    print('✅ uvicorn available')
except ImportError as e:
    print(f'❌ uvicorn not available: {e}')

# Test fastapi
try:
    import fastapi
    print('✅ fastapi available')
except ImportError as e:
    print(f'❌ fastapi not available: {e}')

# Test AgentRouter with fallbacks
try:
    from sources.router import AgentRouter
    print('✅ AgentRouter import successful')
except Exception as e:
    print(f'⚠️ AgentRouter import issue: {e}')
    print('This is expected if torch is not available - router has fallbacks')

# Test API
try:
    import api
    print('✅ API module available')
except Exception as e:
    print(f'❌ API module issue: {e}')
"

echo "🔧 Quick fix completed!"
echo ""
echo "📋 Next steps:"
echo "1. Run: sudo ./final_deploy.sh"
echo "2. Check status: ./check_deployment.sh"
echo "3. If issues persist, check logs: tail -20 backend.log"