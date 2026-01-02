#!/bin/bash

# Script to build Android preview APK with EAS and download when ready
# This handles long-running builds by polling for status

set -e

cd "$(dirname "$0")/.."

BUILD_PROFILE="preview"
PLATFORM="android"
LOG_FILE="/tmp/eas-build-$(date +%s).log"
BUILD_ID_FILE="/tmp/eas-build-id.txt"

# Run pre-build validation checks first
echo "🔍 Running pre-build validation checks..."
if ! ./scripts/pre-build-check.sh; then
    echo ""
    echo "❌ Pre-build checks failed. Fix the issues above before building."
    echo "   This prevents wasting time on builds that will fail quickly."
    exit 1
fi

echo ""
echo "🚀 Starting EAS build for Android preview..."
echo "📝 Build logs: $LOG_FILE"

# Start build in background and capture output
eas build --profile "$BUILD_PROFILE" --platform "$PLATFORM" --non-interactive > "$LOG_FILE" 2>&1 &
BUILD_PID=$!

echo "⏳ Build process started (PID: $BUILD_PID)"
echo "📋 Waiting for build ID..."

# Wait for build ID to appear in logs (EAS outputs it early)
BUILD_ID=""
ATTEMPTS=0
MAX_ID_WAIT=30  # Wait up to 5 minutes for build ID

while [ -z "$BUILD_ID" ] && [ $ATTEMPTS -lt $MAX_ID_WAIT ]; do
    sleep 10
    ATTEMPTS=$((ATTEMPTS + 1))
    
    # Try to extract build ID from logs (multiple patterns)
    BUILD_ID=$(grep -iE "(build.*id|Build ID|buildId)" "$LOG_FILE" 2>/dev/null | grep -oE "[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}" | head -1)
    
    # Also check for URL pattern
    if [ -z "$BUILD_ID" ]; then
        BUILD_ID=$(grep -oE "builds/[a-f0-9-]{36}" "$LOG_FILE" 2>/dev/null | cut -d'/' -f2 | head -1)
    fi
    
    if [ -n "$BUILD_ID" ]; then
        break
    fi
    
    if [ $((ATTEMPTS % 3)) -eq 0 ]; then
        echo "⏳ Still waiting for build ID... ($((ATTEMPTS * 10)) seconds)"
    fi
done

# If still no build ID, try checking latest build
if [ -z "$BUILD_ID" ]; then
    echo "⚠️  Could not extract build ID from logs, checking latest build..."
    sleep 5
    BUILD_ID=$(eas build:list --platform android --limit 1 --non-interactive 2>/dev/null | grep -oE "[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}" | head -1)
fi

if [ -z "$BUILD_ID" ]; then
    echo "❌ Could not determine build ID. Check logs: $LOG_FILE"
    echo "📄 Last 30 lines of build output:"
    tail -30 "$LOG_FILE"
    echo ""
    echo "💡 You can check builds manually with: eas build:list --platform android"
    exit 1
fi

echo "$BUILD_ID" > "$BUILD_ID_FILE"
echo "✅ Build ID: $BUILD_ID"
echo "🔗 Build URL: https://expo.dev/accounts/fiveq-innovations/projects/ffci-app/builds/$BUILD_ID"

# Poll for build status
MAX_ATTEMPTS=180  # 30 minutes max (10 seconds * 180 = 1800 seconds = 30 min)
ATTEMPT=0
STATUS=""
LAST_STATUS=""

echo "📊 Monitoring build status..."

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    # Check if background process is still running
    if ! kill -0 $BUILD_PID 2>/dev/null; then
        echo "ℹ️  Build submission process completed. Build is now running on EAS servers..."
    fi
    
    # Get current build status
    STATUS=$(eas build:view "$BUILD_ID" 2>/dev/null | grep -iE "status|State" | head -1 | grep -oE "(finished|in progress|errored|canceled|pending|new)" | head -1 || echo "unknown")
    
    # If status changed, report it
    if [ "$STATUS" != "$LAST_STATUS" ] && [ -n "$STATUS" ] && [ "$STATUS" != "unknown" ]; then
        echo "📊 Build status: $STATUS"
        LAST_STATUS="$STATUS"
    fi
    
    if [ "$STATUS" = "finished" ]; then
        echo "✅ Build completed successfully!"
        break
    elif [ "$STATUS" = "errored" ] || [ "$STATUS" = "canceled" ] || [ "$STATUS" = "error" ]; then
        echo "❌ Build failed with status: $STATUS"
        echo "📄 Check logs: $LOG_FILE"
        echo "🔗 View build: https://expo.dev/accounts/fiveq-innovations/projects/ffci-app/builds/$BUILD_ID"
        exit 1
    fi
    
    ATTEMPT=$((ATTEMPT + 1))
    if [ $((ATTEMPT % 12)) -eq 0 ]; then
        ELAPSED=$((ATTEMPT * 10))
        MINUTES=$((ELAPSED / 60))
        SECONDS=$((ELAPSED % 60))
        echo "⏳ Still building... (${MINUTES}m ${SECONDS}s elapsed, status: ${STATUS:-in-progress})"
    fi
    
    sleep 10
done

if [ "$STATUS" != "finished" ]; then
    echo "⏰ Build is taking longer than expected. Status: ${STATUS:-unknown}"
    echo "📄 Check logs: $LOG_FILE"
    echo "🔗 View build: https://expo.dev/accounts/fiveq-innovations/projects/ffci-app/builds/$BUILD_ID"
    echo "💡 You can manually check status with: eas build:view $BUILD_ID"
    exit 1
fi

# Wait for background process to fully complete
wait $BUILD_PID 2>/dev/null || true

# Download the APK
echo ""
echo "📥 Downloading APK..."
OUTPUT_DIR="$(pwd)"
APK_FILE="$OUTPUT_DIR/ffci-preview-$(date +%Y%m%d-%H%M%S).apk"

if eas build:download --platform android --id "$BUILD_ID" --output "$APK_FILE" 2>/dev/null; then
    echo "✅ APK downloaded successfully!"
    echo "📱 File: $APK_FILE"
else
    echo "⚠️  Automatic download failed, trying alternative method..."
    # Try downloading to current directory with default name
    if eas build:download --platform android --id "$BUILD_ID" 2>/dev/null; then
        # Find the downloaded file
        DOWNLOADED_APK=$(find . -name "*.apk" -type f -newer "$LOG_FILE" | head -1)
        if [ -n "$DOWNLOADED_APK" ]; then
            mv "$DOWNLOADED_APK" "$APK_FILE"
            echo "✅ APK downloaded successfully!"
            echo "📱 File: $APK_FILE"
        else
            echo "❌ Could not locate downloaded APK"
            echo "💡 You can download manually from: https://expo.dev/accounts/fiveq-innovations/projects/ffci-app/builds/$BUILD_ID"
            exit 1
        fi
    else
        echo "❌ Failed to download APK automatically"
        echo "💡 You can download manually from: https://expo.dev/accounts/fiveq-innovations/projects/ffci-app/builds/$BUILD_ID"
        exit 1
    fi
fi

echo "✅ APK downloaded successfully!"
echo "📱 File: $APK_FILE"
echo "🔗 Build URL: https://expo.dev/accounts/fiveq-innovations/projects/ffci-app/builds/$BUILD_ID"

# Cleanup
rm -f "$BUILD_ID_FILE"

