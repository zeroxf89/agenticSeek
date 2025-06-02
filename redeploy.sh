#!/bin/bash

# AgenticSeek Re-deployment Script
# Pull latest code and redeploy

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

# Run ultimate deployment (fixes all known issues)
echo "Running ultimate deployment..."
sudo ./deploy_ultimate.sh

echo ""
echo "✅ Re-deployment complete!"
echo "Access: http://$SERVER_IP:3000"