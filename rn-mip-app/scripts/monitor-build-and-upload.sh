#!/bin/bash

# Monitor EAS build and upload to BrowserStack when complete
# Usage: ./scripts/monitor-build-and-upload.sh <build-id>

set -e

cd "$(dirname "$0")/.."

BUILD_ID="${1:-d8e87a40-64b5-4040-8530-63121d2ab3ea}"

echo "📊 Monitoring build: $BUILD_ID"
echo "🔗 Build URL: https://expo.dev/accounts/fiveq-innovations/projects/ffci-app/builds/$BUILD_ID"
echo ""

MAX_ATTEMPTS=180  # 30 minutes
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    STATUS=$(eas build:view "$BUILD_ID" 2>/dev/null | grep -iE "status|State" | head -1 | grep -oE "(finished|in progress|errored|canceled|pending|new)" | head -1 || echo "unknown")
    
    if [ "$STATUS" = "finished" ]; then
        echo "✅ Build completed!"
        break
    elif [ "$STATUS" = "errored" ] || [ "$STATUS" = "canceled" ] || [ "$STATUS" = "error" ]; then
        echo "❌ Build failed with status: $STATUS"
        exit 1
    fi
    
    ATTEMPT=$((ATTEMPT + 1))
    if [ $((ATTEMPT % 6)) -eq 0 ]; then
        ELAPSED=$((ATTEMPT * 10))
        MINUTES=$((ELAPSED / 60))
        echo "⏳ Still building... (${MINUTES}m elapsed, status: ${STATUS})"
    fi
    
    sleep 10
done

if [ "$STATUS" != "finished" ]; then
    echo "⏰ Build timeout. Check manually: https://expo.dev/accounts/fiveq-innovations/projects/ffci-app/builds/$BUILD_ID"
    exit 1
fi

# Download APK
echo ""
echo "📥 Downloading APK..."
APK_FILE="ffci-preview-$(date +%Y%m%d-%H%M%S).apk"

if eas build:download --platform android --id "$BUILD_ID" --output "$APK_FILE" 2>/dev/null; then
    echo "✅ APK downloaded: $APK_FILE"
else
    echo "❌ Download failed"
    exit 1
fi

# Upload to BrowserStack
echo ""
echo "📤 Uploading to BrowserStack..."

if [ -f .env ]; then
    set -a
    source .env
    set +a
fi

if [ -z "$BROWSERSTACK_USERNAME" ] || [ -z "$BROWSERSTACK_ACCESS_KEY" ]; then
    echo "⚠️  BrowserStack credentials not found. APK ready at: $APK_FILE"
    exit 0
fi

./scripts/upload-to-browserstack.sh "$APK_FILE"

echo ""
echo "✅ Complete! APK: $APK_FILE"
