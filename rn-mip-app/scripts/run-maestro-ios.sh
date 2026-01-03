#!/bin/bash
# Run Maestro test on iOS with standalone build (no Metro)
# Usage: ./scripts/run-maestro-ios.sh [test-file]

set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Default test file
TEST_FILE="${1:-maestro/flows/homepage-loads-ios.yaml}"

# App bundle ID
APP_ID="com.fiveq.ffci"

# Kill stale Maestro processes that may be blocking port 7001
STALE_PID=$(lsof -ti :7001 2>/dev/null || true)
if [ -n "$STALE_PID" ]; then
    echo "🔧 Killing stale Maestro process (PID: $STALE_PID) on port 7001..."
    kill -9 $STALE_PID 2>/dev/null || true
    sleep 1
fi

cd "$PROJECT_ROOT"

# App bundle path
APP_PATH="$PROJECT_ROOT/ios/build/Build/Products/Release-iphonesimulator/FFCIMobile.app"

# Check if app bundle exists
if [ ! -d "$APP_PATH" ]; then
    echo "⚠️  App bundle not found at $APP_PATH"
    echo "   Build with: ./scripts/build-ios-release.sh"
    exit 1
fi

# Check if simulator is booted
BOOTED_SIM=$(xcrun simctl list devices | grep -i "booted" | head -1)
if [ -z "$BOOTED_SIM" ]; then
    echo "⚠️  No booted iOS simulator found"
    echo "   Boot a simulator first"
    exit 1
fi

echo "📱 Installing app on simulator..."
xcrun simctl install booted "$APP_PATH"

echo "🚀 Stopping and launching app..."
xcrun simctl terminate booted "$APP_ID" 2>/dev/null || true
xcrun simctl launch booted "$APP_ID"

echo "⏳ Waiting for app to load and UIAutomation to initialize..."
sleep 5

echo "🧪 Running Maestro test: $TEST_FILE"
maestro test "$TEST_FILE"
