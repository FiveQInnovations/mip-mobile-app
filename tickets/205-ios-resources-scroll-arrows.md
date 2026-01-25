---
status: qa
area: ios-mip-app
phase: core
created: 2026-01-24
---

# iOS Resources Section Scroll Arrows

## Context

The iOS home screen has a horizontal scrollable "Resources" section (Quick Actions), but lacks the scroll arrow indicators that Android and React Native have. These arrows provide visual cues that content is scrollable and allow users to navigate cards more easily.

## Problem

Users may not realize the Resources section is scrollable. The iOS app shows the horizontal scroll with partial card visibility but lacks the left/right arrow buttons that Android and RN provide.

## Goals

1. Add left/right scroll arrow overlays on the Resources section
2. Show/hide arrows based on scroll position
3. Allow tap-to-scroll functionality (scroll one card at a time)
4. Match Android/RN visual design (circular white buttons with chevrons)

## Acceptance Criteria

- Left arrow appears when scrolled past the first card
- Right arrow appears when more cards are available to scroll
- Left arrow hidden at scroll position 0 (start)
- Right arrow hidden when at end of scroll content
- Arrows are positioned at vertical center of the card row
- Tapping arrows scrolls one card width with animation
- Arrows have white circular background with shadow
- Arrows use SF Symbol chevron icons

## Android Reference Implementation

**File:** `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/screens/HomeScreen.kt:274-350`

**Key Features:**
- Uses `LazyRow` with `rememberLazyListState()` for scroll state
- Tracks `canScrollLeft` and `canScrollRight` with `derivedStateOf`
- `canScrollLeft = scrollState.canScrollBackward`
- `canScrollRight = scrollState.canScrollForward`
- Arrows positioned with `Alignment.CenterStart` and `Alignment.CenterEnd`
- Tap scrolls `cardWidth + spacing` (296dp)
- Animated scroll with `animateScrollToItem()`

**Arrow Styling:**
- `IconButton` with `Surface` wrapper
- CircleShape background
- White color with 0.95 alpha
- 40dp size
- 4dp shadow elevation
- 8dp offset from edge

## React Native Reference Implementation

**File:** `rn-mip-app/components/HomeScreen.tsx:315-337`

**Scroll State Tracking (lines 190-191):**
```javascript
setCanScrollLeft(offsetX > 5);
setCanScrollRight(offsetX < maxScroll - 5);
```

**Arrow Styling (lines 434-455):**
- Position: absolute
- 40x40 circular button
- White background with shadow
- Centered vertically (`top: '50%', marginTop: -20`)
- Left arrow: 8px from left edge
- Right arrow: 8px from right edge

## iOS Implementation Notes

### Files to Modify

**ios-mip-app/FFCI/Views/HomeView.swift (lines 68-94)**

Current implementation:
```swift
ScrollView(.horizontal, showsIndicators: false) {
    HStack(spacing: 16) {
        ForEach(quickTasks, id: \.uuid) { task in
            ResourcesCard(...)
        }
    }
    .padding(.horizontal, 16)
}
```

### State Variables to Add

```swift
@State private var scrollOffset: CGFloat = 0
@State private var contentWidth: CGFloat = 0
@State private var containerWidth: CGFloat = 0

var canScrollLeft: Bool {
    scrollOffset > 5
}

var canScrollRight: Bool {
    scrollOffset < (contentWidth - containerWidth - 5)
}
```

### Scroll Position Tracking

Option 1 - GeometryReader + PreferenceKey:
```swift
ScrollView(.horizontal, showsIndicators: false) {
    HStack(spacing: 16) { ... }
    .background(GeometryReader { geo in
        Color.clear.preference(key: ScrollOffsetKey.self, value: geo.frame(in: .named("scroll")).minX)
    })
}
.coordinateSpace(name: "scroll")
.onPreferenceChange(ScrollOffsetKey.self) { value in
    scrollOffset = -value
}
```

Option 2 - ScrollViewReader (simpler, iOS 14+):
- Use `ScrollViewReader` with `scrollTo(_:anchor:)` for animated scrolling
- Track position with `onAppear` on items

### Arrow Button Component

```swift
struct ScrollArrowButton: View {
    let direction: Direction
    let action: () -> Void
    
    enum Direction {
        case left, right
        
        var iconName: String {
            self == .left ? "chevron.left" : "chevron.right"
        }
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: direction.iconName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.95))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
        }
    }
}
```

### UI Structure

```swift
ZStack {
    // Horizontal ScrollView
    ScrollView(.horizontal, showsIndicators: false) { ... }
    
    // Left arrow
    if canScrollLeft {
        HStack {
            ScrollArrowButton(direction: .left) { scrollLeft() }
                .padding(.leading, 8)
            Spacer()
        }
    }
    
    // Right arrow
    if canScrollRight {
        HStack {
            Spacer()
            ScrollArrowButton(direction: .right) { scrollRight() }
                .padding(.trailing, 8)
        }
    }
}
```

### Scroll Action

Scroll by card width (approximately 280 + 16 spacing = 296 points):
```swift
func scrollLeft() {
    // Scroll left by one card width
}

func scrollRight() {
    // Scroll right by one card width
}
```

## Related Tickets

- Ticket 074: Original RN implementation for scrollable cards indicators (done)

## Related Files

- `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/screens/HomeScreen.kt:274-350`
- `rn-mip-app/components/HomeScreen.tsx:315-337, 434-455`
- `ios-mip-app/FFCI/Views/HomeView.swift:68-94`

## Estimated Complexity

**Medium** — SwiftUI scroll position tracking requires GeometryReader/PreferenceKey pattern which adds complexity, but the visual implementation is straightforward.
