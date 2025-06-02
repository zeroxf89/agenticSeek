#!/bin/bash

# AgenticSeek Quick Deploy - Single Command
# Run this on fresh Ubuntu 24.10 droplet

echo "🚀 AgenticSeek Quick Deploy (Fixed)"
echo "==================================="

# Set your configuration here
export SERVER_IP=159.223.34.36
export OPENAI_API_KEY=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

# Run fixed deployment
chmod +x deploy_fixed.sh
sudo ./deploy_fixed.sh

echo ""
echo "🎯 AgenticSeek deployed and running!"
echo "Access: http://$SERVER_IP:3000"