---
status: in-progress
area: rn-mip-app
phase: testing
created: 2026-01-03
---

# Reliable Maestro Tests for iOS

## Context
Building on the work from Android testing ([016](016-reliable-android-emulator-local.md) and [046](046-reliable-maestro-tests-android.md)), we have iOS-specific Maestro test flows that use `launchApp` and `_setup.yaml` which work reliably on iOS simulators. We need a single command that runs all stable iOS tests reliably, making it easy to verify the app works correctly on iOS.

**Related Tickets:**
- [016](016-reliable-android-emulator-local.md) - Proved Android emulator reliability with Maestro testing
- [046](046-reliable-maestro-tests-android.md) - Reliable Maestro Tests for Android (completed)
- [032](032-maestro-content-page-test.md) - Maestro Test: Content Page Rendering
- [033](033-maestro-collection-test.md) - Maestro Test: Collection Grid and Navigation
- [036](036-maestro-error-handling-test.md) - Maestro Test: Error Handling

**Current Stable iOS Tests:**
- `maestro/flows/home-action-hub.yaml` - Comprehensive homepage test (uses iOS setup flow)
- `maestro/flows/tab-switch-from-home.yaml` - Tab switching test (uses iOS setup flow)

**Shared Setup:**
- `maestro/flows/_setup.yaml` - Shared setup flow (uses launchApp, works reliably on iOS simulators)

**Test Classification:**
- **Stable:** Tests that use `_setup.yaml` with `launchApp`, which works reliably on iOS simulators
- **iOS-specific:** Tests designed for iOS that leverage `launchApp` functionality

**Existing Scripts:**
- `npm run test:maestro:ios` - Currently runs only `home-action-hub.yaml`

## Tasks
- [x] Identify all stable iOS test flows
- [x] Create a script to run all stable iOS tests in sequence
- [x] Add npm script for easy access: `npm run test:maestro:ios:all`
- [x] Document which tests are considered "stable" vs "experimental"
- [x] Ensure proper error handling and reporting for test suite runs
- [ ] Verify the command works reliably (run 3+ times successfully)

## Notes

### Test Suite Script Created (2026-01-03)

**Created:** `scripts/run-maestro-ios-all.sh`

**Features:**
- Runs all 2 stable iOS tests in sequence
- Uses Maestro's built-in `launchApp` (works reliably on iOS)
- Provides detailed progress output
- Tracks pass/fail counts
- Exits with appropriate status code
- Handles stale Maestro processes

**NPM Script:** `npm run test:maestro:ios:all`

**Stable Tests Included:**
1. `home-action-hub.yaml` - Comprehensive homepage verification (checks all Quick Tasks, Get Connected section, Featured)
2. `tab-switch-from-home.yaml` - Tests tab switching via Quick Task button

**Prerequisites:**
- iOS Simulator must be booted and available
- App must be built for iOS (`npx expo run:ios`)
- Dev server should be running (`npm start`)
- Maestro will use `launchApp` to launch the app automatically

**Note:** iOS tests use `_setup.yaml` which leverages `launchApp` - this works reliably on iOS simulators (unlike Android where we use `adb` launch).
