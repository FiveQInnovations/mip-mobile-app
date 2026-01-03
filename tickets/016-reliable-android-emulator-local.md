---
status: done
area: rn-mip-app
created: 2026-01-21
completed: 2026-01-03
---

# Prove Android Emulator Reliability with Maestro Testing

## Context
Prove Android emulator reliability by creating a simple Maestro test that verifies the home screen loads correctly. The test must run successfully 5 times in a row to demonstrate consistent emulator behavior. Additionally, the test must follow the "Break and Verify" pattern - introduce an intentional error and verify the test catches it and fails appropriately.

**Success Criteria:**
- Simple Maestro test for Android home screen
- Test runs successfully 5 consecutive times
- Break and Verify: Test fails when error is introduced, passes when error is removed

## Tasks
- [x] Create simple Maestro test for Android home screen
- [x] Test runs successfully 5 times in a row
- [x] Troubleshoot UIAutomation connection issue:
  - [x] Investigate why Maestro's UIAutomation service cannot connect to Android emulator
  - [x] **Root cause:** Stale Maestro Java process holding port 7001 in CLOSE_WAIT state
  - [x] **Fix:** Kill stale process with `kill -9 <PID>` or check with `lsof -i :7001`
- [x] Implement Break and Verify pattern:
  - [x] Break production code: Changed `HomeScreen.tsx` "Quick Tasks" → "BROKEN TEXT"
  - [x] Rebuild release APK with broken code
  - [x] Verify test fails as expected (caught the regression)
  - [x] Revert production code and rebuild
  - [x] Verify test passes again
- [x] Document test and reliability results

## Notes

### Previous Investigation: Expo Orbit (2026-01-21)

**Status:** Orbit installed and tested, but limited value for core issue

**Findings:**
- ✅ Orbit successfully installed and can detect Android SDK
- ✅ Orbit CLI can list devices (`list-devices` command works)
- ✅ Orbit can install apps on emulator
- ❌ **Main issue:** Orbit doesn't solve the core problem of reliably controlling/managing the emulator after installation

**Conclusion:**
- Orbit is useful for app installation but doesn't address emulator control reliability
- Decided to prove reliability through Maestro testing instead

---

### New Approach: Maestro Test-Based Reliability Proof (2026-01-21)

**Strategy:** Prove emulator reliability by demonstrating consistent test execution
- If a simple Maestro test can run successfully 5 times in a row, the emulator is reliable enough
- Break and Verify pattern ensures the test is actually working correctly

**Existing Test Reference:**
- `rn-mip-app/maestro/flows/homepage-loads-android.yaml` - Existing Android homepage test
- Can use as starting point or create new simplified version

---

### Research: Preview Builds for Deterministic Testing (2026-01-03)

**Problem:** Development builds with Metro server cause flaky tests due to:
- Developer menu prompts from `expo-dev-client`
- Uncertainty whether Metro has served latest JS bundle
- Hot reload leaving app in inconsistent state
- Development mode validations adding latency and non-determinism

**Solution:** Use preview/release builds instead of development builds

**Key Insight:** Preview builds embed the JS bundle in the app binary, eliminating:
- Metro server dependency
- Hot reload uncertainty
- Development Build screen prompts
- Code update ambiguity

**Comparison:**

| Aspect | Development Build | Preview Build |
|--------|-------------------|---------------|
| JS Bundle | Loaded from Metro | Embedded in app |
| Developer Menu | Shows on launch | None |
| Hot Reload | Active (inconsistent) | Disabled |
| Test Reliability | ❌ Flaky | ✅ Consistent |

**Recommended Approach:**

1. Add a `testing` profile to `eas.json`:
```json
{
  "testing": {
    "extends": "preview",
    "android": {
      "buildType": "apk"
    }
  }
}
```

2. Build locally for Android (no EAS cloud needed):
```bash
npx expo run:android --variant release
```

3. Or build with EAS for simulator/emulator:
```bash
eas build --profile testing --platform android
```

4. Install APK and run Maestro tests without Metro

**Trade-off:** Slower iteration (rebuild vs hot reload), but consistency matters more for automated testing.

**Next Steps:**
- [x] Try local Android release build: `./gradlew assembleRelease`
- [x] Install on emulator and verify app launches without dev menu
- [x] Run existing Maestro test against preview build
- [x] Verify 5 consecutive successful runs

---

### Test Results: Preview Build Success (2026-01-03)

**Build Method:** Local Gradle release build (`./gradlew assembleRelease`)

