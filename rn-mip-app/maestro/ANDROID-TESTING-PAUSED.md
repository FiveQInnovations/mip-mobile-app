# Android Testing Paused

**Date:** 2026-01-10  
**Status:** Android Maestro testing temporarily paused due to connection issues

## Issue Summary

Maestro tests cannot connect to Android emulators due to the Maestro server component failing to install automatically on the device.

## Problem Details

### Symptoms
- Maestro CLI cannot connect to Android emulator
- Error: `Connection refused: localhost/[0:0:0:0:0:0:0:1]:7001`
- Error: `io.grpc.StatusRuntimeException: UNAVAILABLE: io exception`
- Maestro server packages (`dev.mobile.maestro`, `dev.mobile.maestro.test`) are not installed on device

### What Works
- ✅ Android emulator boots successfully (`Maestro_Pixel_6_API_30_1`)
- ✅ App installs and launches via `adb`
- ✅ Port forwarding is set up correctly (`adb forward tcp:7001 tcp:7001`)
- ✅ Device is detected and responsive (`adb devices` shows device)

### What Doesn't Work
- ❌ Maestro server component auto-installation
- ❌ Maestro CLI connection to device
- ❌ Running Maestro tests on Android emulator

## Attempted Solutions

1. **Port Forwarding**: Set up `adb forward tcp:7001 tcp:7001` - no effect
2. **Killing Stale Processes**: Checked for and killed stale Maestro processes on port 7001 - no stale processes found
3. **Waiting Longer**: Increased wait times after app launch (5s → 15s) - no effect
4. **Emulator Restart**: Restarted emulator fresh - no effect
5. **Hidden API Access**: Enabled hidden API access (`adb shell settings put global hidden_api_policy 1`) - no effect
6. **Maestro MCP Tools**: Tried using Maestro MCP server tools - same connection error

## Environment Details

- **Maestro Version**: 2.0.10
- **Emulator**: `Maestro_Pixel_6_API_30_1` (API 30)
- **Device ID**: `emulator-5554`
- **Android SDK**: `/Users/anthony/Library/Android/sdk`
- **Locale**: en-US (not the issue)

## Root Cause

Maestro's server component (`dev.mobile.maestro`) should automatically install when `maestro test` is first run, but this auto-installation is failing. The Maestro CLI expects to connect to a gRPC server running on port 7001 on the device, but that server never gets installed/started.

## Decision

**Pause Android testing for now** and focus on iOS testing, which works reliably.

## Next Steps (When Resuming Android Testing)

1. **Update Maestro**: Check if newer Maestro versions fix the auto-installation issue
2. **Manual Server Installation**: Investigate if Maestro server APK can be manually installed
3. **Maestro Cloud**: Consider using Maestro Cloud service instead of local testing
4. **Alternative Tools**: Evaluate alternative Android testing tools if Maestro continues to have issues
5. **Check Maestro Issues**: Review Maestro GitHub issues for similar problems and solutions

## Related Files

- Test file: `maestro/flows/homepage-loads-android.yaml`
- Test script: `scripts/run-maestro-android.sh`
- Previous successful testing: See ticket `016-reliable-android-emulator-local.md` (was working previously)

## Notes

- iOS testing continues to work reliably
- Android app builds and runs successfully - the issue is purely with Maestro's connection to the emulator
- This is a known issue with Maestro on Android emulators in some environments
