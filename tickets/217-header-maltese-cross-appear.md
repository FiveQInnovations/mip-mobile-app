---
status: backlog
area: rn-mip-app
phase: core
created: 2026-01-26
---

# Small Maltese Cross Should Appear on Left Side of Header

## Context

A small Maltese cross icon should appear on the left side of the header, but it is currently not visible. This is separate from the main homepage logo and should be a small icon in the persistent header.

## Goals

1. Ensure the small Maltese cross appears on the left side of the header
2. Verify proper positioning and sizing
3. Visual verification only (no testing required)

## Acceptance Criteria

- Small Maltese cross icon is visible on the left side of the header
- Icon is properly sized (small, not dominating the header)
- Icon appears consistently across all screens with the header

## Notes

- **No testing required** - visual check only
- This is separate from the main homepage logo (ticket 216)
- Related to ticket 070 which replaced header logo with Maltese Cross (already completed)
- Check if the icon asset is being loaded correctly
- Verify header component is rendering the icon

## References

- Related: [070](070-header-logo-maltese-cross.md) - Header Logo Replacement (already completed)
- Related: [216](216-homescreen-logo-appear.md) - Main Homepage Logo
