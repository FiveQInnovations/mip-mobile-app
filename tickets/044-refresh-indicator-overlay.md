---
status: backlog
area: rn-mip-app
created: 2026-01-02
---

# Add Refresh Indicator During Background Refresh

## Context
The app uses a stale-while-revalidate caching pattern where cached content is shown immediately while fresh data loads in the background. Users should see a subtle indicator that content is being refreshed.

## Tasks
- [ ] Design subtle refresh indicator (small spinner, progress bar, etc.)
- [ ] Show indicator in TabScreen when `refreshing` state is true
- [ ] Position indicator unobtrusively (header, bottom, etc.)
- [ ] Hide indicator when background refresh completes
- [ ] Test indicator visibility without being distracting

## Notes
- TabScreen already has `refreshing` state that tracks background refresh
- Should be subtle - not block content or feel like loading
- Could be a small spinner in the header or a thin progress bar
