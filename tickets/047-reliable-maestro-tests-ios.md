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
- [ ] Verify each individual test passes 5 times consecutively
- [ ] Verify the full test suite passes 3 times consecutively

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
1. `home-action-hub.yaml` - Comprehensive homepage verification
   - Verifies "Firefighters for Christ International" title
   - Checks all Quick Tasks (Prayer Request, Chaplain Request, Resources, Donate)
   - Verifies Get Connected section (Find a Chapter, Upcoming Events)
   - Checks Featured section
   - Takes screenshot for documentation
   
2. `tab-switch-from-home.yaml` - Tests tab switching via Quick Task button
   - Taps Resources Quick Task button
   - Verifies tab bar remains visible
   - Verifies Resources tab is selected
   - Verifies Resources content is displayed

**Prerequisites:**
- iOS Simulator must be booted and available
- App must be built for iOS (`npx expo run:ios`)
- **Metro bundler must be running** (`npm start` or `npx expo start`)
- **DDEV proxy may be needed** if using local DDEV backend (`node scripts/ddev-proxy.js [port]`)
- Maestro will use `launchApp` to launch the app automatically

**Note:** iOS tests use `_setup.yaml` which leverages `launchApp` - this works reliably on iOS simulators (unlike Android where we use `adb` launch). However, the app requires Metro bundler to be running to load JavaScript, and may require the DDEV proxy if testing against a local backend.

### Test Status (2026-01-03)

**Current Issue:** Tests are failing because the app isn't rendering content after launch. 

**Setup Status:**
- ✅ Metro bundler is running (port 8081)
- ✅ iOS Simulator is booted
- ✅ Test suite script created
- ✅ Individual test files updated
- ❌ App not loading content (blank screen)

**Investigation Needed:**
- App may need manual launch first to connect to Metro
- App may need to be rebuilt for iOS (`npx expo run:ios`)
- Network/API connectivity may need verification
- App may be showing error state that's not being detected

**Test Requirements:**
- Each individual test must pass 5 times consecutively to be marked as stable
- Full test suite (`npm run test:maestro:ios:all`) must pass 3 times consecutively before marking suite as stable

**Test Stability Criteria:**
1. **Individual Test Stability:** A test is considered stable only after passing 5 consecutive runs
2. **Suite Stability:** The test suite is considered stable only after the full suite passes 3 consecutive runs
3. **Both criteria must be met:** Individual tests must be stable AND the suite must pass 3 times

**Usage:**
```bash
# Run individual test 5 times to verify stability
for i in {1..5}; do
  maestro test maestro/flows/home-action-hub.yaml
done

# Run full test suite 3 times to verify suite stability
for i in {1..3}; do
  npm run test:maestro:ios:all
done
```
