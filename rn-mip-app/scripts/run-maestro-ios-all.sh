#!/bin/bash
# Run all stable iOS Maestro tests in sequence (standalone build, no Metro)
# Usage: ./scripts/run-maestro-ios-all.sh

set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

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

# List of stable iOS test flows (in order)
STABLE_TESTS=(
    "maestro/flows/homepage-loads-ios.yaml"
    "maestro/flows/content-page-rendering-ios.yaml"
    "maestro/flows/internal-page-back-navigation-ios.yaml"
    "maestro/flows/search-result-descriptions-ios.yaml"
)

# Track results
PASSED=0
FAILED=0
FAILED_TESTS=()

echo ""
echo "🧪 Running all stable iOS Maestro tests..."
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
    xcrun simctl terminate booted "$APP_ID" 2>/dev/null || true
    xcrun simctl launch booted "$APP_ID"
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
