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

## Scripts

### Development
- `npm start` - Start Metro bundler
- `npm run ios` - Build and run on iOS
- `npm run android` - Build and run on Android

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

- **[Deployment Workflow](../docs/deployment-workflow.md)** - Complete guide for deploying to BrowserStack
- **[How to Build Android](../docs/how-to-build-android.md)** - Android build reference
- **[iOS Simulator Network Setup](./docs/ios-simulator-network-setup.md)** - Complete guide for network connectivity
- **[TODO](./docs/TODO.md)** - Items to revisit (images, internal links, etc.)
- **[TEMP_SETUP_STATUS.md](./TEMP_SETUP_STATUS.md)** - Development status and notes

