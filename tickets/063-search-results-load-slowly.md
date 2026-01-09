---
status: backlog
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
- [ ] Investigate search API call timing and network performance
- [ ] Check if search requests are being debounced/throttled appropriately
- [ ] Verify API endpoint response times from mobile app
- [ ] Check for any blocking operations during search
- [ ] Optimize search result rendering
- [ ] Add loading indicators if not already present
- [ ] Consider caching search results for common queries

## Notes
- Search functionality works correctly (returns expected results)
- API endpoint at `https://ffci.fiveq.dev/mobile-api/search` responds quickly when tested directly
- Issue appears to be in the mobile app's handling of search requests
