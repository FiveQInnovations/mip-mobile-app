#!/bin/bash
# Run Maestro test 5 consecutive times to prove reliability
# Usage: ./scripts/run-maestro-android-5x.sh [test-file]

set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Default test file
TEST_FILE="${1:-maestro/flows/homepage-loads-android.yaml}"

# App package name
APP_ID="com.fiveq.ffci"
MAIN_ACTIVITY="${APP_ID}/.MainActivity"

cd "$PROJECT_ROOT"

for i in {1..5}; do
  echo ""
  echo "=== Run $i of 5 ==="
  
  echo "🚀 Stopping and launching app..."
  adb shell am force-stop "$APP_ID"
  adb shell am start -n "$MAIN_ACTIVITY"
  
  echo "⏳ Waiting for app to load..."
  sleep 3
  
  echo "🧪 Running Maestro test: $TEST_FILE"
  if ! maestro test "$TEST_FILE"; then
    echo "❌ FAILED on run $i"
    exit 1
  fi
done

echo ""
echo "✅ All 5 runs passed successfully!"
