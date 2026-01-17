---
status: blocked
area: rn-mip-app
phase: core
created: 2026-01-17
---

# Homepage Touch Handling on Real Devices

Status: Blocked until testing on a real device with a finger to touch.

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

## Design Recommendations

Based on research of Apple HIG, Material Design, and React Native best practices:

### Key Insight

**The problem:** Standard React Native TouchableOpacity responds immediately to touch, before the system can determine if the user intends to scroll or tap.

**The solution:** Add a slight delay before registering taps, giving scroll gestures time to be recognized first. If the user doesn't start scrolling within that delay, the tap is registered.

### Recommended Changes

#### 1. ContentCard TouchableOpacity Props

```tsx
<TouchableOpacity
  delayPressIn={100}      // 100ms delay before visual feedback - allows scroll to start
  activeOpacity={0.7}     // Visible feedback when tap is registered
  // ... existing props
>
```

**Why:** The `delayPressIn` gives the scroll gesture recognition system time to claim the touch. If user starts moving finger, scroll takes over. If finger stays still, tap registers after 100ms.

#### 2. Horizontal ScrollView Props (Carousel)

```tsx
<ScrollView
  horizontal
  delaysContentTouches={false}  // Allow immediate scroll detection on iOS
  canCancelContentTouches={true} // Cancel tap if scroll starts (iOS)
  nestedScrollEnabled={true}    // Required for Android nested scrolling
  // ... existing props
>
```

**Why:** 
- `delaysContentTouches={false}` lets iOS detect scroll gestures immediately
- `canCancelContentTouches={true}` cancels any tap-in-progress if scrolling begins
- `nestedScrollEnabled` fixes Android nested scroll issues

#### 3. Main Vertical ScrollView Props

```tsx
<ScrollView
  delaysContentTouches={false}  // Allow immediate scroll detection
  canCancelContentTouches={true} // Cancel tap if scroll starts
  // ... existing props
>
```

### Touch Target Guidelines

Per Apple HIG, all touch targets should be minimum 44×44 points. Current ContentCard implementation already meets this requirement.

### Trade-offs Considered

| Approach | Pros | Cons | Decision |
|----------|------|------|----------|
| `delayPressIn={100}` | Simple, no new dependencies | 100ms latency on intentional taps | **Use** - 100ms is imperceptible |
| `delayPressIn={0}` with gesture handler | Zero latency | Requires new dependency | Skip for now |
| `delaysContentTouches={false}` | Better scroll response | May feel "sticky" on some devices | **Use** - standard iOS pattern |

### What We're NOT Doing

- **Not installing react-native-gesture-handler** - Standard props should suffice for this use case
- **Not adding custom gesture recognizers** - Would add complexity without clear benefit
- **Not changing touch target sizes** - Already adequate

## Research Findings (Scouted)

### Current Code State

| Component | File | Line | Current Props |
|-----------|------|------|---------------|
| Main ScrollView | `HomeScreen.tsx` | 224 | `style`, `contentContainerStyle` only |
| Horizontal ScrollView | `HomeScreen.tsx` | 276 | `horizontal`, `showsHorizontalScrollIndicator`, `scrollEventThrottle` |
| ContentCard | `ContentCard.tsx` | 24 | `style`, `onPress`, `testID`, `accessibilityLabel`, `accessibilityRole` |

### Implementation Plan

1. **ContentCard.tsx:** Add `delayPressIn={100}` and `activeOpacity={0.7}` to TouchableOpacity
2. **HomeScreen.tsx:** Add scroll props to main vertical ScrollView
3. **HomeScreen.tsx:** Add scroll props to horizontal carousel ScrollView

### Files to Change

| File | Changes |
|------|---------|
| `rn-mip-app/components/ContentCard.tsx` | Add `delayPressIn` and `activeOpacity` props |
| `rn-mip-app/components/HomeScreen.tsx` | Add `delaysContentTouches`, `canCancelContentTouches`, `nestedScrollEnabled` to ScrollViews |

## References

- [Ticket #074](074-scrollable-cards-indicators.md) - Scrollable Cards implementation
- [Apple HIG - Touch Targets](https://developer.apple.com/design/tips/) - Minimum 44×44 points
- [React Native ScrollView](https://reactnative.dev/docs/scrollview) - delaysContentTouches, canCancelContentTouches
- [Material Design Gestures](https://m1.material.io/patterns/gestures.html) - Scroll vs tap thresholds
