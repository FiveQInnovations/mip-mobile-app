---
status: backlog
area: rn-mip-app
created: 2026-01-02
---

# Remove Dev Tools Section Before Production

## Context
The HomeScreen currently includes a "Dev Tools (Temp)" section with a cache clearing button. This is useful during development but should be removed or hidden before production release.

## Tasks
- [ ] Remove Dev Tools section from HomeScreen.tsx
- [ ] Or conditionally hide based on __DEV__ flag
- [ ] Remove related state and handlers if fully removing
- [ ] Test production build doesn't show dev tools

## Notes
- Located in HomeScreen.tsx, lines 214-236 approximately
- Includes cache clearing functionality
- Could keep for debug builds only using __DEV__ conditional
