---
status: backlog
area: rn-mip-app
phase: core
created: 2026-01-19
---

# Remove HTML Crash Debug Screen

## Context

The `/debug/html-crash` screen was created as a debug harness to reproduce and test a crash issue with `react-native-render-html` when rendering nested `<picture><source>` tags inside links (ticket #051). The issue has been resolved, but the debug screen was kept as a reference pattern for future debugging needs.

## Tasks

- [ ] Remove `rn-mip-app/app/debug/html-crash.tsx`
- [ ] Remove `rn-mip-app/fixtures/resourcesCrashHtml.ts` (if only used by debug screen)
- [ ] Remove debug button from `rn-mip-app/components/HomeScreen.tsx` that navigates to `/debug/html-crash`
- [ ] Remove `rn-mip-app/maestro/flows/html-crash-fixture-ios.yaml` test flow (if no longer needed)
- [ ] Verify no other references to the debug screen exist

## Notes

- The debug screen pattern (`/debug/*` routes with minimal HTML fixtures) was useful for isolating HTML rendering issues
- Consider documenting this pattern before removal if it might be helpful for future debugging
- Check if `resourcesCrashHtml.ts` fixture is used elsewhere before removing
