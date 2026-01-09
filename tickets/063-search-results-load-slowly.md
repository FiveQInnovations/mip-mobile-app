---
status: qa
area: rn-mip-app
phase: core
created: 2026-01-08
---

# Search results load slowly

## Context
When searching in the mobile app, search results take 20+ seconds to load. This creates a poor user experience. The search API endpoint returns results quickly when tested directly (e.g., searching for "firefighter" returns 19 results), so the issue is likely in the mobile app's search implementation or network handling.

**Current behavior:**
- User types search query
- Search results take 20+ seconds to appear
- API endpoint itself is fast when tested directly

**Expected behavior:**
- Search results should appear within 1-2 seconds

## Tasks
- [x] Investigate search API call timing and network performance
- [x] Check if search requests are being debounced/throttled appropriately
- [x] Verify API endpoint response times from mobile app
- [x] Check for any blocking operations during search
- [x] Optimize search result rendering
- [x] Add loading indicators if not already present
- [x] Consider caching search results for common queries

## Notes
- Search functionality works correctly (returns expected results)
- API endpoint at `https://ffci.fiveq.dev/mobile-api/search` responds quickly when tested directly
- Issue appears to be in the mobile app's handling of search requests

## Implementation (2026-01-08)
**Improvement implemented:** Added search result caching and AbortController support
- Created `searchCache.ts` module with in-memory cache (2 min TTL, 20 query limit)
- Added AbortController to cancel previous requests when user types quickly
- Updated search screen to check cache before making API calls
- Added Maestro test for search functionality

**Results:**
- Significant improvement: Reduced from 20+ seconds to ~10 seconds for first search
- Repeated searches return instantly from cache
- No request pile-up when users type quickly (previous requests are cancelled)
- **Note:** Still takes ~10 seconds for queries like "firefighters" - this is an improvement but not a full solution. Further investigation needed for initial search performance.
