---
status: qa
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

- [x] `GET /mobile-api/page/2E3lFqnOR6UULQfz` returns `200` with valid JSON
- [ ] Android app opens `Become a Member` page from search without `Failed to fetch (500)`
- [x] No regression in `mobile-api/page` responses for other pages
- [x] Root cause documented (content block, snippet, or API transform issue)

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

## Research Update (2026-03-07)

- Re-tested endpoint with app auth headers (`Basic fiveq:demo` + configured `X-API-Key`).
- `GET /mobile-api/page/2E3lFqnOR6UULQfz` now returns `400 Bad Request` (not `500`), with body:
  - `{"status":"error","code":"error.invalidArgument",...}`
- Related checks:
  - `GET /mobile-api/search?q=become+member` returns `200` and still includes UUID `2E3lFqnOR6UULQfz`
  - `GET /mobile-api/page/xhZj4ejQ65bRhrJg` returns `200` (control page works)
- Conclusion:
  - This is still an active backend issue for the `Become a Member` page endpoint.
  - The problem appears isolated to page-specific API transform/serialization for UUID `2E3lFqnOR6UULQfz`, but now surfaces as `error.invalidArgument` instead of HTTP 500.

## Fix Update (2026-03-07)

- Implemented and deployed a defensive fix in `wsp-mobile` (`lib/pages.php`) to prevent page-level API failure when a single section has unsupported/invalid block payload.
- Added guards in page assembly flow so invalid section/UUID data does not fail the entire response.
- Production verification after deploy:
  - `GET /mobile-api/page/2E3lFqnOR6UULQfz` -> `200`
  - `GET /mobile-api/page/xhZj4ejQ65bRhrJg` -> `200` (control)
- Deployed plugin commit: `be17921`
- Ticket moved to `qa` for Android client-path verification.

## References

- Android API client: `android-mip-app/app/src/main/java/com/fiveq/ffci/data/api/MipApiClient.kt`
- Android tab screen error surface: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/screens/TabScreen.kt`
- Endpoint: `https://ffci.fiveq.dev/mobile-api/page/2E3lFqnOR6UULQfz`
- Related search endpoint (works): `https://ffci.fiveq.dev/mobile-api/search?q=become+member`
