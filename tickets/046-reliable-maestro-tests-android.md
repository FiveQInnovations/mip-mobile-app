---
status: done
area: rn-mip-app
phase: testing
created: 2026-01-21
---

# Reliable Maestro Tests for Android

## Context
Building on the work from [016](016-reliable-android-emulator-local.md), we've proven Android emulator reliability and have multiple stable Maestro test flows. We need a single command that runs all stable Android tests reliably, making it easy to verify the app works correctly on Android.

**Related Tickets:**
- [016](016-reliable-android-emulator-local.md) - Proved Android emulator reliability with Maestro testing
- [032](032-maestro-content-page-test.md) - Maestro Test: Content Page Rendering
- [033](033-maestro-collection-test.md) - Maestro Test: Collection Grid and Navigation
- [036](036-maestro-error-handling-test.md) - Maestro Test: Error Handling

**Current Stable Tests:**
- `maestro/flows/homepage-loads-android.yaml` - Homepage verification (Android-specific)
- `maestro/flows/resources-tab-navigation-android.yaml` - Resources tab navigation (Android-specific, verified 5/5)
- `maestro/flows/tab-switch-from-home-android.yaml` - Tab switching from home via Quick Task (Android-specific)

**Experimental/Other Tests:**
- `maestro/flows/home-action-hub.yaml` - Comprehensive homepage test (uses iOS setup flow)
- `maestro/flows/tab-switch-from-home.yaml` - Tab switching test (uses iOS setup flow)
- `maestro/flows/_setup.yaml` - Shared setup flow (uses launchApp, not reliable on Android)

**Existing Scripts:**
- `scripts/run-maestro-android.sh` - Single test run with adb launch
- `scripts/run-maestro-android-5x.sh` - 5 consecutive runs for reliability testing

## Tasks
- [x] Identify all stable Android test flows
- [x] Create a script to run all stable Android tests in sequence
- [x] Add npm script for easy access: `npm run test:maestro:android:all`
- [x] Document which tests are considered "stable" vs "experimental"
- [x] Ensure proper error handling and reporting for test suite runs
- [x] Verify the command works reliably (run 3+ times successfully)

## Notes

### Resources Tab Navigation Test - Fixed and Verified (2026-01-03)

**Issue:** Test was failing because assertion text didn't match actual screen content.

**Fix:** Updated assertion from `"Resources for Firefighters"` to `"Resources for Firefighters and Their Families"` to match the actual page title displayed on the Resources screen.

**Verification:** Ran test 5 consecutive times - all passed successfully:
- ✅ Test 1: PASSED
- ✅ Test 2: PASSED  
- ✅ Test 3: PASSED
- ✅ Test 4: PASSED
- ✅ Test 5: PASSED

**Success Rate:** 5/5 (100%)

The test now reliably verifies:
1. Starting on Home screen (Quick Tasks visible)
2. Tapping Resources tab
3. Navigating to Resources screen (Resources for Firefighters and Their Families visible)
4. Android back button navigation
5. Returning to Home screen (Quick Tasks visible)

### Test Suite Script Created (2026-01-03)

**Created:** `scripts/run-maestro-android-all.sh`

**Features:**
- Runs all 3 stable Android tests in sequence
- Relaunches app before each test for clean state
- Provides detailed progress output
- Tracks pass/fail counts
- Exits with appropriate status code
- Handles stale Maestro processes

**NPM Script:** `npm run test:maestro:android:all`

**Stable Tests Included:**
1. `homepage-loads-android.yaml` - Verifies homepage content renders correctly
2. `resources-tab-navigation-android.yaml` - Tests Resources tab navigation and back button
3. `tab-switch-from-home-android.yaml` - Tests tab switching via Quick Task button

**Test Classification:**
- **Stable:** Tests that use `adb` launch, don't rely on `launchApp`, and have been verified to work reliably on Android
- **Experimental:** Tests that use `_setup.yaml` with `launchApp`, which is not reliable on Android emulators

### Test Suite Verification (2026-01-03)

**Verification:** Ran test suite 4 consecutive times - all passed successfully:
- ✅ Suite Run 1: PASSED (3/3 tests)
- ✅ Suite Run 2: PASSED (3/3 tests)
- ✅ Suite Run 3: PASSED (3/3 tests)
- ✅ Suite Run 4: PASSED (3/3 tests)

**Success Rate:** 4/4 suite runs (100%), 12/12 individual tests (100%)

**All Tests Verified:**
1. `homepage-loads-android.yaml` - 4/4 passes
2. `resources-tab-navigation-android.yaml` - 4/4 passes
3. `tab-switch-from-home-android.yaml` - 4/4 passes

The test suite script is reliable and ready for use!
