#!/bin/bash

# Install missing packages for AgenticSeek
set -e

echo "🔧 Installing missing packages..."

# Fix TMPDIR
export TMPDIR="/root/tmp_pip"
mkdir -p "$TMPDIR"

# Activate environment
source agentic_seek_env/bin/activate

# Install critical missing packages
echo "Installing chromedriver-autoinstaller..."
pip install chromedriver-autoinstaller>=0.6.4

echo "Installing selenium packages..."
pip install selenium>=4.27.1 fake_useragent>=2.1.0 selenium_stealth>=1.0.6 undetected-chromedriver>=3.5.5

echo "Installing other missing packages..."
pip install markdownify>=1.1.0 beautifulsoup4

# Test imports
echo "Testing imports..."
python3 -c "
import chromedriver_autoinstaller
print('✅ chromedriver_autoinstaller OK')

import selenium
print('✅ selenium OK')

from fake_useragent import UserAgent
print('✅ fake_useragent OK')

from selenium_stealth import stealth
print('✅ selenium_stealth OK')

import undetected_chromedriver
print('✅ undetected_chromedriver OK')

import markdownify
print('✅ markdownify OK')

from bs4 import BeautifulSoup
print('✅ beautifulsoup4 OK')
"

echo "✅ All packages installed successfully!"

# Cleanup
rm -rf "$TMPDIR"/*

echo "Ready to start backend!"