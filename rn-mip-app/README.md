# FFCI Mobile App

React Native mobile app for FFCI built with Expo.

> Note: This README is maintained manually.

## Quick Start

### Prerequisites

- Node.js 20.18.0 (managed via `mise`)
- DDEV running with `ws-ffci-copy` project
- iOS Simulator or physical device

### Setup Steps

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Start DDEV:**
   ```bash
   cd ../sites/ws-ffci-copy
   ddev start
   ```

3. **Start HTTP proxy** (required for iOS simulator):
   ```bash
   node scripts/ddev-proxy.js 55038 &
   ```
   
   > **Why?** iOS simulator cannot reach `localhost`. The proxy forwards requests from your Mac's IP to DDEV on localhost.

4. **Start Metro bundler:**
   ```bash
   mise exec -- bash -c "export LANG=en_US.UTF-8 && npx expo start --ios --clear"
   ```

5. **App should launch automatically** in the simulator.

## Troubleshooting

If you see "Network request failed":

1. Verify proxy is running: `ps aux | grep ddev-proxy`
2. Check your Mac's IP hasn't changed: `ifconfig | grep "inet " | grep -v 127.0.0.1`
3. Update `lib/config.ts` if IP changed
4. Restart Metro with `--clear` flag

See **[docs/ios-simulator-network-setup.md](./docs/ios-simulator-network-setup.md)** for detailed troubleshooting guide.

## Web Development

The app can run in a web browser for development. See **[Web Development Guide](./docs/web-development-guide.md)** for complete setup instructions.

**Quick Start:**
1. Start DDEV: `cd ../sites/ws-ffci && ddev start`
2. Start web app: `npm run web`
3. Opens at http://localhost:8081

**Note:** When running on web platform, the app automatically uses the local DDEV API 
(`http://ws-ffci.ddev.site`) via `configs/ffci-local.json`. HTTP is used instead of HTTPS 
to avoid browser certificate warnings with DDEV's self-signed certificates.

**Important:** Native apps (iOS/Android) continue to use the production API 
(`https://ffci.fiveq.dev`) as configured in `configs/ffci.json`.

## Scripts

### Development
- `npm start` - Start Metro bundler
- `npm run ios` - Build and run on iOS
- `npm run android` - Build and run on Android
- `npm run web` - Run in web browser

### Testing
- `npm run test:maestro:ios` - Run Maestro UI tests on iOS
- `npm run test:maestro:android` - Run Maestro UI tests on Android
- `npm run test:maestro` - Run all Maestro tests

### Deployment
- `./scripts/pre-build-check.sh` - Validate dependencies before EAS build
- `./scripts/build-and-download-preview.sh` - Build Android preview APK with EAS
- `./scripts/deploy-to-browserstack.sh` - Complete deployment workflow (build + upload)
- `./scripts/upload-to-browserstack.sh <apk>` - Upload APK to BrowserStack

See **[deployment-workflow.md](../docs/deployment-workflow.md)** for complete deployment guide.

## Configuration

- **API Config**: `lib/config.ts`
- **API Client**: `lib/api.ts`
- **App Config**: `app.json`

## Documentation

- **[Web Development Guide](./docs/web-development-guide.md)** - Complete guide for running in web browser with local DDEV
- **[Deployment Workflow](../docs/deployment-workflow.md)** - Complete guide for deploying to BrowserStack
- **[How to Build Android](../docs/how-to-build-android.md)** - Android build reference
- **[iOS Simulator Network Setup](./docs/ios-simulator-network-setup.md)** - Complete guide for network connectivity
- **[EAS Webhook Setup](./docs/eas-webhook-setup.md)** - Complete webhook setup and configuration
- **[EAS Webhook Running Guide](./docs/eas-webhook-running-guide.md)** - Quick reference for starting/stopping webhook server
- **[TODO](./docs/TODO.md)** - Items to revisit (images, internal links, etc.)
- **[TEMP_SETUP_STATUS.md](./TEMP_SETUP_STATUS.md)** - Development status and notes

