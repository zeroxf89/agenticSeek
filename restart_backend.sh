#!/bin/bash

# Quick restart backend script
echo "🔄 Restarting backend..."

# Kill existing backend
pkill -f "python.*api.py" 2>/dev/null || true
sleep 2

# Activate virtual environment
source agentic_seek_env/bin/activate

# Start backend
echo "Starting backend..."
python3 api.py > backend.log 2>&1 &

sleep 5

# Check if backend is running
if pgrep -f "python.*api.py" > /dev/null; then
    echo "✅ Backend restarted successfully"
    echo "Access: http://159.223.34.36:3000"
else
    echo "❌ Backend failed to start. Check backend.log:"
    tail -10 backend.log
fi