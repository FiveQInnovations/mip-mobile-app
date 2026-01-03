---
status: done
area: rn-mip-app
phase: core
created: 2026-01-19
---

# Remove Debug Elements from HomeScreen

## Context

The `/debug/html-crash` screen was created as a debug harness to reproduce and test a crash issue with `react-native-render-html` when rendering nested `<picture><source>` tags inside links (ticket #051). The issue has been resolved. Additionally, there are leftover debug/placeholder elements on the HomeScreen that should be cleaned up before release.

## Tasks

### HTML Crash Debug Screen
- [ ] Remove `rn-mip-app/app/debug/html-crash.tsx`
- [ ] Remove `rn-mip-app/fixtures/resourcesCrashHtml.ts` (if only used by debug screen)
- [ ] Remove "Open HTML Crash Fixture" button from Dev Tools section in `HomeScreen.tsx`
- [ ] Remove `rn-mip-app/maestro/flows/html-crash-fixture-ios.yaml` test flow (if no longer needed)
- [ ] Verify no other references to the debug screen exist

### HomeScreen Debug Elements
- [ ] Remove "9:46" placeholder text (testID: `hello-world`) and associated `helloWorld` style
- [ ] Remove "Homepage Type" info block that displays `config.homepageType` and associated `infoSection`, `infoLabel`, `infoValue` styles

### Keep for Now
- Clear Cache button in Dev Tools section (still useful for development)

## Notes

- The debug screen pattern (`/debug/*` routes with minimal HTML fixtures) was useful for isolating HTML rendering issues
- Consider documenting this pattern before removal if it might be helpful for future debugging
- Check if `resourcesCrashHtml.ts` fixture is used elsewhere before removing
