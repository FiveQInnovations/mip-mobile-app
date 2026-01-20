---
status: done
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

## Investigation Findings

### Code Changes Attempted:
- Replaced TouchableOpacity with Pressable
- Added `pointerEvents="none"` to child elements
- Added `hitSlop` for larger touch area
- Added visual feedback (opacity changes)
- Added console.log debugging
- Added testID to collection items

### Test Results:
1. **Maestro tap by text** - Tap "completes" but no navigation occurs
2. **Maestro tap by testID** - testID not found in accessibility tree
3. **Visual-tester manual tap** - Confirmed tap registers but nothing happens

### Key Observation:
The `testID` attribute on the Pressable component is NOT appearing in the iOS accessibility tree. This suggests:
1. The Pressable may not be properly exposing accessibility attributes
2. There may be an issue with how React Native's new architecture handles testID
3. The ScrollView parent may be interfering with touch propagation

### Verified Working:
- API returns correct uuid for children (confirmed in code review)
- The `navigateToPage()` function works for other navigations (HTMLContentRenderer links)
- Collection items ARE displayed correctly

### Root Cause Hypothesis:
The touch events are being intercepted somewhere between the UI and the Pressable's onPress handler. The fact that testID doesn't appear in the accessibility tree suggests the Pressable component isn't properly registering with the accessibility system, which may be related to the touch issue.

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
