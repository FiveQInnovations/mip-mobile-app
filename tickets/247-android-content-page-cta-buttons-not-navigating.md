---
status: cancelled
area: android-mip-app
phase: core
created: 2026-03-06
---

# Fix Non-Responsive CTA Buttons on Content Pages (Android)

## Context

During manual QA of content pages opened via in-app Search, CTA buttons rendered inside page content appeared visually correct but did not navigate when tapped.

Follow-up verification confirmed this was a false alarm caused by tapping the wrong screen coordinates during emulator QA. The CTA is responsive in Android.

## Goals

1. Verify whether CTA taps are truly non-responsive on Android
2. Confirm whether behavior is instead explained by backend/API failure

## Acceptance Criteria

- [x] `FAQ` `Become a Member` CTA tap triggers in-app navigation
- [x] App attempts to load page UUID `2E3lFqnOR6UULQfz`
- [x] User-visible error is backend `500`, tracked separately

## Notes

- Verification (2026-03-07):
  - `HtmlContent` logged `Link clicked: https://ffci.fiveq.dev/page/2E3lFqnOR6UULQfz`
  - `TabScreen` logged `Navigating to page: 2E3lFqnOR6UULQfz`
  - API fetch then failed with `Failed to fetch (500)` for that UUID
- Action:
  - Close this ticket as duplicate/invalid
  - Track real issue in `tickets/243-become-a-member-page-api-500.md`

## References

- Android HTML renderer and link handling: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`
- Related API issue: `tickets/243-become-a-member-page-api-500.md`
