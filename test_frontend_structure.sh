#!/bin/bash

echo "🔍 Testing frontend structure..."

# Check if frontend directory exists
if [ -d "frontend" ]; then
    echo "✅ frontend/ directory exists"
else
    echo "❌ frontend/ directory missing"
    exit 1
fi

# Check if agentic-seek-front directory exists
if [ -d "frontend/agentic-seek-front" ]; then
    echo "✅ frontend/agentic-seek-front/ directory exists"
else
    echo "❌ frontend/agentic-seek-front/ directory missing"
    exit 1
fi

# Check if package.json exists
if [ -f "frontend/agentic-seek-front/package.json" ]; then
    echo "✅ package.json exists"
else
    echo "❌ package.json missing"
    exit 1
fi

# Check if .env exists
if [ -f "frontend/agentic-seek-front/.env" ]; then
    echo "✅ .env file exists"
    echo "📄 .env content:"
    cat frontend/agentic-seek-front/.env
else
    echo "❌ .env file missing"
fi

# Check package.json scripts
echo "📦 Package.json scripts:"
cd frontend/agentic-seek-front
node -e "
const pkg = require('./package.json');
console.log('Available scripts:');
Object.keys(pkg.scripts).forEach(script => {
    console.log('  ' + script + ': ' + pkg.scripts[script]);
});
"
cd ../..

echo "✅ Frontend structure test completed!"