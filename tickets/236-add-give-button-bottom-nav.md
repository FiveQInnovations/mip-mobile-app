---
status: qa
area: general
phase: core
created: 2026-01-29
---

# Keep Media Tab and Add Give Tab

## Context

Update: keep the existing Media tab in bottom navigation and add Give as an additional tab. The previous direction to remove Media is no longer in scope.

## Goals

1. Keep Media in bottom navigation
2. Add Give button to bottom navigation
3. Ensure tab ordering and labels stay clear and usable with the additional tab

Current donate menu item is an external link to: https://app.aplos.com/aws/give/FirefightersForChristInternational

## Acceptance Criteria

- Media tab remains in bottom navigation
- Give tab appears in bottom navigation
- Both Media and Give routes open expected destinations
- Navigation feels balanced and intuitive with the extra tab

## Notes

- Current tabs: Home, Resources, Media, Connect
- Target tabs include both Media and Give
- Five tabs may feel cramped; needs testing with short labels
- Part of navigation redesign
- Implemented:
  - Added `external_url` support for mobile main menu tabs in `wsp-mobile`
  - Added Give tab entry in `ws-ffci` mobile menu config (`content/site.txt`)
  - Updated Android bottom-tab handling to open external tab URLs in browser
- Deployed:
  - `wsp-mobile` API changes deployed from canonical repo
  - `ws-ffci` content update deployed with Give tab in mobile menu
- Verification:
  - Live `mobile-api/menu` includes `Resources`, `Media`, `Connect`, and `Give`
  - Live `Give` menu item returns external URL to Aplos donate page
  - Android debug build installs/launches successfully
  - Tapping `Give` opens Chrome with intent URL `https://app.aplos.com/aws/give/FirefightersForChristInternational`

## References

- Meeting: `meetings/ffci-app-build-review-jan-29.md` (00:38:28)
