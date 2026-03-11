---
status: backlog
area: ios-mip-app
phase: core
created: 2026-03-10
---

# Fix iOS Get Involved Hero Contrast Regression

## Context

The `Get Involved` page (opened from in-app search) currently shows a light hero
background with white heading/body text for the first visible section, making the
content difficult to read. Similar hero contrast issues were addressed on other
pages, but this page still has a noticeable readability problem.

## Goals

1. Ensure hero heading/body text is readable on the `Get Involved` page.
2. Remove the low-contrast white-on-light rendering state for this page.
3. Keep behavior aligned with existing iOS hero contrast fixes used on other pages.

## Acceptance Criteria

- The `Get Involved` page hero text is readable immediately on load.
- No white text appears on a light background in the hero area.
- Existing hero contrast behavior on previously fixed pages is not regressed.
- Search-driven navigation to `Get Involved` still works as expected.

## Notes

- User reported this in simulator after searching for `Get Involved`.
- Visual issue appears in the hero section at the top of the page.
- This ticket is for implementation follow-up only; no fix is included yet.

## References

- Related iOS hero work: `tickets/254-ios-port-android-htmlcontent-fixes.md`
- iOS renderer: `ios-mip-app/FFCI/Views/HtmlContentView.swift`
