#!/bin/bash
# Run Maestro test on native iOS app
# Usage: ./scripts/run-maestro-ios.sh [test-file]

set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Default test file
TEST_FILE="${1:-maestro/flows/homepage-loads-ios.yaml}"

# App bundle ID
APP_ID="com.fiveq.ffci"

# Standard simulator ID (iPhone 16)
SIM_ID="D9DE6784-CB62-4AC3-A686-4D445A0E7B57"

# Kill stale Maestro processes that may be blocking port 7001
STALE_PID=$(lsof -ti :7001 2>/dev/null || true)
if [ -n "$STALE_PID" ]; then
    echo "🔧 Killing stale Maestro process (PID: $STALE_PID) on port 7001..."
    kill -9 $STALE_PID 2>/dev/null || true
    sleep 1
fi

cd "$PROJECT_ROOT"

# Find the app bundle in DerivedData
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "FFCI.app" -path "*/Debug-iphonesimulator/*" -type d | head -1)

# Check if app bundle exists
if [ -z "$APP_PATH" ]; then
    echo "⚠️  App bundle not found in DerivedData"
    echo "   Build the app first with:"
    echo "   cd ios-mip-app"
    echo "   xcodebuild -project FFCI.xcodeproj -scheme FFCI -destination 'id=$SIM_ID' -configuration Debug build"
    exit 1
fi

# Check if the standard simulator is booted
BOOTED_SIM=$(xcrun simctl list devices | grep "$SIM_ID" | grep -i "booted" || true)
if [ -z "$BOOTED_SIM" ]; then
    echo "⚠️  iPhone 16 simulator not booted: $SIM_ID"
    echo "   Boot simulator $SIM_ID first:"
    echo "   xcrun simctl boot $SIM_ID"
    exit 1
fi

echo "📱 Installing app on simulator..."
xcrun simctl install "$SIM_ID" "$APP_PATH"

echo "🚀 Stopping and launching app..."
xcrun simctl terminate "$SIM_ID" "$APP_ID" 2>/dev/null || true
xcrun simctl launch "$SIM_ID" "$APP_ID"

echo "⏳ Waiting for app to load and UIAutomation to initialize..."
sleep 5

echo "🧪 Running Maestro test: $TEST_FILE"
maestro -p ios --udid "$SIM_ID" test "$TEST_FILE"
