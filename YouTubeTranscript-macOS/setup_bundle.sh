#!/bin/bash
# Setup script to bundle Python environment with the macOS app

set -e

echo "🔧 Setting up Python environment for bundling..."

# Create venv if it doesn't exist
if [ ! -d ".venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv .venv
fi

# Install dependencies
echo "Installing dependencies..."
.venv/bin/pip install --upgrade pip
.venv/bin/pip install youtube-transcript-api

echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Build the app in Xcode (Product → Archive)"
echo "2. Export as a Mac app"
echo "3. The .venv folder will be included in the app bundle"
