#!/bin/bash

# AgenticSeek Re-deployment Script
# Pull latest code and redeploy (smart - skip completed steps)

echo "🔄 AgenticSeek Re-deployment"
echo "============================"

# Stop existing services
echo "Stopping existing services..."
pkill -f "python.*api.py" 2>/dev/null || true
pkill -f "npm.*start" 2>/dev/null || true
docker-compose down 2>/dev/null || true

# Pull latest code
echo "Pulling latest code..."
git pull origin main

# Set configuration
export SERVER_IP=159.223.34.36
export OPENAI_API_KEY=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

# Make scripts executable
chmod +x *.sh

# Check if virtual environment exists (smart deployment)
if [ -d "agentic_seek_env" ] && [ -f "agentic_seek_env/bin/activate" ]; then
    echo "Virtual environment exists, continuing from Docker step..."
    
    # Activate virtual environment
    source agentic_seek_env/bin/activate
    
    # Install missing TTS packages if needed
    echo "Checking TTS dependencies..."
    if ! python -c "import kokoro" 2>/dev/null; then
        echo "Installing missing TTS packages..."
        pip install --no-cache-dir soundfile IPython
        if pip install --no-cache-dir kokoro; then
            echo "✅ TTS packages installed"
        else
            echo "⚠️  TTS packages failed to install, will run without TTS"
        fi
    else
        echo "✅ TTS packages already available"
    fi
    
    # Generate SEARXNG secret key for docker-compose
    export SEARXNG_SECRET_KEY=$(openssl rand -hex 32)
    echo "Generated SEARXNG_SECRET_KEY for docker-compose"
    
    # Start Docker services
    echo "Starting Docker services..."
    systemctl start docker
    systemctl enable docker
    sleep 5
    docker-compose up -d
    sleep 10
    
    # Configure and start frontend
    echo "Starting frontend..."
    cd frontend/agentic-seek-front
    if [ -f "src/config/api.js" ]; then
        sed -i "s|localhost|$SERVER_IP|g" src/config/api.js
    fi
    if [ ! -d "node_modules" ]; then
        npm install
    fi
    npm run build
    npm start > ../../frontend.log 2>&1 &
    cd ../..
    
    # Start backend
    echo "Starting backend..."
    python3 api.py > backend.log 2>&1 &
    
    sleep 15
    
    # Check backend status
    if pgrep -f "python.*api.py" > /dev/null; then
        echo "✅ Backend started successfully"
    else
        echo "❌ Backend failed to start. Check backend.log:"
        tail -10 backend.log
    fi
    
    echo "✅ Smart re-deployment complete!"
else
    echo "Running full deployment..."
    sudo ./deploy_ultimate.sh
fi

echo ""
echo "✅ Re-deployment complete!"
echo "Access: http://$SERVER_IP:3000"