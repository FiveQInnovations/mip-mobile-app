---
status: backlog
area: wsp-mobile
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

- App pages are stored in "Mobile" folder on website
- Pages must be published for app to read them
- Consider noindex meta tag or robots.txt approach

## References

- Meeting: `meetings/ffci-app-build-review-jan-29.md` (00:13:04)
