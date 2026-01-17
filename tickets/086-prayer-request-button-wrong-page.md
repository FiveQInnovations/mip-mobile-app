---
status: in-progress
area: ws-ffci
phase: core
created: 2026-01-17
---

# Prayer Request Button Should Open Form in Browser - Page Shows Text But No Form Link

## Context

On the Connect tab, the "Prayer Request" button navigates to a page that shows "Prayer Request" as the title but displays no form or content. The page appears empty except for the title.

**Update (2026-01-17):** The button was fixed to navigate to `https://ffci.fiveq.dev/resources#prayer-request`. However, this page only displays informational text about the prayer ministry with no link or button to open the actual form. The form needs to open directly in a browser (per ticket [017](017-prayer-request-form-handling.md)).

**Update (2026-01-17):** Changed button to `link_to: "url"` with `https://ffci.fiveq.dev/prayer-request`, but it still opens as an internal page. Testing with `google.com` opens correctly in browser, confirming the URL link functionality works. The issue is that same-domain URLs are being transformed into internal links by the backend (`wsp-mobile/lib/pages.php` lines 115-126), which then get routed internally by the frontend (`HTMLContentRenderer.tsx` lines 43-53).

**Update (2026-01-17):** Backend fix deployed (Option 1 - skip URL transformation for form paths). Fix was committed to `wsp-mobile` and deployed to `ffci.fiveq.dev` via composer update. **However, the fix did not work.** Maestro test created (`maestro/flows/prayer-request-opens-browser-ios.yaml`) confirms the issue: after tapping "Prayer Request", the app's "Home tab" is still visible, meaning the browser did not open.

**Update (2026-01-17):** Investigation confirmed:
1. **CMS config is correct**: Button uses `link_to: "url"` with `url: "https://ffci.fiveq.dev/prayer-request"` and `target: "true"`
2. **Backend fix is working**: API returns correct HTML with URL NOT transformed:
   ```html
   <a class="_button" href="https://ffci.fiveq.dev/prayer-request" target="_blank">Prayer Request</a>
   ```
3. **Root cause is in FRONTEND**: `HTMLContentRenderer.tsx` uses `isInternalLink()` which checks if URL hostname matches `apiBaseUrl` (`ffci.fiveq.dev`). Since both match, the link is treated as internal and routed within the app instead of opening browser.

**Next step:** Implement Option 2 - modify frontend to force browser opening for form URLs even if same domain.

## Problem

**Current Behavior:**
- User taps "Prayer Request" button on Connect tab
- App navigates to `https://ffci.fiveq.dev/resources#prayer-request`
- Page displays heading "Prayer Request" and description text about the ministry
- **No form is visible and no link/button exists to open the form in a browser**
- User cannot submit a prayer request

**Root Cause:**
1. **Initial Issue:** The button navigated to a page (`/resources#prayer-request`) that only contains informational content with no form link.
2. **Current Issue:** When changed to `link_to: "url"` with `https://ffci.fiveq.dev/prayer-request`, the backend API (`wsp-mobile/lib/pages.php`) automatically transforms same-domain URLs into internal `/page/{uuid}` links (lines 115-126). The frontend (`HTMLContentRenderer.tsx`) then detects these as internal links (lines 43-53) and routes them internally instead of opening in browser.

**Technical Details:**
- Backend transforms same-domain URLs: `https://ffci.fiveq.dev/prayer-request` → `/page/LP0WESdsu4tWpbGA`
- Frontend checks if URL hostname matches `apiBaseUrl` (`ffci.fiveq.dev`) and treats as internal
- External URLs (like `google.com`) work correctly because they're not transformed
- Forms require JavaScript/Vue.js to render and should open directly in an external browser (see ticket [017](017-prayer-request-form-handling.md))

## Current Configuration

**Connect Page:** `content/connect-with-ffc-copy/default.txt`

**Current Button Configuration (line 5):**
```json
{
  "text": "Prayer Request",
  "link_to": "page",
  "page": ["page://iTQ9ZV8UId5Chxew"]  // ❌ This is the FORM UUID, not the PAGE UUID
}
```

**Correct Page Structure:**
- **Prayer Request Page:** `content/prayer-request/default.txt`
  - UUID: `LP0WESdsu4tWpbGA` ✅ (This is the correct page to link to)
  - Contains: Heading, description text, and form block
  - Form block references: `page://iTQ9ZV8UId5Chxew` (the form definition)

- **Prayer Request Form Definition:** `content/forms/2_prayer-request/form.txt`
  - UUID: `iTQ9ZV8UId5Chxew` ❌ (This is just the form definition, not a displayable page)
  - Contains: Form field definitions only

## Solution

**Problem:** Same-domain URLs are automatically transformed into internal links by the backend, preventing them from opening in browser.

**Options:**

### Option 1: Modify Backend to Skip Transformation for Form URLs (Recommended)
Modify `wsp-mobile/lib/pages.php` to check if a URL is a form page and skip transformation:

**File:** `/Users/anthony/mip/fiveq-plugins/wsp-mobile/lib/pages.php`

