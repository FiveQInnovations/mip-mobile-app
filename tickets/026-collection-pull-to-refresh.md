---
status: backlog
area: rn-mip-app
phase: nice-to-have
created: 2026-01-02
---

# Collection Pull-to-Refresh

## Context
The spec requires pull-to-refresh functionality on collection screens. This is a standard mobile pattern that allows users to manually refresh content without restarting the app.

## Tasks
- [ ] Add RefreshControl to collection ScrollView/FlatList
- [ ] Implement refresh handler to reload collection data
- [ ] Show loading indicator during refresh
- [ ] Update UI with fresh data when complete
- [ ] Test pull-to-refresh gesture on iOS and Android

## Notes
- Per spec: "Pull-to-refresh" for Collection List
- React Native provides RefreshControl component for this
- Consider using same pattern for content pages
