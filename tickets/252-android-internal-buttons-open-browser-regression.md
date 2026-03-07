---
status: in-progress
area: android-mip-app
phase: core
created: 2026-03-07
---

# Fix Android Regression: Internal Buttons Open Browser

## Context

On the Android `Become a Member` page, most buttons now open the external browser instead of navigating inside the app. Only true form destinations should open externally.

This appeared after defensive fallback behavior allowed untransformed internal URLs to reach the app as regular paths (not `/page/{uuid}` links).

## Goals

1. Keep non-form internal page links in-app
2. Preserve external browser behavior for form links (e.g. membership form)
3. Verify the behavior on Android navigation paths that use `HtmlContent`

## Acceptance Criteria

- Internal content-page buttons navigate inside Android app
- Form links still open external browser
- No navigation regression for `/page/{uuid}` links

## Notes

- Related QA issue reported after ticket `243` verification.
- This is an app-side resilience fix for mixed link formats.

## References

- `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`
- `android-mip-app/app/src/main/java/com/fiveq/ffci/data/api/MipApiClient.kt`
- `tickets/243-become-a-member-page-api-500.md`
