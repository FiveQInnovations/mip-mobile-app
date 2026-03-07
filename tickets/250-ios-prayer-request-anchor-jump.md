---
status: backlog
area: ios-mip-app
phase: core
created: 2026-03-07
---

# Add iOS Prayer Request Anchor Jump

## Context

Ticket `239` identified extra narrative text above the Prayer Request form that causes unnecessary scrolling in mobile flows. Android now uses an anchor jump to open directly near the form, and iOS should match that behavior for consistency.

## Goals

1. Update iOS external form link handling to append the prayer-request form anchor when appropriate
2. Preserve existing browser-open behavior for all other form links
3. Keep implementation lightweight without requiring CMS/form duplication

## Acceptance Criteria

- Tapping Prayer Request from the iOS app opens in browser with `#prayer-request-response` anchor
- Prayer Request loads near the form instead of top-of-page narrative text
- Chaplain Request and other form links continue working as before
- No regression in iOS internal/external link routing behavior

## Notes

- Scope is iOS-only; Android is already addressed separately
- Prefer URL normalization in the iOS HTML link handling layer to keep behavior centralized

## References

- Parent ticket: `tickets/239-streamline-prayer-request-mobile.md`
- iOS link handling: `ios-mip-app/FFCI/Views/HtmlContentView.swift`
- Android counterpart: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`
