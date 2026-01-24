---
status: maybe
area: rn-mip-app
phase: nice-to-have
created: 2026-01-02
---

# Cache Last Successful Data for Offline Access

## Context
The spec mentions caching last successful data if feasible. This allows users to still view previously loaded content when the network is unavailable, providing a better offline experience.

## Tasks
- [ ] Evaluate persistent storage options (AsyncStorage, MMKV, etc.)
- [ ] Persist site data (menu, branding) to device storage
- [ ] Persist recently viewed page content to device storage
- [ ] Load cached data on app start before network request
- [ ] Show cached content with "offline" indicator when network unavailable
- [ ] Clear old cached data to manage storage usage

## Notes
- Per spec: "Cache last successful data if feasible"
- Current pageCache is in-memory only, lost on app restart
- Full offline mode is out of scope for v1, but showing stale data is acceptable
