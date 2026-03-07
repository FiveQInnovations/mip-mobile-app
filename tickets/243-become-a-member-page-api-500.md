---
status: backlog
area: wsp-mobile
phase: core
created: 2026-03-06
---

# Fix `Become a Member` Page Failing with API 500

## Context

During Android app exploratory navigation, opening `Become a Member` from in-app search consistently failed with an error state: `Failed to fetch (500)`.

Logcat confirms the API request returns 500 for the page endpoint:
`GET /mobile-api/page/2E3lFqnOR6UULQfz`.

This appears to be a backend API/content serialization issue, not a client transport issue, since search returns the page entry successfully and other page endpoints load.

## Goals

1. Reproduce and identify the server-side cause of the 500 response for page UUID `2E3lFqnOR6UULQfz`
2. Fix the API response so the page loads in mobile clients
3. Confirm Android can open `Become a Member` without the error state

## Acceptance Criteria

- [ ] `GET /mobile-api/page/2E3lFqnOR6UULQfz` returns `200` with valid JSON
- [ ] Android app opens `Become a Member` page from search without `Failed to fetch (500)`
- [ ] No regression in `mobile-api/page` responses for other pages
- [ ] Root cause documented (content block, snippet, or API transform issue)

## Notes

- Reproduction path:
  1. Open Android app
  2. Tap Home search icon
  3. Search for `become member`
  4. Tap `Become a Member`
- Observed app error UI:
  - `Something went wrong`
  - `Failed to fetch (500)`
- Relevant logs:
  - `MipApiClient: Fetching: https://ffci.fiveq.dev/mobile-api/page/2E3lFqnOR6UULQfz`
  - `okhttp: <-- 500 Internal Server Error`
  - `TabScreen: Error loading page: Failed to fetch (500)`

## References

- Android API client: `android-mip-app/app/src/main/java/com/fiveq/ffci/data/api/MipApiClient.kt`
- Android tab screen error surface: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/screens/TabScreen.kt`
- Endpoint: `https://ffci.fiveq.dev/mobile-api/page/2E3lFqnOR6UULQfz`
- Related search endpoint (works): `https://ffci.fiveq.dev/mobile-api/search?q=become+member`
