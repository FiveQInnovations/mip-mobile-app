#!/bin/bash

# Helper script to check EAS build status
# Usage: ./scripts/check-build-status.sh [build-id]

cd "$(dirname "$0")/.."

if [ -n "$1" ]; then
    BUILD_ID="$1"
elif [ -f "/tmp/eas-build-id.txt" ]; then
    BUILD_ID=$(cat /tmp/eas-build-id.txt)
else
    echo "📋 Finding latest Android build..."
    BUILD_ID=$(eas build:list --platform android --limit 1 --non-interactive 2>/dev/null | grep -oE "[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}" | head -1)
fi

if [ -z "$BUILD_ID" ]; then
    echo "❌ No build ID found"
    echo "💡 Usage: $0 [build-id]"
    exit 1
fi

echo "🔍 Checking build status for: $BUILD_ID"
echo ""

# Get build details
eas build:view "$BUILD_ID"

echo ""
echo "🔗 Build URL: https://expo.dev/accounts/fiveq-innovations/projects/ffci-app/builds/$BUILD_ID"

# Check if build is finished and offer to download
STATUS=$(eas build:view "$BUILD_ID" 2>/dev/null | grep -iE "status|State" | head -1 | grep -oE "(finished|in-progress|errored|canceled|pending|new)" | head -1 || echo "unknown")

if [ "$STATUS" = "finished" ]; then
    echo ""
    echo "✅ Build is finished! Download with:"
    echo "   eas build:download --platform android --id $BUILD_ID"
fi

