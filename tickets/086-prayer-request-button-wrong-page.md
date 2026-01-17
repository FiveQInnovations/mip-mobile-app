---
status: backlog
area: ws-ffci
phase: core
created: 2026-01-17
---

# Prayer Request Button Links to Wrong Page - No Form or Content Displayed

## Context

On the Connect tab, the "Prayer Request" button navigates to a page that shows "Prayer Request" as the title but displays no form or content. The page appears empty except for the title.

## Problem

**Current Behavior:**
- User taps "Prayer Request" button on Connect tab
- App navigates to a page titled "Prayer Request"
- Page displays no form, no content, no copy - just the title
- User cannot submit a prayer request

**Root Cause:**
The Connect page button is linking to the **form definition UUID** (`iTQ9ZV8UId5Chxew`) instead of the **actual page UUID** (`LP0WESdsu4tWpbGA`) that contains both the content and the form.

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

**Update the Connect page button to link to the correct page UUID:**

**File:** `content/connect-with-ffc-copy/default.txt`

**Change:**
```json
{
  "text": "Prayer Request",
  "link_to": "page",
  "page": ["page://LP0WESdsu4tWpbGA"]  // ✅ Use the PAGE UUID, not the form UUID
}
```

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
- App navigates to page with UUID `LP0WESdsu4tWpbGA`
- Page displays heading, description, and form
- User can submit prayer request

## Related Information

**Form Handling in Mobile App:**
- Forms require JavaScript/Vue.js to render (see ticket [017](017-prayer-request-form-handling.md))
- Forms should open in external browser for full functionality
- However, the page content (heading, description) should still display in the app
- If form doesn't render in-app, user can tap to open in browser

**Page URLs:**
- Prayer Request Page: `https://ffci.fiveq.dev/prayer-request`
- Page UUID: `LP0WESdsu4tWpbGA`
- Form UUID: `iTQ9ZV8UId5Chxew` (referenced within the page, not linked directly)

## Acceptance Criteria

- [ ] Prayer Request button links to page UUID `LP0WESdsu4tWpbGA` (not form UUID)
- [ ] Page displays heading "Submit a Prayer Request"
- [ ] Page displays description text about the prayer ministry
- [ ] Form is visible (or at minimum, page content is visible)
- [ ] User can interact with the page/form
- [ ] Works correctly in mobile app navigation

## Testing

**Test Steps:**
1. Navigate to Connect tab in mobile app
2. Tap "Prayer Request" button
3. Verify page shows heading and description
4. Verify form is visible (or verify page has content)
5. If form doesn't render in-app, verify it opens correctly in browser

## References

- Connect tab ticket: [072](072-connect-tab-navigation.md)
- Prayer Request form handling: [017](017-prayer-request-form-handling.md)
- Prayer Request page: `content/prayer-request/default.txt` (UUID: `LP0WESdsu4tWpbGA`)
- Prayer Request form: `content/forms/2_prayer-request/form.txt` (UUID: `iTQ9ZV8UId5Chxew`)
- Connect page: `content/connect-with-ffc-copy/default.txt`
