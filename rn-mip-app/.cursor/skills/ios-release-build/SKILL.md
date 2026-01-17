---
name: ios-release-build
description: Build iOS Release configuration for simulator. Use when building the app for testing, preparing release builds, or before running Maestro tests.
---

# iOS Release Build

## When to Use
- Before running Maestro UI tests
- When user asks to "build the app" or "build release"
- When preparing standalone app for testing
- After ANY code changes to verify they work

## Standard Simulator

**Always use iPhone 16:** `D9DE6784-CB62-4AC3-A686-4D445A0E7B57`

This prevents issues with stale builds on wrong simulators.

## Build Command

```bash
cd rn-mip-app
npm run build:ios:release
```

This runs `./scripts/build-ios-release.sh` which:
1. Boots the iPhone 16 simulator if needed
2. Runs `clean build` in Release configuration (ensures no stale code)
3. Installs the app on iPhone 16
4. Launches the app

## DO NOT USE

**Never use `npx expo run:ios`** - it causes stale code issues and may target wrong simulators.

## Manual Install/Launch (if needed)

If you need to reinstall without rebuilding:
```bash
cd rn-mip-app

# Install on iPhone 16
xcrun simctl install D9DE6784-CB62-4AC3-A686-4D445A0E7B57 ios/build/Build/Products/Release-iphonesimulator/FFCIMobile.app

# Launch the app
xcrun simctl launch D9DE6784-CB62-4AC3-A686-4D445A0E7B57 com.fiveq.ffci
```

## Take Screenshot

```bash
xcrun simctl io D9DE6784-CB62-4AC3-A686-4D445A0E7B57 screenshot /tmp/screenshot.png
```

## Verify Build

Check app bundle exists:
```bash
ls ios/build/Build/Products/Release-iphonesimulator/FFCIMobile.app
```
