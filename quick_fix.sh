#!/bin/bash

# Quick fix for current backend TTS issue
echo "🔧 Quick Fix: Installing missing TTS packages"

# Activate virtual environment
source agentic_seek_env/bin/activate

# Install missing packages
echo "Installing TTS dependencies..."
pip install --no-cache-dir soundfile IPython

# Try to install kokoro
if pip install --no-cache-dir kokoro; then
    echo "✅ TTS packages installed successfully"
else
    echo "⚠️  kokoro installation failed, but backend should work with TTS disabled"
fi

# Restart backend
echo "Restarting backend..."
pkill -f "python.*api.py" 2>/dev/null || true
sleep 2
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