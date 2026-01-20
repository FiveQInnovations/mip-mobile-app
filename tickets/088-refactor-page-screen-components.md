---
status: done
area: rn-mip-app
phase: nice-to-have
created: 2026-01-20
---

# Refactor PageScreen/TabScreen Shared Logic

## Context

Ticket 087 revealed an architectural issue: `TabScreen.tsx` and `PageScreen.tsx` both render the same content types (content pages, collections, collection-items) but with separate implementations. This caused confusion during debugging and required duplicate fixes.

**Current State:**
- `TabScreen.tsx` - Used by `TabNavigator` for main tab content, maintains internal navigation stack
- `PageScreen.tsx` - Used by Expo Router (`app/page/[uuid].tsx`) for direct URL navigation

Both now have duplicated code for:
- Collection item rendering (Pressable with navigation)
- Audio item detection
- AudioPlayer rendering
- Accessibility props

## Goals

1. Extract shared rendering logic into reusable components
2. Document the navigation architecture to prevent future confusion
3. Ensure feature parity is maintained automatically

## Acceptance Criteria

### 1. Extract CollectionItemList Component
- Create `components/CollectionItemList.tsx`
- Handles: Pressable rendering, press feedback, accessibility, navigation callback
- Both TabScreen and PageScreen use this component
- Reduces duplication

### 2. Extract AudioItemContent Component (optional)
- Create `components/AudioItemContent.tsx`
- Handles: Audio detection, AudioPlayer rendering
- Or include in a more general `PageContent` component

### 3. Add Architecture Documentation
- Add header comments to `TabScreen.tsx` and `PageScreen.tsx` explaining:
  - When each is used
  - Navigation method differences
  - Feature parity requirements
- Consider adding `docs/navigation-architecture.md` if needed

### 4. Tests Still Pass
- `audio-verification-simple.yaml` passes
- `ticket-023-audio-player-testids.yaml` passes
- No regressions in existing functionality

## Notes

- This is a refactoring ticket - no new features, just better structure
- Keep changes incremental and test after each extraction
- The goal is DRY code, not premature abstraction - only extract what's truly duplicated

## References

- Related: [087](087-collection-item-navigation-broken.md) - Exposed this issue
- `rn-mip-app/components/TabScreen.tsx`
- `rn-mip-app/components/PageScreen.tsx`
- `rn-mip-app/app/page/[uuid].tsx`
