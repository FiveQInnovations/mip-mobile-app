---
status: in-progress
area: rn-mip-app
phase: core
created: 2026-01-17
---

# Collection Item Navigation Broken

## Context

When viewing a collection page (e.g., Audio Sermons), tapping on a collection item (e.g., "God's Power Tools") does not navigate to the item detail page. The tap appears to register but the screen remains on the collection list view.

This was discovered while testing ticket 023 (AudioPlayer testIDs). The AudioPlayer component is correctly implemented but cannot be verified because users cannot navigate to individual audio items.

## Evidence

- Maestro test `ticket-023-audio-player-testids.yaml` navigates to "Audio Sermons" collection successfully
- Collection shows "God's Power Tools" item correctly (ticket 083 fix is working)
- Tapping "God's Power Tools" does NOT navigate to the item detail page
- Screenshot evidence: `maestro/screenshots/023-audio-item-page.png` shows collection list, not item detail

## Root Cause Investigation Needed

The navigation handler in `TabScreen.tsx` line 305:
```tsx
onPress={() => navigateToPage(child.uuid)}
```

Possible issues:
1. `child.uuid` may be undefined or null
2. `navigateToPage()` may be silently failing
3. API response may not include uuid for children

## Goals

1. Investigate why collection item taps don't navigate
2. Fix the navigation to work properly
3. Verify AudioPlayer can be tested end-to-end

## Acceptance Criteria

- Tapping a collection item navigates to the item detail page
- Audio items show the AudioPlayer component
- Maestro test `ticket-023-audio-player-testids.yaml` passes

## Notes

- Blocking ticket 023 from being fully verified
- Collection listing works fine (ticket 083 fix)
- Navigation to collections from cards works (e.g., tapping "Audio Sermons" card)
- Only navigation FROM collection TO item is broken

## References

- Related: [023](023-audio-player-component.md) - AudioPlayer testIDs
- Related: [083](083-audio-sermons-collection-integration.md) - Audio Sermons Collection
- Code location: `rn-mip-app/components/TabScreen.tsx` lines 301-320
