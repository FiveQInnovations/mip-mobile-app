---
status: done
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

---

## Research Findings (Scouted)

### Cross-Platform Reference

**Android Implementation:**
- File: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`
- Lines 22-25: `isFormPage()` function checks for form paths
- Currently recognizes: `/prayer-request`, `/chaplain-request`, `/forms/`
- **Does NOT include `/membership` pattern**
- Lines 452-460: When form page detected, opens in external browser via `Intent.ACTION_VIEW`

**Android needs same fix:** Add `/membership` to the form paths list in `isFormPage()` function.

### Current Implementation Analysis

**CMS Configuration (Broken):**
- File: `/Users/anthony/mip/sites/ws-ffci/content/4_get-involved/1_become-a-member/default.txt`
- Line 1 (in JSON): First "Membership Form" button
  - Uses: `"link_to":"scroll"`, `"element_id":"form"`
  - Attempts to scroll to `#form` element on the same page
  - This does NOT open a browser

**Working Reference (Prayer Request):**
- File: `/Users/anthony/mip/sites/ws-ffci/content/connect-with-ffc-copy/default.txt`
- Line 5 (in JSON): "Prayer Request" button configuration
  - Uses: `"link_to":"url"`, `"url":"https://ffci.fiveq.dev/prayer-request"`, `"target":"true"`
  - This correctly opens in external browser

**iOS Implementation:**
- File: `ios-mip-app/FFCI/Views/HtmlContentView.swift`
- Lines 203-208: Form detection logic in `decidePolicyFor` delegate method
  - Checks if URL contains: `/prayer-request`, `/chaplain-request`, `/forms/`
  - **Does NOT include `/membership` pattern**
  - Opens matching URLs with `UIApplication.shared.open(url)`

**Embedded Form (Last resort):**
- Line 5 (last section): Contains iframe embedding ChurchSuite form
  - URL: `https://firefightersforchrist.churchsuite.com/embed/addressbook/form`
  - Section is marked as `"collapse":"true"` (hidden by default)
  - This is the actual form, but embedded in page rather than opening in browser

### Implementation Plan

1. **CMS Content Change** (Primary fix):
   - Edit: `/Users/anthony/mip/sites/ws-ffci/content/4_get-involved/1_become-a-member/default.txt`
   - Find the first button in the JSON (line ~1, search for `"Membership Form"`)
   - Change from:
     ```json
     "link_to":"scroll",
     "element_id":"form",
     "url":""
     ```
   - Change to:
     ```json
     "link_to":"url",
     "element_id":"",
     "url":"https://ffci.fiveq.dev/membership"
     ```
   - This makes the button open the membership URL in browser (matching Prayer Request pattern)

2. **iOS Code Change** (Support mobile browser opening):
   - Edit: `ios-mip-app/FFCI/Views/HtmlContentView.swift`
   - Line 204: Add `/membership` to form detection condition
   - Change from:
     ```swift
     if urlString.contains("/prayer-request") || urlString.contains("/chaplain-request") || urlString.contains("/forms/") {
     ```
   - Change to:
     ```swift
     if urlString.contains("/prayer-request") || urlString.contains("/chaplain-request") || urlString.contains("/forms/") || urlString.contains("/membership") {
     ```

3. **Android Code Change** (Maintain parity):
   - Edit: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`
   - Line 23: Add `/membership` to form paths list
   - Change from:
     ```kotlin
     val formPaths = listOf("/prayer-request", "/chaplain-request", "/forms/")
     ```
   - Change to:
     ```kotlin
     val formPaths = listOf("/prayer-request", "/chaplain-request", "/forms/", "/membership")
     ```

### Code Locations

| File | Purpose | Changes Needed |
|------|---------|----------------|
| `/Users/anthony/mip/sites/ws-ffci/content/4_get-involved/1_become-a-member/default.txt` | CMS page content | Change button from `link_to:"scroll"` to `link_to:"url"` with URL |
| `ios-mip-app/FFCI/Views/HtmlContentView.swift` (line 204) | iOS form detection | Add `\|\| urlString.contains("/membership")` to condition |
| `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt` (line 23) | Android form detection | Add `"/membership"` to formPaths list |

### Form URL Decision

**Recommended URL:** `https://ffci.fiveq.dev/membership`

**Rationale:**
- Matches the pattern used by Prayer Request button (`https://ffci.fiveq.dev/prayer-request`)
- Consistent with site domain
- Server can route `/membership` to the ChurchSuite form or create a custom page
- More maintainable than hardcoding direct ChurchSuite URL

**Alternative:** Use direct ChurchSuite URL (`https://firefightersforchrist.churchsuite.com/embed/addressbook/form`)
- But this is less flexible if form provider changes

### Variables/Data Reference

**Button Configuration Fields (Kirby CMS JSON):**
- `link_to`: Type of link - values: `"scroll"`, `"page"`, `"url"`
- `element_id`: For scroll links - CSS ID to scroll to
- `url`: For URL links - full URL to open
- `target`: Whether to open in new tab/window - `"true"` or `"false"`

**iOS URL Detection:**
- `urlString`: `String` - Full URL from navigation action
- `url`: `URL` - Parsed URL object
- Form paths checked with `.contains()` string matching

**Android URL Detection:**
- `url`: `String` - URL to check
- `formPaths`: `List<String>` - Paths that indicate form pages
- Uses `any { url.contains(it) }` for detection

### Estimated Complexity

**Low** - Simple configuration change + one-line code additions

**Breakdown:**
- CMS edit: 2 minutes (JSON field change in CMS panel or text file)
- iOS code: 1 minute (add one condition to existing if statement)
- Android code: 1 minute (add one string to list)
- Testing: 5 minutes (verify button opens browser on both platforms)

**Total estimated time:** ~10 minutes
