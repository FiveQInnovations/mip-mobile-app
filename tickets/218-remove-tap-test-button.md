---
status: backlog
area: ios-mip-app
phase: core
created: 2026-01-26
---

# Remove Tap Test Button from Home Screen

## Context

The "TAP TEST" button on the home screen was added for Maestro UI testing to verify tap functionality. This debug/test button should be removed before production as it's not part of the intended user experience.

## Goals

1. Remove the Tap Test button from the home screen
2. Remove all related test code and test files
3. Clean up any associated state variables

## Acceptance Criteria

- Tap Test button is no longer visible on the home screen
- `tapCount` state variable is removed from `HomeView.swift`
- Tap Test button code (lines 25-44) is removed from `HomeView.swift`
- Maestro test file `tap-test-button-ios.yaml` is removed or deleted
- Any screenshot files related to tap test are cleaned up

## Notes

- Button is currently located in `ios-mip-app/FFCI/Views/HomeView.swift` (lines 25-44)
- Button includes `@State private var tapCount = 0` variable (line 18)
- Maestro test file: `ios-mip-app/maestro/flows/tap-test-button-ios.yaml`
- Screenshot files may exist in `maestro/screenshots/` directory:
  - `tap-test-button-ios-initial`
  - `tap-test-button-ios-after-1`
  - `tap-test-button-ios-after-2`
- Button has accessibility identifier: `tap-test-button`
- Button was placed outside ScrollView to ensure it's always accessible for testing

## References

- Implementation: `ios-mip-app/FFCI/Views/HomeView.swift` (lines 18, 25-44)
- Test file: `ios-mip-app/maestro/flows/tap-test-button-ios.yaml`
