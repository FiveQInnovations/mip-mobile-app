---
status: qa
area: ios-mip-app
phase: core
created: 2026-01-24
---

# iOS Quick Actions Right Arrow Should Scroll to Instagram

## Context

After fixing the Quick Actions order (ticket 212), the horizontal scrolling right arrow should be able to scroll all the way to Instagram at the end of the list.

## Problem

The right scroll arrow may not be calculating the scroll position correctly to reach the last card (Instagram) when it's properly positioned as the last item.

## Goals

1. Verify right arrow can scroll to the last Quick Action card (Instagram)
2. Ensure scroll position calculation accounts for all cards including the last one
3. Right arrow should disappear when scrolled to the end

## Acceptance Criteria

- Right arrow appears when not at the end of the scroll
- Right arrow can scroll to Instagram (last card)
- Right arrow disappears when scrolled to Instagram
- Left arrow appears when scrolled past the first card
- Scroll animation is smooth and reaches the end position correctly

## Related Files

- `ios-mip-app/FFCI/Views/ResourcesScrollView.swift` (scroll tracking logic)
- `ios-mip-app/FFCI/Views/HomeView.swift`

## Dependencies

- Ticket 212 must be completed first (Instagram must be last item)

## Notes

- Current scroll tracking uses `ScrollTracker` class
- Scroll position calculation may need adjustment for the last card
- Anchor point for last card scroll uses `.trailing` (line 106 in ResourcesScrollView.swift)

---

## Research Findings (Scouted)

### Root Cause Analysis

**Problem identified:** Scroll offset tracking becomes out of sync when scrolling to the last card (Instagram).

**Location:** `ios-mip-app/FFCI/Views/ResourcesScrollView.swift`, lines 103-111

The right arrow button has a **mismatch between manual offset calculation and actual scroll behavior**:

```swift
ScrollArrowButton(direction: .right) {
    let targetIndex = min(quickTasks.count - 1, scrollTracker.visibleIndex + 1)
    let itemWidth = cardWidth + cardSpacing
    let targetOffset = CGFloat(targetIndex) * itemWidth  // Line 106
    scrollTracker.updateScrollOffset(targetOffset)       // Line 107 - PROBLEM
    withAnimation(.easeInOut(duration: 0.3)) {
        let anchor: UnitPoint = targetIndex == quickTasks.count - 1 ? .trailing : .leading  // Line 109
        scrollProxy.scrollTo(targetIndex, anchor: anchor)  // Line 110
    }
}
```

**The Issue:**
1. **Line 107** manually sets scroll offset assuming `.leading` anchor alignment
2. **Line 109-110** actually scrolls using `.trailing` anchor for the last card
3. Result: ScrollTracker believes it's at position `targetIndex * itemWidth`, but the view actually scrolled further to align the card's trailing edge
4. `canScrollRight` calculation (ScrollTracker.swift line 27-29) uses the wrong offset
5. Arrow either doesn't disappear or doesn't scroll far enough to show Instagram

### Current Implementation Details

#### ScrollTracker Class (`ios-mip-app/FFCI/Views/ScrollTracker.swift`)

**Key Properties:**
- `scrollOffset: CGFloat` (line 11) - Current scroll position
- `contentWidth: CGFloat` (line 12) - Total scrollable content width
- `containerWidth: CGFloat` (line 13) - Visible container width
- `visibleIndex: Int` (line 14) - Current visible card index

**Arrow Visibility Logic:**
```swift
// Line 19-21
var maxScrollOffset: CGFloat {
    max(contentWidth - containerWidth, 0)
}

// Line 27-29
var canScrollRight: Bool {
    scrollOffset < (maxScrollOffset - 5)  // 5px threshold
}
```

**Offset Update Method:**
```swift
// Line 36-40
func updateScrollOffset(_ value: CGFloat) {
    let clampedOffset = min(max(value, 0), maxScrollOffset)
    scrollOffset = clampedOffset
    visibleIndex = calculateVisibleIndex()
}
```

