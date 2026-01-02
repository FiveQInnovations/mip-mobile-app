#!/bin/bash

# Upload APK to BrowserStack App Live
# 
# Usage:
#   ./scripts/upload-to-browserstack.sh <apk-file-path>
#   ./scripts/upload-to-browserstack.sh --url <apk-url>
#   ./scripts/upload-to-browserstack.sh --custom-id <id> <apk-file-path>
# 
# Environment variables:
#   BROWSERSTACK_USERNAME - BrowserStack username (required)
#   BROWSERSTACK_ACCESS_KEY - BrowserStack access key (required)

set -e

cd "$(dirname "$0")/.."

BROWSERSTACK_API_URL="https://api-cloud.browserstack.com/app-live/upload"

# Load .env file if it exists
if [ -f .env ]; then
    set -a
    source .env
    set +a
fi

# Check for credentials
if [ -z "$BROWSERSTACK_USERNAME" ] || [ -z "$BROWSERSTACK_ACCESS_KEY" ] || [ "$BROWSERSTACK_ACCESS_KEY" = "your_access_key_here" ]; then
    echo "❌ Error: BrowserStack credentials not found"
    echo ""
    echo "Please set the following environment variables:"
    echo "  BROWSERSTACK_USERNAME - Your BrowserStack username"
    echo "  BROWSERSTACK_ACCESS_KEY - Your BrowserStack access key"
    echo ""
    echo "You can either:"
    echo "  1. Create a .env file in the project root (see .env.example)"
    echo "  2. Export them as environment variables"
    echo ""
    echo "You can find these in your BrowserStack account settings:"
    echo "  https://www.browserstack.com/accounts/settings"
    exit 1
fi

# Parse arguments
CUSTOM_ID=""
USE_URL=false
APK_PATH=""
URL=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --custom-id)
            CUSTOM_ID="$2"
            shift 2
            ;;
        --url)
            USE_URL=true
            URL="$2"
            shift 2
            ;;
        *)
            if [ -z "$APK_PATH" ] && [ "$USE_URL" = false ]; then
                APK_PATH="$1"
            fi
            shift
            ;;
    esac
done

# Validate arguments
if [ "$USE_URL" = true ]; then
    if [ -z "$URL" ]; then
        echo "❌ Error: --url flag requires a URL"
        exit 1
    fi
    
    echo "📤 Uploading APK from URL: $URL"
    
    if [ -n "$CUSTOM_ID" ]; then
        DATA_JSON="{\"url\": \"$URL\", \"custom_id\": \"$CUSTOM_ID\"}"
    else
        DATA_JSON="{\"url\": \"$URL\"}"
    fi
    
    RESPONSE=$(curl -s -u "$BROWSERSTACK_USERNAME:$BROWSERSTACK_ACCESS_KEY" \
        -X POST "$BROWSERSTACK_API_URL" \
        -F "data=$DATA_JSON")
else
    if [ -z "$APK_PATH" ]; then
        echo "❌ Error: APK file path required"
        echo ""
        echo "Usage:"
        echo "  ./scripts/upload-to-browserstack.sh <apk-file-path>"
        echo "  ./scripts/upload-to-browserstack.sh --url <apk-url>"
        echo "  ./scripts/upload-to-browserstack.sh --custom-id <id> <apk-file-path>"
        exit 1
    fi
    
    if [ ! -f "$APK_PATH" ]; then
        echo "❌ Error: APK file not found: $APK_PATH"
        exit 1
    fi
    
    FILE_SIZE=$(stat -f%z "$APK_PATH" 2>/dev/null || stat -c%s "$APK_PATH" 2>/dev/null)
    FILE_SIZE_MB=$(echo "scale=2; $FILE_SIZE / 1024 / 1024" | bc)
    
    echo "📤 Uploading APK: $(basename "$APK_PATH")"
    echo "   Size: ${FILE_SIZE_MB} MB"
    
    if [ -n "$CUSTOM_ID" ]; then
        RESPONSE=$(curl -s -u "$BROWSERSTACK_USERNAME:$BROWSERSTACK_ACCESS_KEY" \
            -X POST "$BROWSERSTACK_API_URL" \
            -F "file=@$APK_PATH" \
            -F "data={\"custom_id\": \"$CUSTOM_ID\"}")
    else
        RESPONSE=$(curl -s -u "$BROWSERSTACK_USERNAME:$BROWSERSTACK_ACCESS_KEY" \
            -X POST "$BROWSERSTACK_API_URL" \
            -F "file=@$APK_PATH")
    fi
fi

# Check if upload was successful
if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Upload failed: curl command failed"
    exit 1
fi

# Parse and display result
echo ""
if echo "$RESPONSE" | grep -q "app_url\|app_id"; then
    echo "✅ Upload successful!"
    echo ""
    
    # Extract app_url if present
    APP_URL=$(echo "$RESPONSE" | grep -o '"app_url":"[^"]*"' | cut -d'"' -f4)
    if [ -n "$APP_URL" ]; then
        echo "🔗 App URL: $APP_URL"
    fi
    
    # Extract app_id if present
    APP_ID=$(echo "$RESPONSE" | grep -o '"app_id":"[^"]*"' | cut -d'"' -f4)
    if [ -n "$APP_ID" ]; then
        echo "🆔 App ID: $APP_ID"
    fi
    
    # Extract custom_id if present
    CUSTOM_ID_RESULT=$(echo "$RESPONSE" | grep -o '"custom_id":"[^"]*"' | cut -d'"' -f4)
    if [ -n "$CUSTOM_ID_RESULT" ]; then
        echo "🏷️  Custom ID: $CUSTOM_ID_RESULT"
    fi
    
    echo ""
    echo "💡 You can now test your app on BrowserStack App Live:"
    echo "   https://www.browserstack.com/app-live"
else
    echo "⚠️  Unexpected response from BrowserStack API:"
    echo "$RESPONSE"
    echo ""
    echo "The upload may have succeeded. Check your BrowserStack dashboard:"
    echo "   https://www.browserstack.com/app-live"
fi

