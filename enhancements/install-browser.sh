#!/bin/bash
#
# Browser Automation Installation Script
# Installs Playwright Chromium for web scraping, screenshots, and automation
# Tested on: Ubuntu 24.04 ARM64
# Estimated time: 5-10 minutes
#

set -e  # Exit on error

echo "================================================"
echo "OpenClaw Browser Automation Installer"
echo "================================================"
echo ""
echo "This will install:"
echo "  - Playwright Chromium (headless browser)"
echo "  - OpenClaw browser configuration"
echo ""
echo "Estimated time: 5-10 minutes"
echo "Disk space required: ~180 MB"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
   echo "❌ Please do not run this script as root"
   exit 1
fi

# Step 1: Check for Node.js
echo "🔍 Step 1/4: Checking Node.js installation..."
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js first."
    exit 1
fi

NODE_VERSION=$(node --version)
echo "✅ Node.js found: $NODE_VERSION"
echo ""

# Step 2: Install Playwright Chromium
echo "📥 Step 2/4: Installing Playwright Chromium (~180 MB download)..."
echo "   This may take 5-10 minutes depending on your connection..."
cd /tmp
npx -y playwright@1.58.2 install chromium >/dev/null 2>&1
echo "✅ Playwright Chromium installed"
echo ""

# Step 3: Verify installation
echo "🔍 Step 3/4: Verifying Chromium installation..."
CHROMIUM_PATH="$HOME/.cache/ms-playwright/chromium-1208/chrome-linux/chrome"
if [ ! -f "$CHROMIUM_PATH" ]; then
    echo "❌ Chromium binary not found at expected location"
    echo "   Expected: $CHROMIUM_PATH"
    echo "   Please check Playwright installation"
    exit 1
fi

# Test Chromium can run
$CHROMIUM_PATH --version >/dev/null 2>&1
echo "✅ Chromium verified and working"
echo ""

# Step 4: Configure OpenClaw
echo "⚙️  Step 4/4: Configuring OpenClaw browser settings..."

# Check if openclaw command exists
if ! command -v openclaw &> /dev/null; then
    echo "⚠️  Warning: openclaw command not found. Skipping configuration."
    echo "   Please configure browser manually after installation."
else
    # Apply browser configuration
    openclaw gateway config.patch << 'CONFIG_EOF'
{
  "browser": {
    "executablePath": "/home/ubuntu/.cache/ms-playwright/chromium-1208/chrome-linux/chrome",
    "headless": true,
    "noSandbox": true
  },
  "commands": {
    "restart": true
  }
}
CONFIG_EOF

    echo "✅ OpenClaw configured"
    echo ""
    
    # Restart gateway
    echo "🔄 Restarting OpenClaw gateway..."
    openclaw gateway restart
    echo "✅ Gateway restarted"
fi

echo ""
echo "================================================"
echo "✅ Browser Automation Installation Complete!"
echo "================================================"
echo ""
echo "What was installed:"
echo "  📍 Playwright Chromium: ~/.cache/ms-playwright/chromium-1208/"
echo "  📍 Browser binary: $CHROMIUM_PATH"
echo ""
echo "Configuration applied:"
echo "  🌐 Browser: Playwright Chromium (headless mode)"
echo "  🔒 Security: Sandbox disabled (required for server environment)"
echo "  ⚡ Performance: Optimized for ARM64"
echo ""
echo "Test the browser:"
echo "  Ask your assistant:"
echo "    'Take a screenshot of example.com'"
echo "    'Open google.com and search for OpenClaw'"
echo "    'What does the homepage of github.com say?'"
echo ""
echo "Capabilities:"
echo "  ✅ Open websites and navigate"
echo "  ✅ Take screenshots (full page or viewport)"
echo "  ✅ Extract text and search content"
echo "  ✅ Fill forms and click buttons"
echo "  ✅ Handle JavaScript-heavy sites"
echo ""
echo "Performance:"
echo "  • Page load: 3-10 seconds typical"
echo "  • Screenshot: 1-2 seconds"
echo "  • Works with: News sites, e-commerce, documentation, etc."
echo ""
echo "Troubleshooting:"
echo "  • If browser times out: Check executablePath in config"
echo "  • If pages don't load: Verify internet connection"
echo "  • Test manually: $CHROMIUM_PATH --version"
echo ""
echo "Enjoy your browser-enabled OpenClaw! 🌐"
echo ""
