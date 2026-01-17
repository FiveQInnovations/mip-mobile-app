# Maestro Tests

This directory contains Maestro end-to-end tests for the React Native app.

## ⚠️ Android Testing Status

**Android testing is currently paused** due to Maestro connection issues. See [ANDROID-TESTING-PAUSED.md](./ANDROID-TESTING-PAUSED.md) for details.

iOS testing continues to work reliably.

## Setup

1. **Install Maestro**: Follow instructions at https://maestro.dev
2. **Build native apps**: Run `npm run build:ios:release` (first build takes 5-10 minutes)
   - This uses iPhone 16 simulator (UDID: `D9DE6784-CB62-4AC3-A686-4D445A0E7B57`)
   - **DO NOT use `npx expo run:ios`** - it causes stale code issues
3. **Start dev server**: Not needed for Release builds (standalone app)

## Running Tests

```bash
# Run all tests
npm run test:maestro

# Run iOS homepage test
npm run test:maestro:ios

# Run with specific device
maestro --udid <DEVICE_ID> test maestro/flows/homepage-loads.yaml
```

## Test Files

- `flows/homepage-loads.yaml` - Tests that the homepage loads and displays correctly (iOS)
- `flows/homepage-loads-android.yaml` - Android-specific homepage test
- `flows/homepage-sanity-check-browserstack.yaml` - Simple sanity check for BrowserStack testing

## BrowserStack Testing

For testing on BrowserStack cloud devices, see [BrowserStack Testing Guide](./BROWSERSTACK.md).

## Notes

- Tests require native apps to be built in Release mode
- iOS tests use `launchApp` which works reliably
- **Standard Simulator**: iPhone 16 (`D9DE6784-CB62-4AC3-A686-4D445A0E7B57`)
- First native build takes 5-10 minutes, subsequent builds are faster
- **DO NOT use `npx expo run:ios`** - always use `npm run build:ios:release`

