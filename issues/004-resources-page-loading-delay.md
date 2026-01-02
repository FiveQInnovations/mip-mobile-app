---
status: backlog
area: rn-mip-app
created: 2026-01-02
---

# Resources page loading delay

## Context
When navigating from the Homepage to the Resources tab, there is a noticeable delay before the Resources page content loads. This impacts user experience and makes the app feel less responsive.

**Observed behavior:**
- User taps Resources tab from Homepage
- Tab switches immediately (tab bar updates)
- Resources page content takes several seconds to load/display
- No loading indicator shown during this delay

**Environment:**
- Deployed API: `https://ffci.fiveq.dev`
- iOS Simulator (iPhone 16 Plus)
- App connects directly to deployed API (no local server)

## Tasks
- [ ] Investigate root cause of loading delay
  - [ ] Check API response times for Resources endpoint
  - [ ] Review network requests in app (are requests being made efficiently?)
  - [ ] Check if data is being fetched unnecessarily or multiple times
  - [ ] Verify if there's a caching issue
- [ ] Add loading indicator while Resources page is loading
- [ ] Optimize Resources page loading performance
- [ ] Test and verify improvements

## Notes
- Issue discovered during testing of issue #002
- Resources page does eventually load successfully
- Other pages may have similar issues - should check during investigation

