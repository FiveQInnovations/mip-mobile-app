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
- [ ] Try local Android release build: `npx expo run:android --variant release`
- [ ] Install on emulator and verify app launches without dev menu
- [ ] Run existing Maestro test against preview build
- [ ] Verify 5 consecutive successful runs
