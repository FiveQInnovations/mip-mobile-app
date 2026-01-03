---
status: backlog
area: rn-mip-app
phase: core
created: 2026-01-03
---

# Header Should Respect Safe Area Insets

## Problem

Headers and navigation elements rendered within tab content screens don't consistently respect iOS safe area insets. This causes UI elements to overlap with the status bar, making them difficult or impossible to tap.

## Background

This was discovered while fixing ticket 054. The "← Back" button in `TabScreen.tsx` was rendered at position `[0,0]`, overlapping with the iOS status bar. The fix applied `marginTop: insets.top` to push it below the safe area.

## Current State

- **Fixed:** `TabScreen.tsx` back button now uses `useSafeAreaInsets()` to position correctly
- **To Review:** Other screens may have similar issues with headers/navigation elements

## Scope

Review and ensure all header/navigation elements respect safe area insets:

- [ ] `TabScreen.tsx` - Back button (already fixed)
- [ ] `HomeScreen.tsx` - Any header elements
- [ ] `PageScreen.tsx` - Used for `/page/[uuid]` route (uses Expo Router header)
- [ ] Any other screens with custom headers

## Technical Approach

1. Use `useSafeAreaInsets()` from `react-native-safe-area-context`
2. Apply `marginTop: insets.top` or `paddingTop: insets.top` to header containers
3. Consider creating a reusable `<Header>` component that handles safe area automatically

## Related Files

- `rn-mip-app/components/TabScreen.tsx` - Has the fix pattern to follow
- `rn-mip-app/components/HomeScreen.tsx`
- `rn-mip-app/components/PageScreen.tsx`
- `rn-mip-app/app/_layout.tsx` - Root layout with SafeAreaProvider

## Related Tickets

- Ticket 054: Internal Page Back Navigation (fix applied there)
