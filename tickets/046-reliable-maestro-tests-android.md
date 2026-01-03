---
status: in-progress
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
- `maestro/flows/homepage-loads-android.yaml` - Homepage verification
- `maestro/flows/resources-tab-navigation-android.yaml` - Resources tab navigation
- `maestro/flows/tab-switch-from-home.yaml` - Tab switching from home

**Existing Scripts:**
- `scripts/run-maestro-android.sh` - Single test run with adb launch
- `scripts/run-maestro-android-5x.sh` - 5 consecutive runs for reliability testing

## Tasks
- [ ] Identify all stable Android test flows
- [ ] Create a script to run all stable Android tests in sequence
- [ ] Add npm script for easy access: `npm run test:maestro:android:all`
- [ ] Document which tests are considered "stable" vs "experimental"
- [ ] Ensure proper error handling and reporting for test suite runs
- [ ] Verify the command works reliably (run 3+ times successfully)

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
