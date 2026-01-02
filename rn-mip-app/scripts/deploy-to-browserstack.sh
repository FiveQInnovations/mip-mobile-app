#!/bin/bash

# Complete deployment workflow: Build Android APK with EAS and upload to BrowserStack
# This script handles the full process from validation to BrowserStack upload
#
# Usage:
#   ./scripts/deploy-to-browserstack.sh
#   ./scripts/deploy-to-browserstack.sh --skip-validation
#   ./scripts/deploy-to-browserstack.sh --skip-upload
#
# Environment variables:
#   BROWSERSTACK_USERNAME - BrowserStack username (required for upload)
#   BROWSERSTACK_ACCESS_KEY - BrowserStack access key (required for upload)

set -e

cd "$(dirname "$0")/.."

SKIP_VALIDATION=false
SKIP_UPLOAD=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-validation)
            SKIP_VALIDATION=true
            shift
            ;;
        --skip-upload)
            SKIP_UPLOAD=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--skip-validation] [--skip-upload]"
            exit 1
            ;;
    esac
done

echo "🚀 FFCI Mobile App - BrowserStack Deployment"
echo "=============================================="
echo ""

# Step 1: Pre-build validation
if [ "$SKIP_VALIDATION" = false ]; then
    echo "📋 Step 1: Pre-build validation"
    echo "--------------------------------"
    if ! ./scripts/pre-build-check.sh; then
        echo ""
        echo "❌ Pre-build validation failed. Fix the issues above before proceeding."
        echo "   To skip validation, run: $0 --skip-validation"
        exit 1
    fi
    echo ""
else
    echo "⏭️  Skipping pre-build validation (--skip-validation flag set)"
    echo ""
fi

# Step 2: Build Android preview APK
echo "🔨 Step 2: Building Android preview APK with EAS"
echo "-----------------------------------------------"
BUILD_PROFILE="preview"
PLATFORM="android"

echo "Starting EAS build..."
echo "  Profile: $BUILD_PROFILE"
echo "  Platform: $PLATFORM"
echo ""

# Run build script which handles the full build process
if ! ./scripts/build-and-download-preview.sh; then
    echo ""
    echo "❌ Build failed. Check the logs above for details."
    exit 1
fi

# Extract APK file path from build script output or find latest
APK_FILE=$(find . -name "ffci-preview-*.apk" -type f -mtime -1 | head -1)

if [ -z "$APK_FILE" ]; then
    echo "❌ Could not find downloaded APK file"
    echo "   Check the build output above for the APK location"
    exit 1
fi

echo ""
echo "✅ Build completed successfully!"
echo "📱 APK: $APK_FILE"
echo ""

# Step 3: Upload to BrowserStack
if [ "$SKIP_UPLOAD" = false ]; then
    echo "📤 Step 3: Uploading to BrowserStack"
    echo "------------------------------------"
    
    # Load .env file if it exists
    if [ -f .env ]; then
        set -a
        source .env
        set +a
    fi
    
    # Check for credentials
    if [ -z "$BROWSERSTACK_USERNAME" ] || [ -z "$BROWSERSTACK_ACCESS_KEY" ] || [ "$BROWSERSTACK_ACCESS_KEY" = "your_access_key_here" ]; then
        echo "⚠️  BrowserStack credentials not found. Skipping upload."
        echo ""
        echo "To upload to BrowserStack, set these environment variables:"
        echo "  BROWSERSTACK_USERNAME - Your BrowserStack username"
        echo "  BROWSERSTACK_ACCESS_KEY - Your BrowserStack access key"
        echo ""
        echo "You can either:"
        echo "  1. Create a .env file in the project root"
        echo "  2. Export them as environment variables"
        echo ""
        echo "To skip upload, run: $0 --skip-upload"
        echo ""
        echo "✅ Deployment complete! APK ready for manual upload:"
        echo "   $APK_FILE"
        exit 0
    fi
    
    # Upload to BrowserStack
    if ! ./scripts/upload-to-browserstack.sh "$APK_FILE"; then
        echo ""
        echo "❌ BrowserStack upload failed. APK is still available locally:"
        echo "   $APK_FILE"
        exit 1
    fi
    
    echo ""
    echo "✅ Upload completed successfully!"
    echo ""
else
    echo "⏭️  Skipping BrowserStack upload (--skip-upload flag set)"
    echo ""
fi

echo "✅ Deployment complete!"
echo ""
echo "📱 Next steps:"
echo "   1. Open BrowserStack App Live: https://www.browserstack.com/app-live"
echo "   2. Select your uploaded app"
echo "   3. Choose an Android device"
echo "   4. Test the app functionality"
echo ""
echo "📄 APK location: $APK_FILE"

