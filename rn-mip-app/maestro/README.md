# Maestro Tests

This directory contains Maestro end-to-end tests for the React Native app.

## Setup

1. **Install Maestro**: Follow instructions at https://maestro.dev
2. **Build native apps**: Run `npx expo run:ios` (first build takes 5-10 minutes)
3. **Start dev server**: Run `npm start` in a separate terminal

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

- Tests require `expo-dev-client` to be installed and native apps to be built
- iOS tests use `launchApp` which works reliably
- Always keep the dev server running (`npm start`) when testing
- First native build takes 5-10 minutes, subsequent builds are faster

