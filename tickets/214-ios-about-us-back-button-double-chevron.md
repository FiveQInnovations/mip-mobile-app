---
status: done
area: ios-mip-app
phase: core
created: 2026-01-24
---

# iOS About Us Page Shows Double Chevron in Back Button

## Context

When navigating to the "About Us" page, the back button displays incorrectly with an extra left chevron - one before the word "Back" and one after.

## Problem

The custom back button implementation in `TabPageView` is showing alongside SwiftUI's default back button, resulting in duplicate chevrons.

## Goals

1. Remove duplicate chevron from back button
2. Ensure only one back button appears (either custom or default)
3. Fix navigation bar appearance for About Us and similar pages

## Acceptance Criteria

- Back button shows only one chevron (not two)
- Back button text/label is correct
- Navigation works correctly when tapping back
- No visual artifacts or duplicate UI elements

## Related Files

- `ios-mip-app/FFCI/Views/TabPageView.swift` (lines 94-103 - custom back button)
- `ios-mip-app/FFCI/Views/HomeView.swift` (navigation stack setup)

## Notes

- Custom back button is added via `ToolbarItem` with `chevron.left` icon (line 98)
- SwiftUI may be showing default back button alongside custom one
- May need to hide default back button using `navigationBarBackButtonHidden(true)` or adjust toolbar configuration
- Check if About Us is navigated to differently than other pages (e.g., from Quick Actions vs tab)

---

## Research Findings (Scouted)

### Root Cause Analysis

The double chevron issue occurs due to incorrect logic in the `canGoBack` computed property. Here's the data flow:

**Navigation Hierarchy:**
1. `HomeView` creates a `NavigationStack` (HomeView.swift:23)
2. When user taps a quick task/featured item, `NavigationLink` pushes `TabPageView` onto the stack
3. `TabPageView` creates its OWN `NavigationStack` (TabPageView.swift:35) for internal drill-down navigation
4. This creates nested NavigationStacks

**The Bug:**
```swift
// Lines 26-32 in TabPageView.swift
var currentUuid: String {
    pageStack.isEmpty ? uuid : pageStack.last!
}

var canGoBack: Bool {
    !pageStack.isEmpty  // ❌ BUG: This is WRONG
}
```

**What Happens:**
1. TabPageView initializes with empty `pageStack` (line 15)
2. On first load, the `.task` modifier runs (line 112-117)
3. Line 113-115 checks if pageStack is empty and initializes it:
   ```swift
   if pageStack.isEmpty {
       pageStack = [uuid]  // ❌ Adds initial page to stack!
   }
   ```
4. Now `pageStack.count == 1`, so `canGoBack` returns `true`
5. Custom back button appears (lines 94-103) even though user hasn't navigated anywhere yet
6. SwiftUI ALSO shows its default back button (to return to HomeView)
7. **Result: Two chevrons appear**

### Implementation Plan

**Step 1: Fix the canGoBack Logic**

File: `ios-mip-app/FFCI/Views/TabPageView.swift`
Lines: 30-32

Change from:
```swift
var canGoBack: Bool {
    !pageStack.isEmpty
}
```

To:
```swift
var canGoBack: Bool {
    pageStack.count > 1
}
```

**Reasoning:** The pageStack is initialized with the root page (count = 1). The custom back button should only appear when the user has navigated deeper (count > 1). When count = 1, we're at the root level of TabPageView, and only SwiftUI's default back button should show.

**Step 2: Optional Enhancement - Hide Default Back Button for Internal Navigation**

When user drills into collections (pageStack.count > 1), we might want to hide SwiftUI's default back button to avoid confusion. However, this is optional and may not be necessary.

File: `ios-mip-app/FFCI/Views/TabPageView.swift`
Line: 104 (after the toolbar block)

Add:
```swift
.navigationBarBackButtonHidden(canGoBack)
```

This hides the default back button when our custom one is showing.

### Code Locations

| File | Lines | Purpose | Change Needed |
|------|-------|---------|---------------|
| `ios-mip-app/FFCI/Views/TabPageView.swift` | 30-32 | `canGoBack` computed property | **MUST CHANGE**: Fix condition from `!pageStack.isEmpty` to `pageStack.count > 1` |
| `ios-mip-app/FFCI/Views/TabPageView.swift` | 15 | `pageStack` state variable | No change - understand this starts empty |
| `ios-mip-app/FFCI/Views/TabPageView.swift` | 113-115 | Initial pageStack setup in `.task` | No change - this is correct behavior |
| `ios-mip-app/FFCI/Views/TabPageView.swift` | 94-103 | Custom back button toolbar item | No change - logic is correct |
| `ios-mip-app/FFCI/Views/TabPageView.swift` | 104 | After toolbar block | **OPTIONAL**: Add `.navigationBarBackButtonHidden(canGoBack)` |
| `ios-mip-app/FFCI/Views/HomeView.swift` | 23 | NavigationStack for home | No change - provides navigation context |
| `ios-mip-app/FFCI/Views/ResourcesScrollView.swift` | 50 | NavigationLink to TabPageView | No change - navigation is correct |
| `ios-mip-app/FFCI/Views/FeaturedSectionView.swift` | 33 | NavigationLink to TabPageView | No change - navigation is correct |

### Variables/Data Reference

**Key State Variables:**
- `pageStack: [String]` (line 15) - Array of UUIDs tracking navigation within TabPageView
  - Starts empty: `[]`
  - Initialized to `[uuid]` on first load (line 114)
  - Items added via `navigateToPage()` (line 202)
  - Items removed via `goBack()` (line 208)

**Key Computed Properties:**
- `currentUuid: String` (lines 26-28) - Returns the current page UUID (last item in stack, or root uuid if empty)
- `canGoBack: Bool` (lines 30-32) - **THE BUG** - Should check `count > 1`, not `!isEmpty`

**Navigation Flow:**
1. User taps quick task/featured item → `NavigationLink` pushes TabPageView
2. TabPageView loads → pageStack initialized to `[rootUuid]`
3. User clicks collection item → `HtmlContentView` calls `onNavigate` callback (line 58-60)
4. `navigateToPage()` appends to pageStack (line 202)
5. Custom back button appears and works correctly for internal navigation

### Edge Cases & Other Affected Views

**Views NOT Affected:**
- When TabPageView is used directly as a tab (ContentView.swift:92), it shows no back button (neither default nor custom) because there's no navigation stack above it
- This issue ONLY occurs when TabPageView is reached via NavigationLink from HomeView

**Testing Scenarios:**
1. ✅ Navigate to "About Us" from Quick Actions → Should show ONE back button (SwiftUI default)
2. ✅ Navigate to "About Us", then drill into a collection → Should show ONE back button (custom)
3. ✅ Use TabPageView directly as a tab → Should show NO back button
4. ✅ Navigate multiple levels deep → Back button should work correctly at each level

### Estimated Complexity

**Low** - Single line fix that addresses the root cause. The logic error is clear, the fix is straightforward, and the behavior is well-understood. Optional enhancement adds one line. No architectural changes needed.
