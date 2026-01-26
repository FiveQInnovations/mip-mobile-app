---
status: done
area: ios-mip-app
phase: core
created: 2026-01-26
---

# iOS Back Button Style Consistency

## Context

Follow-up from ticket 214. After fixing the double chevron issue, there are now two different back button styles appearing at different navigation levels within TabPageView.

## Problem

1. **Root level** (e.g., About page): Shows SwiftUI default "< Back" with text label
2. **Drilled level** (e.g., Mission & Vision): Shows custom chevron only, no text, slightly different position

The chevron positions are also slightly different between the two styles.

## Goals

1. Make back button style consistent across all navigation levels
2. Ensure chevron is in the same position regardless of navigation depth

## Acceptance Criteria

- Back button looks the same at root level and drilled level
- Chevron is in consistent position
- Either both have "Back" label or neither has it (consistency is the goal)
- Navigation still works correctly at all levels

## Related Files

- `ios-mip-app/FFCI/Views/TabPageView.swift` (custom back button at lines 94-103)

## Notes

- Currently root level shows SwiftUI default (because `canGoBack` is false)
- Drilled level shows custom back button (because `canGoBack` is true)
- Solution: Either add "Back" text to custom button OR hide default and use custom styling everywhere

## Implementation

Added "Back" text to the custom back button to match SwiftUI's default style:

```swift
Button(action: goBack) {
    HStack(spacing: 4) {
        Image(systemName: "chevron.left")
        Text("Back")
    }
    .foregroundColor(Color("PrimaryColor"))
}
```

### Files Modified

- `ios-mip-app/FFCI/Views/TabPageView.swift` - Updated custom back button to include "Back" text

### Verification

- Maestro test: `ios-mip-app/maestro/flows/ticket-215-back-button-style-consistency-ios.yaml`
- Test passes: Back button now shows "< Back" consistently at both navigation levels
- No regression: ticket-214 test still passes
