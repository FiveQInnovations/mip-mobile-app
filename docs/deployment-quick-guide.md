# Deployment Quick Guide

Complete workflow for making code changes, testing locally, and deploying to BrowserStack.

## Prerequisites

- Node.js 20.18.0 (via `mise`)
- EAS CLI installed: `npm install -g eas-cli`
- BrowserStack credentials set (in `.env` or environment variables)
- iOS Simulator available

## Complete Workflow

### 1. Make Code Changes

Edit your code files as needed. For example, modify `rn-mip-app/components/HomeScreen.tsx`.

### 2. Verify Locally on iOS Simulator

**Start Metro bundler:**
```bash
cd rn-mip-app
mise exec -- bash -c "export LANG=en_US.UTF-8 && npx expo start --ios --clear"
```

**Verify changes:**
- App should auto-reload in iOS Simulator
- If not, press `Cmd+R` to reload
- Verify your changes appear correctly

**Run Maestro tests:**
```bash
npm run test:maestro:ios
```

> **Important:** Always run tests locally before starting an EAS build. EAS builds take ~12 minutes and consume build minutes. Verify your changes work locally first to avoid wasting time and resources on builds that will fail.

### 3. Build Android Preview APK with EAS

**Run the complete deployment script:**
```bash
cd rn-mip-app
./scripts/deploy-to-browserstack.sh
```

This script automatically:
- ✅ Runs pre-build validation
- ✅ Builds Android preview APK (~12 minutes)
- ✅ Downloads APK when complete
- ✅ Uploads to BrowserStack (if credentials configured)

**Or run steps manually:**

1. **Pre-build validation:**
   ```bash
   ./scripts/pre-build-check.sh
   ```

2. **Build APK:**
   ```bash
   ./scripts/build-and-download-preview.sh
   ```
   
   Note: The download step may fail. If so, get the APK URL from:
   ```bash
   eas build:list --platform android --limit 1 --non-interactive
   ```
   
   Then download manually:
   ```bash
   curl -L "<Application Archive URL>" -o "ffci-preview-$(date +%Y%m%d-%H%M%S).apk"
   ```

### 4. Upload to BrowserStack

**If using the deployment script:** Upload happens automatically.

**If uploading manually:**
```bash
./scripts/upload-to-browserstack.sh ffci-preview-YYYYMMDD-HHMMSS.apk
```

**Or upload via BrowserStack dashboard:**
1. Go to https://www.browserstack.com/app-live
2. Click "Uploaded Apps" → "Upload"
3. Select your APK file

### 5. Test on BrowserStack

1. Open https://www.browserstack.com/app-live
2. Select your uploaded app
3. Choose an Android device
4. Verify:
   - App launches successfully
   - Your changes are visible
   - Core functionality works

## Quick Reference

### Common Commands

```bash
# Start iOS simulator with Metro
cd rn-mip-app
mise exec -- bash -c "export LANG=en_US.UTF-8 && npx expo start --ios --clear"

# Run Maestro tests
npm run test:maestro:ios

# Full deployment workflow
./scripts/deploy-to-browserstack.sh

# Pre-build validation only
./scripts/pre-build-check.sh

# Build APK only
./scripts/build-and-download-preview.sh

# Upload APK to BrowserStack
./scripts/upload-to-browserstack.sh <apk-file>
```

### Build Profiles

- **`preview`** - Standalone build for BrowserStack/testing (no dev server needed)
- **`development`** - Requires dev server (for local development)
- **`production`** - App store releases

**Always use `preview` profile for BrowserStack testing.**

### Troubleshooting

**Pre-build validation fails:**
- Run `npm install --legacy-peer-deps` to sync `package-lock.json`
- Ensure React version is exactly `19.1.0`

**Build fails:**
- Check build logs at the EAS build URL
- Run pre-build validation locally first
- Verify `eas.json` has `NPM_CONFIG_LEGACY_PEER_DEPS` set

**APK download fails:**
- Use `eas build:list` to get Application Archive URL
- Download manually with `curl`

**BrowserStack upload fails:**
- Verify credentials in `.env` or environment variables
- Check file size (should be ~92 MB)
- Try uploading via BrowserStack dashboard

## Time Estimates

- **Local testing:** 1-2 minutes
- **EAS Build:** ~12 minutes
- **BrowserStack upload:** ~30 seconds
- **Total:** ~15 minutes

## Related Documentation

- **[Deployment Workflow](./deployment-workflow.md)** - Detailed deployment guide
- **[How to Build Android](./how-to-build-android.md)** - Build type reference
- **[iOS Simulator Network Setup](../rn-mip-app/docs/ios-simulator-network-setup.md)** - Local development setup

