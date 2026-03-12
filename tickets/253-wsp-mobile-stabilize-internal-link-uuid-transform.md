---
status: done
area: wsp-mobile
phase: core
created: 2026-03-07
---

# Stabilize Internal Link to UUID Transform in Mobile API

## Context

Some content responses can fall back to raw HTML when link transformation throws. In that fallback path, internal links may remain slug/path URLs instead of `/page/{uuid}`, forcing clients to guess or resolve links at runtime.

## Goals

1. Ensure internal links are consistently transformed to UUID-based app links
2. Prevent single-link transform failures from downgrading entire page link quality
3. Improve diagnostics so broken content/link payloads are actionable

## Acceptance Criteria

- `page_content` for content pages preserves internal navigation as `/page/{uuid}` links
- Link-transform errors are isolated with enough metadata for debugging
- Android/iOS clients no longer need best-effort URL-to-UUID resolution for standard internal buttons

## Notes

- This is a follow-up hardening task; Android now has an app-side fallback.

## Implementation Notes

- Updated `wsp-mobile/lib/pages.php` to isolate internal-link UUID transform failures per link so one bad href does not downgrade all transformed links in `page_content`.
- Added richer transform-failure diagnostics (reason + source context + failing href metadata) to make broken content payloads actionable.
- Preserved non-page destinations (external and form routes) so only valid internal page targets convert to `/page/{uuid}`.
- Deployed in `wsp-mobile` and verified endpoint responses include transformed `/page/{uuid}` links while preserving external/form links.

## QA (Manual iOS Simulator)

- Build and run the iOS app on simulator.
- Open a content page that includes mixed links (internal page buttons and at least one external/form link).
- Confirm internal content links navigate in-app (no browser open for standard internal page buttons).
- Confirm form/external links still open externally.
- If available, verify a page with malformed/odd link markup still preserves other valid internal links as `/page/{uuid}`.
- Ready for QA.

## References

- `wsp-mobile/lib/pages.php`
- `tickets/243-become-a-member-page-api-500.md`
- `tickets/252-android-internal-buttons-open-browser-regression.md`
