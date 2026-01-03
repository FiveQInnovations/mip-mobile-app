---
status: backlog
area: rn-mip-app
created: 2026-01-02
---

# Maestro Test: Error Handling

## Context
The spec requires Maestro test coverage for error handling. Need to verify the app shows a graceful error screen when the API is unavailable.

## Tasks
- [ ] Create `error-handling.yaml` Maestro flow
- [ ] Determine how to simulate API unavailability in test
- [ ] Trigger error condition (network off, bad URL, etc.)
- [ ] Assert error screen is displayed
- [ ] Verify retry button is present
- [ ] Test retry functionality if possible
- [ ] Take screenshot for documentation

## Notes
- Per spec: "Error Handling - Graceful error screen when API unavailable"
- May require special test setup to simulate network failure
- Depends on ticket 037 (Error/offline screen) being implemented
