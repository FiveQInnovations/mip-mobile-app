---
name: ios-release-build
description: Build iOS Release configuration for simulator. Use when building the app for testing, preparing release builds, or before running Maestro tests.
---

# iOS Release Build

## When to Use
- Before running Maestro UI tests
- When user asks to "build the app" or "build release"
- When preparing standalone app for testing

## Prerequisites
- iOS simulator must be booted (use ios-simulator skill)
- iOS project must exist at `ios/FFCIMobile.xcworkspace`

## Build Command
```bash
cd rn-mip-app
npm run build:ios:release
```

This runs `./scripts/build-ios-release.sh` which:
1. Builds Release configuration for iphonesimulator
2. Outputs to `ios/build/Build/Products/Release-iphonesimulator/FFCIMobile.app`

## Install and Launch
```bash
# Install on booted simulator
xcrun simctl install booted ios/build/Build/Products/Release-iphonesimulator/FFCIMobile.app

# Launch the app
xcrun simctl launch booted com.fiveq.ffci
```

## Verify Build
Check app bundle exists:
```bash
ls ios/build/Build/Products/Release-iphonesimulator/FFCIMobile.app
```
