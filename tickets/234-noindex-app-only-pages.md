---
status: done
area: ws-ffci
phase: core
created: 2026-01-29
---

# Investigate noindex for App-Only Pages

## Context

From FFCI App Build Review meeting (Jan 29, 2026). App pages must be published on the website for the app to read them, but we don't want them cluttering web search results. Need to investigate using noindex meta tags or other SEO separation strategies.

## Goals

1. Investigate feasibility of noindex implementation for app-only pages
2. Implement solution if feasible
3. Ensure app pages remain accessible to the app while hidden from search engines

## Acceptance Criteria

- App-only pages are not indexed by search engines
- App can still access and display these pages
- Solution doesn't break app functionality

## Notes

- App pages are stored in "Mobile" folder on website: https://ffci.fiveq.dev/panel/pages/mobile
- Pages must be published for app to read them
- Consider noindex meta tag or robots.txt approach

## Implementation Notes

- Added site-specific routing in `ws-ffci/site/config/config.php` for `/mobile` and `/mobile/(:all)` to keep app pages accessible while applying search exclusion behavior.
- Added a site-specific `sitemap.xml` route override in `ws-ffci/site/config/config.php` to exclude `/mobile` and `/mobile/*` URLs from the generated sitemap.
- Kept the change site-specific only (no shared plugin modifications).

## Verification Notes

- Deployed via `master` push to `ws-ffci` and validated live on `https://ffci.fiveq.dev`.
- Confirmed `/mobile`, `/mobile/connect-with-us`, and `/mobile/test-background` include `<meta name="robots" content="noindex">` via `curl`.
- Confirmed `https://ffci.fiveq.dev/sitemap.xml` no longer includes `/mobile` URLs by checking for `<loc>https://ffci.fiveq.dev/mobile...` entries with `curl` + `rg` (no matches).

## References

- Meeting: `meetings/ffci-app-build-review-jan-29.md` (00:13:04)
