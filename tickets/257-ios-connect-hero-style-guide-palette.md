---
status: in-progress
area: ios-mip-app
phase: core
created: 2026-03-14
---

# Align Connect Hero Styling With Style Guide Palette

## Context

Client feedback identified visual inconsistency in the `Connect` flow. After tapping
`Connect`, the `Connect With Us` hero area uses a dark gray banner, a non-palette box
behind it, and a tan/beige blurred photo treatment that does not match the approved
style guide.

## Goals

1. Bring `Connect With Us` hero/banner visuals into the approved style guide palette.
2. Remove the blurred photo treatment from the hero/background presentation.
3. Preserve readability and visual hierarchy while matching brand styling.

## Acceptance Criteria

- The `Connect With Us` banner color uses a style-guide-approved palette value.
- The container/background behind the banner also uses style-guide-approved palette
  values (no off-palette dark gray/tan/beige treatment).
- The hero/background image displays without blur.
- Banner text remains clearly readable after styling updates.
- No visual regressions are introduced on other iOS pages using shared hero styling.

## Notes

- Source request: Mike Bell (Firefighters for Christ International), 2026-03-14.
- Reuse existing app palette tokens or constants where possible to avoid one-off colors.

## References

- Related contrast work: `tickets/255-ios-get-involved-hero-contrast-regression.md`
- Shared renderer likely involved: `ios-mip-app/FFCI/Views/HtmlContentView.swift`

