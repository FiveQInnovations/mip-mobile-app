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

### Break and Verify Test (2026-01-03)

**Purpose:** Verify that tests actually catch regressions by intentionally breaking the code and confirming tests fail.

**Test Performed:**
- Changed "Quick Tasks" → "Broken Text" in `HomeScreen.tsx`
- Rebuilt iOS app (first rebuild): **1:41.02 elapsed time** (101 seconds)
- Ran test: ✅ **Test correctly failed** - Assertion for "Quick Tasks" failed as expected
- Reverted change and rebuilt (cached rebuild): **23.77 seconds** (much faster due to caching)

**Findings:**
- ✅ Tests properly detect regressions
- ✅ iOS rebuild time: ~1:41 (101 seconds) for full rebuild, ~24 seconds for cached rebuild
- ✅ Test failure was immediate and clear - assertion failed as expected

**Key Difference: Android vs iOS Testing:**

**Android Testing:**
- Uses `adb` to launch app directly
- Installs standalone APK (no Metro bundler)
- **Full rebuild required for EVERY change** (JavaScript or native)
- No hot reload available for testing

**iOS Testing:**
- Uses `launchApp` which launches dev client app
- **Dev client CAN connect to Metro bundler** (unlike Android)
- **Metro bundler allows hot reload** for JavaScript changes
- Full rebuild (`npx expo run:ios`) only needed for:
  - Native code changes
  - Pod dependencies change
  - App configuration changes (app.json, Info.plist)
  - First build or after cleaning

**Recommendations:**
- **For JavaScript/React code changes:** Use Metro bundler - no rebuild needed!
  - Start Metro: `npm start` or `npx expo start`
  - Run tests: `maestro test` - Metro will serve updated JavaScript
  - Much faster iteration (~seconds vs ~1:41)
- **For native/config changes:** Full rebuild required (`npx expo run:ios`)
- **For test verification:** Can use Metro bundler for JS changes, rebuild only for native changes

### Standalone Build Approach (2026-01-03)

**Problem:** Metro-based testing had cached code issues where the app would show stale JavaScript even when source code was correct (e.g., showing "Broken Text" instead of "Quick Tasks").

**Solution:** Implemented standalone Release build approach (mirroring Android APK pattern) that bundles JavaScript directly into the app, eliminating Metro dependency and cached code issues.

**Implementation:**
- **Build Script:** `scripts/build-ios-release.sh` - Builds Release `.app` bundle for simulator
  - Uses `xcodebuild` with Release configuration
  - Targets specific booted simulator to avoid x86_64 build issues
  - Uses `ONLY_ACTIVE_ARCH=YES` to build only for active architecture (arm64)
  
- **Test Runner:** `scripts/run-maestro-ios.sh` - Installs, launches, and tests standalone app
  - Installs `.app` bundle with `xcrun simctl install booted`
  - Launches app with `xcrun simctl launch booted com.fiveq.ffci`
  - Runs Maestro test (app already launched, no `launchApp` needed)
  
- **Test Flow:** `maestro/flows/homepage-loads-ios.yaml` - Simplified test without `launchApp`
  - No `_setup.yaml` dependency
  - Just waits for animations and asserts visibility
  - App is launched by script, not Maestro

**NPM Scripts:**
- `npm run build:ios:release` - Build Release .app for simulator
- `npm run test:maestro:ios:standalone` - Run test with standalone build

**Verification Results:**
1. ✅ **Baseline Pass:** Built app, test passed - "Quick Tasks" visible
2. ✅ **Break Detection:** Changed "Quick Tasks" → "Broken Text", rebuilt, test correctly failed
3. ✅ **Fix Verification:** Reverted change, rebuilt, test passed again

**Key Benefits:**
- ✅ **No cached code issues** - JavaScript is bundled into app at build time
- ✅ **Consistent behavior** - Tests always run against the exact code that was built
- ✅ **Matches Android pattern** - Same approach for both platforms
- ✅ **Reliable regression detection** - Verified that tests catch code changes

**Build Time:**
- Full Release build: ~2-3 minutes (includes clean)
- Subsequent builds: Faster due to caching

**Usage:**
```bash
# Build Release app
npm run build:ios:release

# Run test with standalone build
npm run test:maestro:ios:standalone
```

**Note:** This approach requires a full rebuild for every code change (like Android), but eliminates Metro dependency and cached code issues. For faster iteration during development, Metro-based testing is still available, but standalone builds are recommended for reliable CI/CD and regression testing.