#### ResourcesScrollView Scroll Tracking

**Automatic offset tracking** (lines 75-77):
```swift
.onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
    scrollTracker.updateScrollOffset(value)
}
```

This preference key reads the actual scroll position using GeometryReader (lines 66-72).

### Implementation Plan

**Option 1: Remove Manual Offset Update (Recommended)**
- **File:** `ResourcesScrollView.swift`, line 107
- **Change:** Remove `scrollTracker.updateScrollOffset(targetOffset)` call
- **Reason:** Let the preference key (lines 75-77) update the offset naturally after scroll animation completes
- **Risk:** Low - scroll tracking will sync automatically from GeometryReader

**Option 2: Calculate Correct Offset for Trailing Anchor**
- **File:** `ResourcesScrollView.swift`, lines 103-111
- **Change:** Calculate different offset when using `.trailing` anchor:
  ```swift
  let targetOffset = if targetIndex == quickTasks.count - 1 {
      maxScrollOffset  // Use max offset for last card
  } else {
      CGFloat(targetIndex) * itemWidth  // Use leading calculation for others
  }
  ```
- **Requires:** Access to `maxScrollOffset` from ScrollTracker
- **Risk:** Medium - requires precise calculation of max scroll position

**Option 3: Use Leading Anchor for All Cards**
- **File:** `ResourcesScrollView.swift`, line 109
- **Change:** Always use `.leading` anchor, remove conditional
- **Risk:** Medium - Last card might not scroll fully into view if content width calculation is off

### Code Locations

| File | Lines | Purpose | Changes Needed |
|------|-------|---------|----------------|
| `ios-mip-app/FFCI/Views/ResourcesScrollView.swift` | 103-111 | Right arrow button logic | Remove line 107 OR fix offset calculation |
| `ios-mip-app/FFCI/Views/ResourcesScrollView.swift` | 75-77 | Automatic scroll tracking | No changes - already correct |
| `ios-mip-app/FFCI/Views/ScrollTracker.swift` | 27-29 | Arrow visibility logic | No changes - calculation is correct |
| `ios-mip-app/FFCI/Views/ScrollTracker.swift` | 36-40 | Offset update method | No changes - method is correct |

### Edge Cases to Consider

1. **Different screen sizes:** iPhone SE vs iPhone 15 Pro Max have different container widths
2. **Dynamic content:** Number of Quick Action cards may vary (currently 5 cards)
3. **Animation timing:** Offset update happens immediately, but scroll animates over 0.3s
4. **Content width estimation:** Lines 19-24 estimate content width, might not match actual measured width

### Existing Test Coverage

**Maestro test:** `ios-mip-app/maestro/flows/ticket-205-resources-scroll-arrows-ios.yaml`
- Tests right arrow scrolling to end (lines 37-87)
- Asserts right arrow disappears at end (lines 89-90)
- Tests left arrow scrolling back to start (lines 96-135)
- Currently passing, but may not verify Instagram is fully visible

**Maestro test:** `ios-mip-app/maestro/flows/ticket-212-instagram-last-ios.yaml`
- Scrolls to end using right arrow (lines 41-63)
- Asserts Instagram text is visible (lines 71-73)
- Does NOT verify arrow disappears

### Recommended Solution

**Remove manual offset update on line 107** - simplest and safest fix:

1. The manual update causes sync issues
2. The preference key already tracks scroll position automatically
3. Removing it lets the system naturally sync after animation completes
4. No complex calculations needed

**Test verification:**
- Run `ticket-205-resources-scroll-arrows-ios.yaml` - should still pass
- Run `ticket-212-instagram-last-ios.yaml` - should still pass
- Create new test to specifically verify right arrow disappears when Instagram is visible

### Estimated Complexity

**Low** - Single line removal or simple conditional logic change

- Implementation: 5 minutes
- Testing: 10 minutes (run existing Maestro tests + manual verification)
- Total: ~15 minutes