**Change around line 123:**
```php
// Check if it's same domain
$hrefHost = $parsed['host'] ?? '';
$baseHost = parse_url($baseUrl, PHP_URL_HOST);
if ($hrefHost !== $baseHost && $hrefHost !== '') {
    // Different domain - external link, don't transform
    return $matches[0];
}

// Same domain - check if it's a form page that should open in browser
$hrefPath = $parsed['path'] ?? '';
if (str_contains($hrefPath, '/prayer-request') || 
    str_contains($hrefPath, '/chaplain-request') ||
    str_contains($hrefPath, '/forms/')) {
    // Form pages should open in browser, don't transform
    return $matches[0];
}
```

### Option 2: Modify Frontend to Force Browser for Form URLs
Modify `rn-mip-app/components/HTMLContentRenderer.tsx` to check for form URLs and force browser opening:

**File:** `rn-mip-app/components/HTMLContentRenderer.tsx`

**Change around line 104:**
```typescript
// Check if it's an internal link
const isInternal = isInternalLink(href);

// Force browser for form pages even if same domain
const isFormPage = href.includes('/prayer-request') || 
                   href.includes('/chaplain-request') ||
                   href.includes('/forms/');
const shouldOpenInBrowser = !isInternal || isFormPage;

if (!shouldOpenInBrowser) {
    // Internal link handling...
}
```

### Option 3: Use Query Parameter Workaround
Add a query parameter to force external opening (requires both backend and frontend changes).

**Rationale:**
- Forms require JavaScript/Vue.js to render (see ticket [017](017-prayer-request-form-handling.md))
- Forms should open in external browser for full functionality
- Same-domain URL transformation prevents browser opening
- Need to bypass internal link detection for form pages

## Verification

**What the Prayer Request page should contain:**
- Heading: "Submit a Prayer Request"
- Description text explaining the prayer ministry focus
- Form with fields:
  - First Name (required)
  - Last Name (required)
  - USA State (optional)
  - Country (optional)
  - Email Address (required)
  - Your Prayer Request (textarea, required)
  - International prayer team opt-in (select, required)
  - Include name in request (select, required)

**After fix:**
- User taps "Prayer Request" button
- App opens `https://ffci.fiveq.dev/prayer-request` in external browser (Safari/Chrome)
- Browser displays the prayer request form page with heading, description, and form
- User can submit prayer request directly in the browser

## Related Information

**Form Handling in Mobile App:**
- Forms require JavaScript/Vue.js to render (see ticket [017](017-prayer-request-form-handling.md))
- Forms should open in external browser for full functionality
- The Resources page (`/resources#prayer-request`) only shows informational text, not the form
- The form page (`/prayer-request`) contains both the content and the form

**Page URLs:**
- Prayer Request Form Page: `https://ffci.fiveq.dev/prayer-request` ✅ (Use this - opens form directly)
- Resources Page (info only): `https://ffci.fiveq.dev/resources#prayer-request` ❌ (No form link)
- Page UUID: `LP0WESdsu4tWpbGA`
- Form UUID: `iTQ9ZV8UId5Chxew` (referenced within the page, not linked directly)

## Acceptance Criteria

- [ ] Backend or frontend modified to prevent same-domain URL transformation for form pages
- [ ] Prayer Request button uses `link_to: "url"` with `https://ffci.fiveq.dev/prayer-request`
- [ ] Button opens `https://ffci.fiveq.dev/prayer-request` in external browser (not internal page)
- [ ] Browser displays the prayer request form page with heading and description
- [ ] Form is visible and functional in the browser
- [ ] User can submit prayer request directly in browser
- [ ] User can return to app after form submission

## Testing

**Automated Test:**
- Maestro test: `maestro/flows/prayer-request-opens-browser-ios.yaml`
- Run: `maestro test maestro/flows/prayer-request-opens-browser-ios.yaml`
- Test verifies: Navigate to Connect tab → Scroll to Prayer Request → Tap → Assert app goes to background (browser opens)
- **Current status: FAILING** - App's "Home tab" still visible after tap, browser not opening

**Manual Test Steps:**
1. Navigate to Connect tab in mobile app
2. Tap "Prayer Request" button
3. Verify external browser (Safari/Chrome) opens automatically
4. Verify browser navigates to `https://ffci.fiveq.dev/prayer-request`
5. Verify form page displays heading "Submit a Prayer Request" and description text
6. Verify form is visible and functional in browser
7. Verify user can submit a test prayer request
8. Verify user can return to app after submission

## References

- Connect tab ticket: [072](072-connect-tab-navigation.md)
- Prayer Request form handling: [017](017-prayer-request-form-handling.md)
- Prayer Request page: `content/prayer-request/default.txt` (UUID: `LP0WESdsu4tWpbGA`)
- Prayer Request form: `content/forms/2_prayer-request/form.txt` (UUID: `iTQ9ZV8UId5Chxew`)
- Connect page: `content/connect-with-ffc-copy/default.txt`
- Backend URL transformation: `fiveq-plugins/wsp-mobile/lib/pages.php` (lines 115-126)
- Frontend internal link detection: `rn-mip-app/components/HTMLContentRenderer.tsx` (lines 43-53)
