#!/bin/bash
# Run Maestro iOS test 5 consecutive times to prove reliability
# Usage: ./scripts/run-maestro-ios-5x.sh [test-file]

set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Default test file
TEST_FILE="${1:-maestro/flows/homepage-loads-ios.yaml}"

cd "$PROJECT_ROOT"

# Kill stale Maestro processes that may be blocking port 7001
STALE_PID=$(lsof -ti :7001 2>/dev/null || true)
if [ -n "$STALE_PID" ]; then
    echo "🔧 Killing stale Maestro process (PID: $STALE_PID) on port 7001..."
    kill -9 $STALE_PID 2>/dev/null || true
    sleep 1
fi

echo ""
echo "🧪 Running iOS Maestro test 5 consecutive times..."
echo "Test: $TEST_FILE"
echo "=========================================="
echo ""

for i in {1..5}; do
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📋 Run $i of 5"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  if ! maestro test "$TEST_FILE"; then
    echo ""
    echo "❌ FAILED on run $i"
    exit 1
  fi
  
  echo "✅ Run $i passed"
done

echo ""
echo "=========================================="
echo "🎉 All 5 runs passed successfully!"
echo "=========================================="
