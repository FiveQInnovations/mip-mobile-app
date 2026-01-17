#!/bin/bash
# Build iOS Release .app for simulator (standalone, no Metro)
# Usage: ./scripts/build-ios-release.sh

set -e

# Standard iPhone 16 simulator - ALWAYS use this specific device
# This prevents issues with stale builds on wrong simulators
DEVICE_UDID="D9DE6784-CB62-4AC3-A686-4D445A0E7B57"

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

echo "🔨 Building iOS Release for Simulator..."
echo "=========================================="
echo "📱 Target: iPhone 16 ($DEVICE_UDID)"
echo ""

# Boot the specific simulator if not already booted
BOOTED_SIM=$(xcrun simctl list devices | grep "$DEVICE_UDID" | grep -i "booted" || true)
if [ -z "$BOOTED_SIM" ]; then
    echo "🚀 Booting iPhone 16 simulator..."
    xcrun simctl boot "$DEVICE_UDID" 2>/dev/null || true
    sleep 3
fi

# Build Release configuration for iOS Simulator
# Use -destination to target specific simulator and ONLY_ACTIVE_ARCH=YES to avoid x86_64 build issues
xcodebuild -workspace ios/FFCIMobile.xcworkspace \
  -scheme FFCIMobile \
  -configuration Release \
  -sdk iphonesimulator \
  -destination "id=$DEVICE_UDID" \
  -derivedDataPath ios/build \
  ONLY_ACTIVE_ARCH=YES \
  clean build

APP_PATH="ios/build/Build/Products/Release-iphonesimulator/FFCIMobile.app"

if [ -d "$APP_PATH" ]; then
    echo ""
    echo "✅ Build successful!"
    echo "📱 App bundle: $APP_PATH"
    echo ""
    echo "📲 Installing on iPhone 16..."
    xcrun simctl install "$DEVICE_UDID" "$APP_PATH"
    echo "🚀 Launching app..."
    xcrun simctl launch "$DEVICE_UDID" com.fiveq.ffci
    echo ""
    echo "✅ App installed and launched on iPhone 16"
    exit 0
else
    echo ""
    echo "❌ Build failed - app bundle not found at $APP_PATH"
    exit 1
fi
