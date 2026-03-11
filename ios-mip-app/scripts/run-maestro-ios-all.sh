#!/bin/bash
# Run stable native iOS Maestro tests in sequence.
# Usage: ./scripts/run-maestro-ios-all.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

STABLE_TESTS=(
    "maestro/flows/ticket-210-connect-tab-buttons-ios.yaml"
    "maestro/flows/ticket-215-back-button-style-consistency-ios.yaml"
)

PASSED=0
FAILED=0
FAILED_TESTS=()
MAX_ATTEMPTS=2

echo "Running stable native iOS Maestro test suite..."
echo ""

for test_file in "${STABLE_TESTS[@]}"; do
    test_name=$(basename "$test_file" .yaml)
    echo "----------------------------------------"
    echo "Test: $test_name"
    echo "----------------------------------------"

    test_passed=0
    attempt=1
    while [ $attempt -le $MAX_ATTEMPTS ]; do
        echo "Attempt $attempt/$MAX_ATTEMPTS"
        if bash "$SCRIPT_DIR/run-maestro-ios.sh" "$test_file"; then
            test_passed=1
            break
        fi

        if [ $attempt -lt $MAX_ATTEMPTS ]; then
            echo "Retrying due to possible simulator/driver flake..."
            sleep 2
        fi
        attempt=$((attempt + 1))
    done

    if [ $test_passed -eq 1 ]; then
        echo "PASS: $test_name"
        PASSED=$((PASSED + 1))
    else
        echo "FAIL: $test_name"
        FAILED=$((FAILED + 1))
        FAILED_TESTS+=("$test_name")
    fi

    echo ""
done

echo "========================================"
echo "Suite summary"
echo "========================================"
echo "Total: ${#STABLE_TESTS[@]}"
echo "Passed: $PASSED"
echo "Failed: $FAILED"

if [ $FAILED -eq 0 ]; then
    echo "All stable tests passed."
    exit 0
fi

echo "Failed tests:"
for failed_test in "${FAILED_TESTS[@]}"; do
    echo " - $failed_test"
done
exit 1
