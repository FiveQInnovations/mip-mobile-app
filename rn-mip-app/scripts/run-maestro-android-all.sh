#!/bin/bash
# Run all stable Android Maestro tests in sequence
# Usage: ./scripts/run-maestro-android-all.sh

set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

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

# List of stable Android test flows (in order)
STABLE_TESTS=(
    "maestro/flows/homepage-loads-android.yaml"
    "maestro/flows/resources-tab-navigation-android.yaml"
    "maestro/flows/tab-switch-from-home-android.yaml"
)

cd "$PROJECT_ROOT"

# Track results
PASSED=0
FAILED=0
FAILED_TESTS=()

echo ""
echo "🧪 Running all stable Android Maestro tests..."
echo "=========================================="
echo ""

# Run each test
for test_file in "${STABLE_TESTS[@]}"; do
    test_name=$(basename "$test_file" .yaml)
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 Test: $test_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Relaunch app before each test to ensure clean state
    echo "🔄 Relaunching app for clean state..."
    adb shell am force-stop "$APP_ID"
    adb shell am start -n "$MAIN_ACTIVITY"
    sleep 3
    
    if maestro test "$test_file"; then
        echo "✅ PASSED: $test_name"
        ((PASSED++))
    else
        echo "❌ FAILED: $test_name"
        ((FAILED++))
        FAILED_TESTS+=("$test_name")
    fi
    echo ""
done

# Print summary
echo "=========================================="
echo "📊 Test Suite Summary"
echo "=========================================="
echo "Total Tests: ${#STABLE_TESTS[@]}"
echo "✅ Passed: $PASSED"
echo "❌ Failed: $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "🎉 All tests passed!"
    exit 0
else
    echo "⚠️  Some tests failed:"
    for failed_test in "${FAILED_TESTS[@]}"; do
        echo "   - $failed_test"
    done
    exit 1
fi
