---
status: done
area: android-mip-app
phase: core
created: 2026-01-26
---

# Android Resources Page Excessive Spacing

## Context

On the Android app's Resources page, there is excessive vertical spacing between the "More Resources" heading (with tagline "Gear, materials, and specialized tools to serve your community.") and the "FFC Online Store" subheading. This spacing is noticeably larger than the corresponding spacing in the web browser version, creating an inconsistent user experience.

## Symptoms

- Large empty vertical space (whitespace) between the "More Resources" section tagline and the "FFC Online Store" subheading
- Spacing appears much larger than the web version of the same page
- Creates visual inconsistency and poor use of screen space on mobile

## Goals

1. Reduce excessive spacing between "More Resources" section and "FFC Online Store" subheading
2. Match spacing to be consistent with web version or appropriate for mobile layout
3. Improve visual hierarchy and content density on Resources page

## Acceptance Criteria

- Spacing between "More Resources" tagline and "FFC Online Store" subheading is visually appropriate
- Spacing is consistent with other sections on the Resources page
- Layout matches or improves upon web version spacing
- No excessive whitespace that detracts from content visibility

## Technical Investigation Needed

1. **Check HTML/CSS rendering** - Is there extra margin/padding in the HTML content?
2. **Check WebView CSS** - Are there CSS rules adding excessive spacing?
3. **Check content structure** - Is there empty content blocks or elements creating the gap?
4. **Compare with web version** - What spacing does the web version use?

## References

- Resources page UUID: `uezb3178BtP3oGuU`
- Android renderer: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`
- Related: ticket 207 (Android Resources Missing Buttons) - may have similar HTML/CSS issues
- Screenshot comparison showing spacing difference between web and Android app
