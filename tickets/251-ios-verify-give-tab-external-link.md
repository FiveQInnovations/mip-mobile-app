---
status: done
area: ios-mip-app
phase: core
created: 2026-03-07
---

# Verify Give Tab External Link on iOS

## Context

Ticket `236` added a new Give tab that opens the Aplos donation URL from mobile navigation. Android behavior is implemented and verified, and iOS now needs explicit verification to confirm parity and prevent platform-specific regressions.

## Goals

1. Verify the Give tab appears in iOS bottom navigation when loading live mobile menu data
2. Verify tapping Give opens the external Aplos donation page in browser
3. Verify existing tabs (Home, Resources, Media, Connect) still route correctly

## Acceptance Criteria

- iOS app shows Give in bottom navigation with no missing/duplicated tab labels
- Tapping Give opens `https://app.aplos.com/aws/give/FirefightersForChristInternational` externally
- Returning to app preserves normal tab navigation behavior
- No regression in existing iOS tab routing after menu/API updates

## Notes

- Scope is verification-focused for iOS behavior against current live API and content
- If any mismatch is found, capture repro steps and open implementation follow-up

## References

- Parent ticket: `tickets/236-add-give-button-bottom-nav.md`
- iOS tab/navigation code: `ios-mip-app/`
- Mobile API menu source: `https://ffci.fiveq.dev/mobile-api/menu`
