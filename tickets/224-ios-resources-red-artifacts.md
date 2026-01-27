---
status: backlog
area: ios-mip-app
phase: core
created: 2026-01-26
---

# Red Artifacts on Left Side of Resources Tab Content

## Context

Small red vertical line artifacts are appearing on the left side of content in the Resources tab on iOS. These artifacts are similar to issues that were already fixed on Android. The red lines appear as unintended visual elements that detract from the content presentation.

**Current State:**
- Small, thin vertical red lines visible on the left edge of content sections
- Artifacts appear in multiple locations on the Resources page
- Creates visual clutter and indicates CSS styling issues

## Goals

1. Remove red vertical line artifacts from Resources tab content
2. Ensure clean visual presentation without unintended red styling
3. Apply similar fixes that were successful on Android

## Acceptance Criteria

- No red vertical line artifacts visible in Resources tab content
- Content displays cleanly without unintended red styling
- Visual presentation matches intended design
- Fix aligns with Android solution approach

## Notes

**Related Android Fix:**
- Ticket [208](208-android-bracket-artifacts.md) - Red Bracket Artifacts in Content (Android)
- Android fix involved removing red styling from links that aren't buttons
- File: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`
- Lines 157-179: CSS rules to prevent red artifacts from link styling

**Android Solution Approach:**
The Android fix removed red styling from all links except buttons:
- Removed red background, borders, and padding from non-button links
- Specifically targeted decorative elements that might show red
- Reset inherited styles on buttons to prevent artifacts

**iOS Current Implementation:**
- File: `ios-mip-app/FFCI/Views/HtmlContentView.swift`
- Line 73: Links have red styling: `color: #D9232A; background: rgba(217, 35, 42, 0.08); border-bottom: 2px solid #D9232A;`
- Line 71: h3 headings have intentional red border-left: `border-left: 3px solid #D9232A;` (this is intentional design)

**Investigation Needed:**
1. **Check HTML Structure:** Verify what HTML elements are generating the red artifacts
   - May be unintended link styling
   - May be border-left on wrong elements
   - May be CSS bleeding from button/link styles

2. **Compare with Android:** Review Android CSS fixes and apply similar approach
   - Android removed red styling from non-button links
   - May need similar link style restrictions in iOS

3. **Check Specific Elements:** Identify which elements show red artifacts
   - Could be links styled incorrectly
   - Could be borders appearing where they shouldn't
   - Could be CSS pseudo-elements or decorative elements

**Possible Causes:**
1. **Link Styling Bleeding:** Red link styles (`border-bottom`, `background`) appearing on elements that shouldn't have them
2. **Border Artifacts:** Unintended `border-left` or other borders appearing
3. **CSS Inheritance:** Red styles from buttons/links inheriting to other elements
4. **Decorative Elements:** CSS pseudo-elements or decorative spans showing red

**Recommended Fix Approach:**
Apply similar CSS rules as Android fix:
1. Remove red styling from links that aren't buttons
2. Ensure button styles don't bleed to other elements
3. Reset inherited styles that might cause red artifacts
4. Specifically target any decorative elements showing red

**Implementation:**
Update CSS in `HtmlContentView.swift` to:
- Restrict red link styling to actual text links (not decorative elements)
- Remove red backgrounds/borders from non-button links near buttons
- Ensure button styles are properly scoped
- Add rules to prevent red artifacts similar to Android fix

**Resources Page:**
- Page UUID: `uezb3178BtP3oGuU`
- Contains multiple resource cards with buttons
- Artifacts appear on left side of content sections

## References

- Android Fix: [208](208-android-bracket-artifacts.md) - Red Bracket Artifacts in Content
- Android Implementation: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt` (lines 157-179)
- iOS HTML Renderer: `ios-mip-app/FFCI/Views/HtmlContentView.swift` (lines 67-132)
- Resources Page UUID: `uezb3178BtP3oGuU`
