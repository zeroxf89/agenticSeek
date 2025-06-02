#!/bin/bash

# Continue deployment from Docker step (skip completed steps)
echo "🔄 Continuing AgenticSeek deployment from Docker step..."

# Set environment
export SERVER_IP=${SERVER_IP:-159.223.34.36}
export OPENAI_API_KEY=${OPENAI_API_KEY:-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}

# Activate virtual environment
source agentic_seek_env/bin/activate

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

# Update API URL in frontend
if [ -f "src/config/api.js" ]; then
    sed -i "s|localhost|$SERVER_IP|g" src/config/api.js
fi

# Install frontend dependencies if not already installed
if [ ! -d "node_modules" ]; then
    npm install
fi

# Build and start frontend
npm run build
npm start > ../../frontend.log 2>&1 &

cd ../..

# Step 8: Start backend
echo "[8/8] Starting backend..."

# Start backend API
python3 api.py > backend.log 2>&1 &

# Wait for services to start
sleep 15

# Health check
echo ""
echo "🔍 Health Check:"
echo "Frontend: http://$SERVER_IP:3000"
echo "Backend: http://$SERVER_IP:8000"
echo "SearXNG: http://$SERVER_IP:8080"

# Check if services are running
if pgrep -f "python.*api.py" > /dev/null; then
    echo "✅ Backend is running"
else
    echo "❌ Backend failed to start"
fi

if pgrep -f "npm.*start" > /dev/null; then
    echo "✅ Frontend is running"
else
    echo "❌ Frontend failed to start"
fi

if docker ps | grep -q searxng; then
    echo "✅ SearXNG is running"
else
    echo "❌ SearXNG failed to start"
fi

echo ""
echo "✅ Deployment continued successfully!"
echo "Access: http://$SERVER_IP:3000"