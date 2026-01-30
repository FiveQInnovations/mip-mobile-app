---
status: backlog
area: wsp-mobile
phase: core
created: 2026-01-29
---

# Explore Streamlining Prayer Request Page for Mobile

## Context

From FFCI App Build Review meeting (Jan 29, 2026). When users click the Prayer Request button in the app, it opens the browser and shows the website page with narrative text above the form. The narrative text ("fluff") makes sense on the website but adds unnecessary scrolling in the app. Users should be able to go straight to the form.

## Goals

1. Explore options for creating a mobile-optimized Prayer Request page
2. Remove or hide unnecessary narrative text when accessed from the app
3. Keep the form functionality intact
4. Consider if this pattern applies to other pages

## Options to Explore

1. **Separate mobile page:** Create a mobile-optimized version in the Mobile folder (same form, no narrative text)
2. **Conditional display:** Use parameters or CSS to hide narrative text on mobile views
3. **Page duplication:** Create two versions - website version with narrative, app version without

## Acceptance Criteria

- Mobile users can access Prayer Request form without scrolling past unnecessary text
- Form functionality remains intact
- Solution is maintainable and doesn't break website experience
- Pattern can be applied to other similar pages if needed

## Notes

- Current behavior: App button opens browser → shows website page with narrative text → user scrolls to form
- Desired behavior: App button opens browser → shows streamlined page → form is immediately accessible
- Mike K. noted: "That little heading, Submitted Protocols is perfect, but all that that's written there is, that's not necessary on the app"
- Related action item assigned to Mike K.: "Create mobile-optimized Prayer Request page in Mobile folder; link app Prayer Request to it"
- This pattern may apply to other forms/pages accessed from the app

## References

- Meeting: `meetings/ffci-app-build-review-jan-29.md` (00:33:41 - 00:35:42)
- Related to app content management and Mobile folder strategy
