# Deployment Workflow

Complete guide for deploying the FFCI mobile app to real devices via EAS Build and BrowserStack.

## Overview

This workflow ensures consistent, reliable deployments by:
1. **Pre-build validation** - Catches dependency issues before starting EAS build
2. **EAS Build** - Creates Android APK using Expo Application Services
3. **BrowserStack upload** - Uploads APK for testing on real devices

### Deployment Options

**Option 1: Automated Webhook Workflow (Recommended)**
- Set up webhook server once
- Automatically downloads and uploads builds when they complete
- No manual intervention needed after initial setup
- Best for: Regular builds, CI/CD workflows

**Option 2: Manual Script Workflow**
- Run deployment script when needed
- Full control over when builds happen
- Best for: One-off builds, testing new features

## Prerequisites

### Required Tools
- Node.js 20.18.0 (managed via `mise`)
- EAS CLI: `npm install -g eas-cli`
- Maestro (for testing): Follow [Maestro installation guide](https://maestro.dev)

### Required Accounts
- **EAS Account**: Expo Application Services account (Starter plan: $20/month)
- **BrowserStack Account**: For cloud device testing

### Required Credentials
Set these environment variables (or create `.env` file):
```bash
BROWSERSTACK_USERNAME=your_username
BROWSERSTACK_ACCESS_KEY=your_access_key
WEBHOOK_SECRET=your_webhook_secret  # For automated workflow only
```

**Note:** For the automated webhook workflow, you also need `WEBHOOK_SECRET`. Generate one with:
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

## Quick Start

### Option 1: Automated Webhook Workflow (Recommended)

**One-time setup:**

1. **Set up webhook server:**
   ```bash
   cd rn-mip-app
   cp .env.example .env
   # Edit .env and add WEBHOOK_SECRET (generate with command above)
   ```

2. **Start webhook server:**
   ```bash
   npm run webhook:server
   ```

3. **Expose with tunnel** (in another terminal):
   ```bash
   # Option A: Using ngrok (requires auth token)
   ngrok http 3000
   
   # Option B: Using localtunnel (no auth needed)
   npx localtunnel --port 3000
   ```

4. **Create EAS webhook:**
   ```bash
   cd rn-mip-app
   WEBHOOK_SECRET=$(node -e "require('dotenv').config(); console.log(process.env.WEBHOOK_SECRET)") && \
   eas webhook:create \
     --url <your-tunnel-url>/webhook \
     --secret "$WEBHOOK_SECRET" \
     --event BUILD \
     --non-interactive
   ```

**After setup, builds are automated:**
- Trigger EAS build: `eas build --profile preview --platform android`
- Webhook server automatically downloads APK when build completes
- Webhook server automatically uploads to BrowserStack
- No manual steps needed!

See **[EAS Webhook Running Guide](../rn-mip-app/docs/eas-webhook-running-guide.md)** for detailed setup instructions.

### Option 2: Manual Script Workflow

Run the complete deployment workflow:

```bash
cd rn-mip-app
./scripts/deploy-to-browserstack.sh
```

This script:
1. ✅ Runs pre-build validation checks
2. ✅ Builds Android preview APK with EAS
3. ✅ Downloads APK when build completes
4. ✅ Uploads APK to BrowserStack App Live

### Step-by-Step Manual Process

If you prefer to run steps manually:

#### Step 1: Pre-build Validation

```bash
cd rn-mip-app
./scripts/pre-build-check.sh
```

**What it does:**
- Verifies `package-lock.json` exists
- Runs `npm ci` to catch dependency conflicts (same as EAS Build)
- Runs `expo-doctor` to check for common issues

**Why this matters:** EAS builds take 20+ minutes. Catching dependency conflicts locally (which fail in ~1 minute) saves significant time.

#### Step 2: Build Android APK

```bash
cd rn-mip-app
./scripts/build-and-download-preview.sh
```

**What it does:**
- Runs pre-build validation automatically
- Starts EAS build with `preview` profile
- Monitors build status
- Downloads APK when build completes

**Build profiles:**
- `preview` - Standalone build for testing (BrowserStack, physical devices)
- `development` - Requires dev server (for local development)
- `production` - App store releases

**Important:** Use `preview` profile for BrowserStack testing. It's a standalone build that doesn't require a dev server.

#### Step 3: Upload to BrowserStack

```bash
cd rn-mip-app
./scripts/upload-to-browserstack.sh path/to/your-app.apk
```

**What it does:**
- Uploads APK to BrowserStack App Live
- Returns app URL for testing

**Alternative:** Upload manually via BrowserStack dashboard:
1. Go to [BrowserStack App Live](https://www.browserstack.com/app-live)
2. Click "Uploaded Apps" → "Upload"
3. Select your APK file

## Build Configuration

### EAS Configuration (`eas.json`)

```json
{
  "build": {
    "preview": {
      "distribution": "internal",
      "env": {
        "NPM_CONFIG_LEGACY_PEER_DEPS": "true"
      }
    }
  }
}
```

**Key settings:**
- `NPM_CONFIG_LEGACY_PEER_DEPS`: Handles React version peer dependency conflicts
- `distribution: "internal"`: Allows internal distribution (not app store)

### Package Configuration (`package.json`)

**Critical:** React version must be exactly `19.1.0` to match React Native 0.81.5 requirements.

```json
{
  "dependencies": {
    "react": "19.1.0",
    "react-native": "0.81.5"
  }
}
```

## Testing on BrowserStack

### After Upload

1. **Open BrowserStack App Live**: https://www.browserstack.com/app-live
2. **Select your uploaded app** from "Uploaded Apps"
3. **Choose an Android device** (e.g., Samsung Galaxy S25)
4. **Test core functionality:**
   - ✅ App launches without crashes
   - ✅ Homepage loads correctly
   - ✅ Navigation between tabs works
   - ✅ Resources page loads
   - ✅ API authentication works
   - ✅ Performance is acceptable

### Manual Testing Checklist

- [ ] App launches successfully
- [ ] Homepage displays all sections:
  - Quick Tasks (Prayer Request, Chaplain Request, Resources, Donate)
  - Get Connected (Find a Chapter, Upcoming Events)
  - Featured section
  - Bottom navigation bar
- [ ] Navigation works between tabs
- [ ] Resources page loads (previously had loading delay issues)
- [ ] API authentication works correctly
- [ ] No crashes or errors

## Common Issues and Solutions

### Build Fails with Dependency Errors

**Error:** `ERESOLVE could not resolve` or peer dependency conflicts

**Solution:**
1. Run `./scripts/pre-build-check.sh` locally to reproduce
2. Fix dependency conflicts (usually React version mismatch)
3. Ensure React is exactly `19.1.0` (required by React Native 0.81.5)
4. Run `npm install --legacy-peer-deps` if needed
5. Retry build

### App Crashes on BrowserStack

**Error:** React version mismatch or app won't launch

**Solution:**
1. Verify you're using `preview` profile (not `development`)
2. Check React version is `19.1.0` in `package.json`
3. Ensure `NPM_CONFIG_LEGACY_PEER_DEPS` is set in `eas.json`
4. Rebuild with fixed configuration

### Build Takes Too Long

**Issue:** EAS builds can take 20+ minutes

**Solution:**
- Always run pre-build validation first (`./scripts/pre-build-check.sh`)
- This catches dependency issues in ~1 minute instead of failing after 20 minutes
- Fix issues locally before starting EAS build

### BrowserStack Upload Fails

**Error:** Credentials not found or upload fails

**Solution:**
1. Verify BrowserStack credentials are set:
   ```bash
   echo $BROWSERSTACK_USERNAME
   echo $BROWSERSTACK_ACCESS_KEY
   ```
2. Create `.env` file if needed:
   ```bash
   BROWSERSTACK_USERNAME=your_username
   BROWSERSTACK_ACCESS_KEY=your_access_key
   ```
3. Or upload manually via BrowserStack dashboard

### Webhook Not Processing Builds

**Issue:** Builds complete but aren't automatically uploaded

**Solution:**
1. Verify webhook server is running: `ps aux | grep eas-webhook-server`
2. Check webhook server logs for errors
3. Verify EAS webhook is configured: `eas webhook:list`
4. Ensure tunnel is running (ngrok/localtunnel)
5. Check that `WEBHOOK_SECRET` matches in `.env` and EAS webhook
6. Verify BrowserStack credentials are set in `.env` file
7. Check webhook server logs for download/upload errors

## Scripts Reference

### `./scripts/pre-build-check.sh`
- Validates dependencies before EAS build
- Catches issues early (saves time)
- Run before every build

### `./scripts/build-and-download-preview.sh`
- Builds Android preview APK with EAS
- Monitors build status
- Downloads APK when complete

### `./scripts/deploy-to-browserstack.sh`
- Complete manual deployment workflow
- Runs validation, build, and upload
- Use when webhook automation isn't available

### `./scripts/upload-to-browserstack.sh`
- Uploads APK to BrowserStack App Live
- Requires BrowserStack credentials
- Returns app URL for testing

### `./scripts/eas-webhook-server.js`
- Webhook server for automated deployments
- Listens for EAS build completion events
- Automatically downloads and uploads builds
- Run with: `npm run webhook:server`

## Best Practices

1. **Always run pre-build validation** before starting EAS build
2. **Use `preview` profile** for BrowserStack testing (standalone build)
3. **Keep React version at `19.1.0`** (required by React Native 0.81.5)
4. **Test locally first** (iOS simulator, Maestro tests) before deploying
5. **Use automated webhook workflow** for regular builds (set up once, runs automatically)
6. **Use manual script workflow** for one-off builds or when webhook isn't available
7. **Keep webhook server running** if using automated workflow (or run in background)

## Related Documentation

- **[EAS Webhook Setup Guide](../rn-mip-app/docs/eas-webhook-setup.md)** - Complete webhook setup instructions
- **[EAS Webhook Running Guide](../rn-mip-app/docs/eas-webhook-running-guide.md)** - Quick reference for webhook server
- **[How to Build Android](./how-to-build-android.md)** - Build type reference
- **[iOS Simulator Network Setup](../rn-mip-app/docs/ios-simulator-network-setup.md)** - Local development setup
- **[Maestro Testing Guide](../rn-mip-app/maestro/README.md)** - UI testing

## Troubleshooting

If you encounter issues not covered here:

1. **Check build logs**: EAS build page shows detailed logs
2. **Run pre-build validation**: `./scripts/pre-build-check.sh`
3. **Verify configuration**: Check `eas.json` and `package.json`
4. **Test locally first**: iOS simulator and Maestro tests
5. **Check BrowserStack logs**: Device logs show runtime errors

