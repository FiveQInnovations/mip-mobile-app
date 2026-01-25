---
status: done
area: ios-mip-app
phase: core
created: 2026-01-24
---

# iOS About Us Card Not Clickable on Home Screen

## Context

On the iOS app home screen, users cannot click on the 'About Us' card in the Resources / Quick Actions section. The card appears visually but does not respond to taps/clicks.

## Goals

1. Fix touch handling for Resources cards on the home screen
2. Ensure all cards in the Resources section are clickable and navigate correctly

## Acceptance Criteria

- Users can tap/click the 'About Us' card on the home screen
- Tapping the card navigates to the About Us page
- All other cards in the Resources section remain clickable
- Touch handling works consistently across all Resources cards

## Notes

- The Resources section uses a horizontal ScrollView with ResourcesCard components
- ResourcesCard uses Button with PlainButtonStyle
- May be related to touch handling conflicts with the ScrollView
- Similar to ticket 077 (Homepage Touch Handling on Real Devices) but specific to iOS Resources cards

## References

- `ios-mip-app/FFCI/Views/HomeView.swift` - ResourcesCard component implementation
- Ticket 077 - Homepage Touch Handling on Real Devices (Android/RN)

---

## Research Findings (Scouted)

### Root Cause Analysis

The issue is a **known SwiftUI limitation** with Buttons inside horizontal ScrollViews. The ScrollView's pan gesture recognizer intercepts touch events before they can reach the Button's tap gesture recognizer, making the buttons unresponsive.

**Why this happens:**
- SwiftUI's gesture recognition system prioritizes scroll gestures in ScrollViews
- When a user touches a ResourcesCard, the ScrollView captures the touch first to detect potential scrolling
- The Button never receives the tap event because the ScrollView doesn't release it
- This is specific to horizontal ScrollViews containing interactive elements

### Cross-Platform Comparison

#### React Native Implementation (Working)
File: `rn-mip-app/components/HomeScreen.tsx`

Lines 285-297 show the working solution:
```tsx
<ScrollView 
  horizontal 
  delaysContentTouches={false}      // Allow immediate touch detection
  canCancelContentTouches={true}    // Cancel tap if scroll starts
  nestedScrollEnabled={true}        // Android nested scroll support
>
```

**Strategy**: RN gives child components (cards) first chance at touch events, then cancels them if scrolling begins.

