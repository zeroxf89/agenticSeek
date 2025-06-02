#!/bin/bash

# Debug backend startup issues
set -e

echo "🔍 Backend Debug Script"
echo "======================"

# Check Python environment
echo "1. Python Environment:"
source agentic_seek_env/bin/activate
python3 --version
pip list | grep -E "(fastapi|uvicorn|torch|transformers)"

echo ""
echo "2. Testing imports:"
python3 -c "
import sys
sys.path.append('.')

# Test basic imports
try:
    import fastapi
    print('✅ FastAPI available')
except Exception as e:
    print(f'❌ FastAPI error: {e}')

try:
    import uvicorn
    print('✅ Uvicorn available')
except Exception as e:
    print(f'❌ Uvicorn error: {e}')

# Test router import
try:
    from sources.router import AgentRouter
    print('✅ Router import successful')
except Exception as e:
    print(f'❌ Router import failed: {e}')
    import traceback
    traceback.print_exc()

# Test other imports
try:
    from sources.llm_provider import Provider
    print('✅ LLM Provider import successful')
except Exception as e:
    print(f'❌ LLM Provider import failed: {e}')

try:
    from sources.interaction import Interaction
    print('✅ Interaction import successful')
except Exception as e:
    print(f'❌ Interaction import failed: {e}')
"

echo ""
echo "3. Testing config:"
if [ -f "config.ini" ]; then
    echo "✅ config.ini exists"
    echo "Config sections:"
    python3 -c "
import configparser
config = configparser.ConfigParser()
config.read('config.ini')
print('Sections:', list(config.sections()))
for section in config.sections():
    print(f'{section}: {dict(config[section])}')
"
else
    echo "❌ config.ini missing"
fi

echo ""
echo "4. Testing Redis connection:"
if command -v redis-cli &> /dev/null; then
    if redis-cli ping 2>/dev/null; then
        echo "✅ Redis is running"
    else
        echo "❌ Redis not responding"
    fi
else
    echo "⚠️ redis-cli not available"
fi

echo ""
echo "5. Testing API startup:"
export OPENAI_API_KEY="${OPENAI_API_KEY:-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}"

# Test API import
python3 -c "
try:
    import api
    print('✅ API module import successful')
except Exception as e:
    print(f'❌ API module import failed: {e}')
    import traceback
    traceback.print_exc()
"

echo ""
echo "6. Starting API with debug output:"
echo "Press Ctrl+C to stop..."
python3 api.py