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

echo "🚀 Stopping and launching app..."
adb shell am force-stop "$APP_ID"
adb shell am start -n "$MAIN_ACTIVITY"

echo "⏳ Waiting for app to load..."
sleep 3

echo "🧪 Running Maestro test: $TEST_FILE"
cd "$PROJECT_ROOT"
maestro test "$TEST_FILE"
