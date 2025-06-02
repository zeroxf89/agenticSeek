#!/bin/bash

# Install ALL missing packages for AgenticSeek
set -e

echo "🔧 Installing ALL missing packages..."

# Fix TMPDIR
export TMPDIR="/root/tmp_pip"
mkdir -p "$TMPDIR"

# Activate environment
source agentic_seek_env/bin/activate

# Install all packages from requirements.txt that might be missing
echo "Installing packages from requirements.txt..."
pip install --upgrade pip

# Core packages
pip install fastapi>=0.115.12 uvicorn>=0.34.0 pydantic>=2.10.6

# Browser packages
pip install selenium>=4.27.1 chromedriver-autoinstaller>=0.6.4
pip install fake_useragent>=2.1.0 selenium_stealth>=1.0.6 undetected-chromedriver>=3.5.5

# Language and NLP packages
pip install langid>=1.1.6 nltk transformers>=4.46.3

# Utility packages
pip install markdownify>=1.1.0 beautifulsoup4 requests>=2.31.0
pip install colorama>=0.4.6 python-dotenv>=1.0.0 termcolor>=2.4.0

# Audio packages (optional)
pip install soundfile>=0.13.1 || echo "⚠️ soundfile failed (optional)"

# ML packages (optional)
pip install torch>=2.4.1 || echo "⚠️ torch failed (optional)"
pip install scipy>=1.9.3 numpy>=1.24.4 || echo "⚠️ scipy/numpy failed (optional)"

# Other packages
pip install pypdf>=5.4.0 text2emotion>=0.0.5 || echo "⚠️ some packages failed (optional)"

# Test critical imports
echo "Testing critical imports..."
python3 -c "
# Test core packages
try:
    import fastapi, uvicorn
    print('✅ FastAPI/Uvicorn OK')
except Exception as e:
    print(f'❌ FastAPI/Uvicorn failed: {e}')

# Test browser packages
try:
    import selenium, chromedriver_autoinstaller
    from fake_useragent import UserAgent
    from selenium_stealth import stealth
    import undetected_chromedriver
    print('✅ Browser packages OK')
except Exception as e:
    print(f'❌ Browser packages failed: {e}')

# Test language packages
try:
    import langid, nltk
    print('✅ Language packages OK')
except Exception as e:
    print(f'❌ Language packages failed: {e}')

# Test utility packages
try:
    import markdownify
    from bs4 import BeautifulSoup
    import requests, colorama
    print('✅ Utility packages OK')
except Exception as e:
    print(f'❌ Utility packages failed: {e}')

# Test router import
try:
    import sys
    sys.path.append('.')
    from sources.router import Router
    print('✅ Router import OK')
except Exception as e:
    print(f'❌ Router import failed: {e}')
"

echo "✅ Package installation completed!"

# Cleanup
rm -rf "$TMPDIR"/*

echo "Ready to start backend!"