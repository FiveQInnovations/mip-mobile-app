#!/bin/bash

# Pre-build validation script to catch issues before EAS build
# This simulates what EAS Build does to catch dependency conflicts early

set -e

cd "$(dirname "$0")/.."

echo "🔍 Running pre-build validation checks..."
echo ""

# Check 1: Ensure package-lock.json exists
if [ ! -f "package-lock.json" ]; then
    echo "❌ ERROR: package-lock.json not found"
    echo "   EAS Build uses 'npm ci' which requires package-lock.json"
    echo "   Run 'npm install' locally to generate it"
    exit 1
fi

echo "✅ package-lock.json exists"

# Check 2: Run npm ci (what EAS Build uses) to catch dependency conflicts
echo "🔍 Testing 'npm ci' (simulating EAS Build dependency installation)..."
echo ""

# Clean node_modules first to simulate fresh install
if [ -d "node_modules" ]; then
    echo "🧹 Cleaning node_modules..."
    rm -rf node_modules
fi

# Run npm ci with same flags EAS uses
if npm ci --include=dev 2>&1; then
    echo ""
    echo "✅ npm ci succeeded - dependencies are compatible"
else
    echo ""
    echo "❌ ERROR: npm ci failed - dependency conflicts detected"
    echo ""
    echo "This will fail on EAS Build. Common issues:"
    echo "  - Peer dependency conflicts (e.g., React version mismatches)"
    echo "  - Missing required dependencies"
    echo ""
    echo "Fix the dependency issues above, then run this check again:"
    echo "  ./scripts/pre-build-check.sh"
    exit 1
fi

# Check 3: Run expo-doctor to catch other common issues
echo ""
echo "🔍 Running expo-doctor..."
if npx expo-doctor 2>&1 | grep -q "checks failed"; then
    echo ""
    echo "⚠️  WARNING: expo-doctor found issues (non-fatal)"
    echo "   Review the output above and fix if needed"
else
    echo "✅ expo-doctor checks passed"
fi

echo ""
echo "✅ Pre-build validation complete - ready for EAS build"


