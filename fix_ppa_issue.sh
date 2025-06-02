#!/bin/bash

# Fix PPA deadsnakes issue on Ubuntu 24.10
echo "🔧 Fixing PPA deadsnakes issue..."

# Remove deadsnakes PPA completely
echo "Removing deadsnakes PPA..."
add-apt-repository --remove ppa:deadsnakes/ppa -y 2>/dev/null || true

# Remove all deadsnakes related files
rm -f /etc/apt/sources.list.d/deadsnakes-ubuntu-ppa-*.list 2>/dev/null || true
rm -f /etc/apt/sources.list.d/*deadsnakes* 2>/dev/null || true

# Clean apt cache
apt-get clean
apt-get autoclean

# Update package lists
echo "Updating package lists..."
apt-get update

echo "✅ PPA issue fixed! Now run deployment:"
echo "sudo ./deploy_ultimate.sh"