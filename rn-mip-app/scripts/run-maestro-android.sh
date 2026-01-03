#!/bin/bash
# Run Maestro test on Android with adb launch
# Usage: ./scripts/run-maestro-android.sh [test-file]

set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Default test file
TEST_FILE="${1:-maestro/flows/homepage-loads-android.yaml}"

# App package name
APP_ID="com.fiveq.ffci"
MAIN_ACTIVITY="${APP_ID}/.MainActivity"

# Kill stale Maestro processes that may be blocking port 7001
STALE_PID=$(lsof -ti :7001 2>/dev/null || true)
if [ -n "$STALE_PID" ]; then
    echo "🔧 Killing stale Maestro process (PID: $STALE_PID) on port 7001..."
    kill -9 $STALE_PID 2>/dev/null || true
    sleep 1
fi

# APK path
APK_PATH="$PROJECT_ROOT/android/app/build/outputs/apk/release/app-release.apk"

# Install APK if it exists
if [ -f "$APK_PATH" ]; then
    echo "📱 Installing/reinstalling APK..."
    adb install -r "$APK_PATH"
else
    echo "⚠️  APK not found at $APK_PATH"
    echo "   Build with: ./gradlew assembleRelease"
fi

echo "🚀 Stopping and launching app..."
adb shell am force-stop "$APP_ID"
adb shell am start -n "$MAIN_ACTIVITY"

echo "⏳ Waiting for app to load and UIAutomation to initialize..."
sleep 5

echo "🧪 Running Maestro test: $TEST_FILE"
cd "$PROJECT_ROOT"
maestro test "$TEST_FILE"
