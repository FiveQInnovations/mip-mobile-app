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

**Current iOS Tests:**
- `maestro/flows/home-action-hub.yaml` - Comprehensive homepage test (uses iOS setup flow)
- `maestro/flows/tab-switch-from-home.yaml` - Tab switching test (uses iOS setup flow)
- `maestro/flows/_setup.yaml` - Shared setup flow (uses launchApp, works reliably on iOS)

**Existing Scripts:**
- `npm run test:maestro:ios` - Currently runs only `home-action-hub.yaml`

## Tasks
- [ ] Identify all stable iOS test flows
- [ ] Create a script to run all stable iOS tests in sequence
- [ ] Add npm script for easy access: `npm run test:maestro:ios:all`
- [ ] Document which tests are considered "stable" vs "experimental"
- [ ] Ensure proper error handling and reporting for test suite runs
- [ ] Verify the command works reliably (run 3+ times successfully)

## Notes