#### Android Implementation (Working)
File: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/screens/HomeScreen.kt`

Lines 387-390 show the working solution:
```kotlin
Card(
    modifier = modifier
        .width(280.dp)
        .clickable(onClick = onClick),  // Jetpack Compose handles touch correctly
```

**Strategy**: Compose's `clickable` modifier and `LazyRow` automatically handle touch delegation properly.

### iOS Current Implementation (Broken)

File: `ios-mip-app/FFCI/Views/HomeView.swift`

**Lines 76-90 - ScrollView container:**
```swift
ScrollView(.horizontal, showsIndicators: false) {
    HStack(spacing: 16) {
        ForEach(quickTasks, id: \.uuid) { task in
            ResourcesCard(
                task: task,
                onClick: {
                    if let uuid = task.uuid {
                        onQuickTaskClick(uuid)
                    }
                }
            )
        }
    }
    .padding(.horizontal, 16)
}
```

**Lines 215-263 - ResourcesCard implementation:**
```swift
struct ResourcesCard: View {
    let task: HomepageQuickTask
    let onClick: () -> Void
    
    var body: some View {
        Button(action: onClick) {
            // ... card content ...
        }
        .buttonStyle(PlainButtonStyle())  // Line 261
    }
}
```

**The problem**: No gesture priority configuration. The ScrollView's pan gesture always wins.

### Implementation Plan

**Solution: Use `.onTapGesture()` with higher priority instead of Button**

SwiftUI provides gesture priority modifiers that solve this exact issue:

1. Replace `Button(action: onClick)` with a VStack + `.onTapGesture()`
2. OR add `.simultaneousGesture(TapGesture().onEnded { onClick() })` to the Button

**Option 1: Replace Button with onTapGesture (Recommended)**

```swift
struct ResourcesCard: View {
    let task: HomepageQuickTask
    let onClick: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ... existing card content ...
        }
        .frame(width: 280)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .onTapGesture {
            onClick()
        }
    }
}
```

**Why this works:**
- `.onTapGesture()` has higher priority than ScrollView's pan gesture
- SwiftUI automatically handles the gesture conflict resolution
- Scrolling still works if the user moves their finger before lifting

**Option 2: Add simultaneousGesture to Button (Alternative)**

```swift
Button(action: {}) {  // Empty action
    // ... existing content ...
}
.buttonStyle(PlainButtonStyle())
.simultaneousGesture(
    TapGesture().onEnded {
        onClick()
    }
)
```

**Why this works:**
- Explicitly registers a tap gesture with simultaneous priority
- Tells SwiftUI to allow both scroll and tap gestures to coexist
- Tap wins if finger doesn't move; scroll wins if finger moves

### Code Locations

| File | Line Range | Purpose | Change Required |
|------|------------|---------|-----------------|
| `ios-mip-app/FFCI/Views/HomeView.swift` | 215-263 | ResourcesCard implementation | Replace Button with VStack + onTapGesture |
| `ios-mip-app/FFCI/Views/HomeView.swift` | 220-261 | Button wrapper | Remove Button, keep content |
| `ios-mip-app/FFCI/Views/HomeView.swift` | 261 | .buttonStyle(PlainButtonStyle()) | Remove this line |

### Comparison with Working iOS Components

**FeaturedCard (Lines 118-213) - Why it works:**
- NOT inside a horizontal ScrollView
- Inside a vertical ForEach in a regular VStack
- No gesture conflicts with parent container

**CollectionListItem** (`CollectionListView.swift` Lines 36-68) - Why it works:
- NOT inside a ScrollView
- Inside a vertical VStack/ForEach
- No gesture conflicts

### Variables/Data Reference

**No data structure changes needed.**

The `HomepageQuickTask` model and `onQuickTaskClick` callback remain unchanged:

```swift
struct HomepageQuickTask {
    let uuid: String?
    let label: String?
    let description: String?
    let imageUrl: String?
}
```

### Testing Checklist

After implementing the fix:

1. **Tap Recognition**
   - [ ] Tap on "About Us" card navigates to About Us page
   - [ ] Tap on other Resources cards navigates correctly
   - [ ] Visual feedback on tap (if using Button variant)

2. **Scroll Functionality**
   - [ ] Horizontal scrolling still works smoothly
   - [ ] Cards don't navigate if user scrolls instead of taps
   - [ ] Scroll arrows (ticket 205) still function correctly

3. **Edge Cases**
   - [ ] Quick tap-and-lift works (doesn't require long press)
   - [ ] Tapping while scrolling is ending doesn't navigate
   - [ ] Works on real iOS device (not just simulator)

4. **Regression Testing**
   - [ ] FeaturedCard still works (should be unaffected)
   - [ ] Other buttons on home screen still work
   - [ ] Navigation to other tabs works

### Estimated Complexity

**Low** - 15-30 minutes

**Reasoning:**
- Simple, well-documented SwiftUI pattern
- Changes contained to one component (ResourcesCard)
- No data model changes
- No API changes
- Similar pattern already used in other SwiftUI apps
- Clear test cases

### Related Research

**From Ticket 077 (React Native touch handling):**
- Documented the `delaysContentTouches` pattern for RN
- Same underlying issue: parent scroll container vs child tap targets
- RN solution: Give children first chance, then cancel if scroll starts
- iOS solution: Use gesture priority system instead

**From Ticket 074 (Scrollable cards indicators):**
- Implemented scroll arrows for Resources section
- Scroll functionality already working correctly
- This fix ensures cards are tappable while preserving scroll behavior

### Additional Notes

**Why PlainButtonStyle isn't enough:**
- `PlainButtonStyle` only affects visual styling, not gesture recognition priority
- The gesture conflict happens at a lower level in the view hierarchy
- Need to explicitly configure gesture priority with `.onTapGesture()` or `.simultaneousGesture()`

**Recommended approach:**
Use Option 1 (replace Button with onTapGesture) because:
- Cleaner, more explicit code
- Standard SwiftUI pattern for this exact use case
- Better documented in Apple's SwiftUI tutorials
- Less nested view hierarchy
