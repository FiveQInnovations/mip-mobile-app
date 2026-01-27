---
status: backlog
area: ios-mip-app
phase: core
created: 2026-01-26
---

# Membership Form Button Should Open Form in Browser

## Context

The Membership Form button on the "Become a member" page currently does nothing when tapped. It should open the membership form in an external browser, similar to how the Prayer Request form works.

**User Flow:**
1. Connect tab → tap button 'Membership Form' → opens internal page 'Become a member'
2. On 'Become a member' page → tap button 'Membership Form' → should open browser but does nothing

## Goals

1. Fix the Membership Form button to open the form URL in an external browser
2. Ensure iOS app recognizes membership form URLs and opens them in browser (similar to Prayer Request)
3. Match the behavior of the Prayer Request form button

## Acceptance Criteria

- Membership Form button on "Become a member" page opens form in external browser
- Form URL opens correctly (likely `https://firefightersforchrist.churchsuite.com/embed/addressbook/form` or similar)
- Browser opens when button is tapped (app goes to background)
- Behavior matches Prayer Request form functionality

## Notes

**Current Implementation Issue:**
- The Membership Form button in `content/4_get-involved/1_become-a-member/default.txt` uses:
  - `"link_to":"scroll"` 
  - `"element_id":"form"`
- This attempts to scroll to an element on the page rather than opening a URL

**Expected Fix:**
1. **CMS Configuration:** Change button to use `link_to: "url"` with the form URL
   - Similar to Prayer Request button which uses: `link_to: "url"` with `url: "https://ffci.fiveq.dev/prayer-request"`

2. **iOS App Code:** Add membership form URL pattern to form detection logic
   - File: `ios-mip-app/FFCI/Views/HtmlContentView.swift` (line 204)
   - Currently checks: `/prayer-request`, `/chaplain-request`, `/forms/`
   - Need to add: `/membership` or the actual membership form URL pattern

**Form URL Options:**
- Direct ChurchSuite URL: `https://firefightersforchrist.churchsuite.com/embed/addressbook/form`
- Or FFCI site URL: `https://ffci.fiveq.dev/membership` (if such a page exists)
- Need to verify the correct URL to use

**Reference Implementation:**
- Prayer Request form handling: [086](086-prayer-request-button-wrong-page.md)
- Prayer Request form opens browser via: `HtmlContentView.swift` line 204-208
- Form paths are checked and opened with `UIApplication.shared.open(url)`

## References

- CMS Content: `/Users/anthony/mip/sites/ws-ffci/content/4_get-involved/1_become-a-member/default.txt`
- iOS Implementation: `ios-mip-app/FFCI/Views/HtmlContentView.swift` (lines 203-208)
- Related: [086](086-prayer-request-button-wrong-page.md) - Prayer Request Form Browser Opening
