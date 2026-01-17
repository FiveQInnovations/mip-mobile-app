---
status: backlog
area: rn-mip-app
phase: core
created: 2026-01-17
---

# Homepage Touch Handling on Real Devices

## Context

The homepage works well in the iOS Simulator. However, there are concerns that on a real device, touch gestures may be misinterpreted:

1. **Horizontal scrolling (card carousels):** The gesture to scroll horizontally through the cards may be misinterpreted as a tap on a card, causing it to open unexpectedly instead of scrolling.

2. **Vertical scrolling (main page):** When scrolling vertically through the homepage, touches may accidentally register as taps on cards or other interactive elements.

Simulators use mouse clicks which have different behavior than touch gestures on physical devices. Touch interactions involve gestures like swipe vs tap that need to be properly distinguished.

## Goals

1. Research best practices for handling touch gestures in scrollable components
2. Ensure horizontal scroll gestures are not misinterpreted as card taps
3. Ensure vertical scroll gestures are not misinterpreted as taps on interactive elements
4. Test on real devices to verify behavior

## Acceptance Criteria

- Users can scroll horizontally through cards without accidentally opening them
- Users can scroll vertically through the homepage without accidentally tapping cards
- Tapping a card still works reliably to open it
- Scroll gestures feel natural and responsive on real devices
- Behavior is consistent between iOS and Android

## Research Notes

Areas to investigate:
- React Native ScrollView touch handling and `delaysContentTouches` prop
- TouchableOpacity/Pressable gesture thresholds
- `hitSlop` configuration for touch targets
- Gesture responder system configuration
- Whether react-native-gesture-handler provides better control

## References

- [Ticket #074](074-scrollable-cards-indicators.md) - Scrollable Cards implementation
- React Native Touch Handling docs
- react-native-gesture-handler documentation