**Test Execution:**
- Built release APK: `android/app/build/outputs/apk/release/app-release.apk`
- Installed on emulator: `Maestro_Pixel_6_API_30_1` (emulator-5554)
- Test file: `maestro/flows/homepage-loads-android.yaml`

**Key Findings:**
1. ✅ Release build works without Metro server - no dev menu prompts
2. ✅ App launches successfully with `adb shell am start`
3. ⚠️ Maestro's `launchApp` command fails with release builds - must use adb
4. ⚠️ `clearState` closes the app - removed from test flow
5. ✅ Test passes consistently when app is launched via adb before test

**Test Results - 5 Consecutive Runs:**
- Run 1: ✅ PASSED
- Run 2: ✅ PASSED
- Run 3: ✅ PASSED
- Run 4: ✅ PASSED
- Run 5: ✅ PASSED

**All assertions passed in all runs:**
- "Firefighters for Christ International" visible
- "Quick Tasks" visible
- "Prayer Request" visible
- "Resources" visible
- "Home" tab visible

**Test Command:**
```bash
adb shell am force-stop com.fiveq.ffci && \
adb shell am start -n com.fiveq.ffci/.MainActivity && \
sleep 3 && \
maestro test maestro/flows/homepage-loads-android.yaml
```

**Automation Scripts Created:**
- `scripts/run-maestro-android.sh` - Single test run with adb launch
- `scripts/run-maestro-android-5x.sh` - 5 consecutive runs for reliability testing
- `npm run test:maestro:android` - npm script wrapper
- `npm run test:maestro:android:5x` - npm script for 5x runs

**Conclusion:** Preview/release builds provide deterministic testing without Metro dependency. The workflow is reliable when using adb to launch the app before running Maestro tests. Scripts have been created to automate this workflow.

---

### UIAutomation Connection Issue (2026-01-03)

**Status:** Blocking baseline test execution

**Problem:**
Maestro's UIAutomation service cannot connect to Android emulator, preventing test execution:
- Error: `io.grpc.StatusRuntimeException: INTERNAL: UiAutomation not connected, UiAutomation@7cd8243[id=-1, flags=0]`
- App launches successfully via `adb shell am start`
- App displays correctly on emulator (verified via screenshot)
- Maestro cannot read UI hierarchy to find elements

**What Works:**
- ✅ APK installation: `adb install -r android/app/build/outputs/apk/release/app-release.apk`
- ✅ App launch: `adb shell am start -n com.fiveq.ffci/.MainActivity`
- ✅ App displays homepage correctly
- ✅ Maestro packages installed on device (`dev.mobile.maestro`, `dev.mobile.maestro.test`)

**What Doesn't Work:**
- ❌ Maestro's `launchApp` command (fails with release builds - expected)
- ❌ Maestro's UIAutomation service connection
- ❌ Reading UI hierarchy after app launch via adb

**Attempted Solutions:**
1. Increased wait time after app launch (3s → 5s → 8s)
2. Enabled accessibility services
3. Verified app is running before test
4. Restarted Maestro packages on device
5. Added APK reinstall step to script

**Resolution (2026-01-03):**
- ✅ **Root cause identified:** Stale Maestro Java process holding port 7001 in CLOSE_WAIT state
- ✅ **Fix:** Kill the stale process: `lsof -i :7001` to find PID, then `kill -9 <PID>`
- ✅ **Prevention:** Add port check to test script before running Maestro

**Diagnostic command:**
```bash
lsof -i :7001
```
If this shows a Java process with CLOSE_WAIT connections, kill it before running Maestro tests.

---

### Break and Verify Pattern Results (2026-01-03)

**Status:** ✅ Complete

**Approach:** Modified production code (not test code) to verify test catches real regressions.

**Test Flow:**
1. **Baseline established:** Test passes with correct production code
2. **Break production code:** Changed `HomeScreen.tsx` line 145: `"Quick Tasks"` → `"BROKEN TEXT"`
3. **Rebuild APK:** `./gradlew assembleRelease` (14s incremental build)
4. **Verified failure:** Test correctly failed - caught the regression
5. **Revert and rebuild:** Restored production code, rebuilt APK
6. **Fix verified:** Test passes again

**Results:**
- ✅ Baseline: PASSED
- ✅ Broken production code: FAILED (test caught the regression)
- ✅ Fixed production code: PASSED

**Conclusion:** The Maestro test correctly detects production code regressions. The test is reliable for catching real bugs in the app.
