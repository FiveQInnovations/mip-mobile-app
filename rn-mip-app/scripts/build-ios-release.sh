#!/bin/bash
# Build iOS Release .app for simulator (standalone, no Metro)
# Usage: ./scripts/build-ios-release.sh

set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

echo "🔨 Building iOS Release for Simulator..."
echo "=========================================="
echo ""

# Get booted simulator ID
BOOTED_SIM=$(xcrun simctl list devices | grep -i "booted" | head -1 | awk -F'[()]' '{print $2}')
if [ -z "$BOOTED_SIM" ]; then
    echo "⚠️  No booted iOS simulator found"
    echo "   Boot a simulator first"
    exit 1
fi

# Build Release configuration for iOS Simulator
# Use -destination to target specific simulator and ONLY_ACTIVE_ARCH=YES to avoid x86_64 build issues
xcodebuild -workspace ios/FFCIMobile.xcworkspace \
  -scheme FFCIMobile \
  -configuration Release \
  -sdk iphonesimulator \
  -destination "id=$BOOTED_SIM" \
  -derivedDataPath ios/build \
  ONLY_ACTIVE_ARCH=YES \
  clean build

APP_PATH="ios/build/Build/Products/Release-iphonesimulator/FFCIMobile.app"

if [ -d "$APP_PATH" ]; then
    echo ""
    echo "✅ Build successful!"
    echo "📱 App bundle: $APP_PATH"
    exit 0
else
    echo ""
    echo "❌ Build failed - app bundle not found at $APP_PATH"
    exit 1
fi
