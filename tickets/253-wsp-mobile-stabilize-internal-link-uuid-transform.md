---
status: backlog
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

## References

- `wsp-mobile/lib/pages.php`
- `tickets/243-become-a-member-page-api-500.md`
- `tickets/252-android-internal-buttons-open-browser-regression.md`
