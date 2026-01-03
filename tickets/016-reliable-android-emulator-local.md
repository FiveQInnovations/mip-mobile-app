---
status: in-progress
area: rn-mip-app
created: 2026-01-21
---

# Prove Android Emulator Reliability with Maestro Testing

## Context
Prove Android emulator reliability by creating a simple Maestro test that verifies the home screen loads correctly. The test must run successfully 5 times in a row to demonstrate consistent emulator behavior. Additionally, the test must follow the "Break and Verify" pattern - introduce an intentional error and verify the test catches it and fails appropriately.

**Success Criteria:**
- Simple Maestro test for Android home screen
- Test runs successfully 5 consecutive times
- Break and Verify: Test fails when error is introduced, passes when error is removed

## Tasks
- [ ] Create simple Maestro test for Android home screen
- [ ] Test runs successfully 5 times in a row
- [ ] Implement Break and Verify pattern:
  - [ ] Introduce intentional error (e.g., wrong text assertion)
  - [ ] Verify test fails as expected
  - [ ] Remove error and verify test passes again
- [ ] Document test and reliability results

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

**Conclusion:** Preview/release builds provide deterministic testing without Metro dependency. The workflow is reliable when using adb to launch the app before running Maestro tests.
