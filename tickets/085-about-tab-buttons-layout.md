---
status: backlog
area: rn-mip-app
phase: core
created: 2026-01-17
---

# About Tab Buttons Layout Issue - Side-by-Side Buttons Not Readable

## Context

On the About tab, when two buttons are displayed next to each other (e.g., "Our Mission" and "Join Now"), the text is truncated and unreadable. However, when there is a single button (e.g., "Read Our Story"), it displays nicely, taking up the full width of the row.

## Problem

**Current Behavior:**
- Two buttons side-by-side: Text is truncated, buttons are cramped, text is unreadable
- Single button: Displays full-width, looks good, text is readable

**Example from About page:**
- ❌ "Our Mission" and "Join Now" buttons side-by-side - text truncated and unreadable
- ✅ "Read Our Story" button (single) - full width, looks nice

## Goals

1. Ensure buttons are always readable, regardless of how many are displayed
2. Make buttons full-width when displayed side-by-side (stack them vertically instead)
3. Maintain the nice appearance of single buttons
4. Fix button layout to prevent text truncation

## Current Implementation

**File:** `rn-mip-app/components/HTMLContentRenderer.tsx`

**Button Styles (lines 278-290):**
- Buttons have `minWidth: 200` which causes issues when two are side-by-side
- `_button-group` class exists with `flexDirection: 'column'` to stack buttons vertically
- Buttons have `marginVertical: 8` but no width constraint for full-width display

**Issue:**
- When buttons are NOT wrapped in `_button-group`, they may display side-by-side
- The `minWidth: 200` constraint causes truncation when two buttons share a row
- No automatic detection/wrapping of sibling buttons to ensure vertical stacking

## Solution

### Option 1: Make All Buttons Full-Width (Recommended)
- Remove `minWidth` constraint from button styles
- Add `width: '100%'` or `alignSelf: 'stretch'` to make buttons full-width
- This ensures buttons always take up the full row, preventing side-by-side display

### Option 2: Auto-Detect and Wrap Sibling Buttons
- Detect when multiple buttons are siblings (next to each other in DOM)
- Automatically wrap them in a container that stacks them vertically
- Use `_button-group` styling for sibling buttons

### Option 3: Force Vertical Stacking for All Buttons
- Ensure buttons always stack vertically, never side-by-side
- Override any CSS that might cause horizontal layout
- Use flexbox with `flexDirection: 'column'` for button containers

## Implementation Details

**File to modify:** `rn-mip-app/components/HTMLContentRenderer.tsx`

**Current button style (lines 278-290):**
```typescript
'_button': {
  backgroundColor: primaryColor,
  color: buttonTextColor,
  paddingHorizontal: 20,
  paddingVertical: 14,
  borderRadius: 8,
  fontWeight: '600' as const,
  fontSize: 17,
  textAlign: 'center' as const,
  textDecorationLine: 'none' as const,
  borderBottomWidth: 0,
  marginVertical: 8,
  // minWidth: 200,  // <-- This causes issues
},
```

**Proposed fix:**
- Remove `minWidth: 200`
- Add `width: '100%'` or `alignSelf: 'stretch'`
- Ensure buttons take full width of container
- Add `marginHorizontal: 0` to prevent side-by-side spacing

**For button groups:**
- Ensure `_button-group` properly wraps buttons
- Verify `flexDirection: 'column'` is working correctly
- Add gap/spacing between stacked buttons

## Acceptance Criteria

- [ ] Single buttons display full-width and look good (no regression)
- [ ] Multiple buttons stack vertically, never side-by-side
- [ ] Button text is always readable and not truncated
- [ ] Buttons maintain consistent styling (padding, border radius, colors)
- [ ] Works on both iOS and Android
- [ ] No visual regressions on other pages with buttons

## Testing

**Test Cases:**
1. About tab - "Our Mission" and "Join Now" buttons should stack vertically
2. About tab - "Read Our Story" button should remain full-width
3. Other pages with single buttons should remain unchanged
4. Other pages with multiple buttons should stack vertically

**Screenshots:**
- Before: Side-by-side buttons with truncated text
- After: Vertically stacked buttons with readable text

## References

- Current button implementation: `rn-mip-app/components/HTMLContentRenderer.tsx` lines 135-295
- Related ticket: [078](078-content-page-design-improvements.md) - Content Page Visual Design Improvements
- Screenshots:
  - `assets/085-buttons-side-by-side-issue.png` - Shows the problem with two buttons side-by-side
  - `assets/085-single-button-good.png` - Shows the desired single button appearance
