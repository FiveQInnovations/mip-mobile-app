---
status: done
area: wsp-mobile
phase: core
created: 2026-01-26
---

# Mobile API: Replace Form Blocks with Buttons

## Context

The Resources page (and potentially other pages) contains embedded forms (e.g., Prayer Request form). Forms don't work well in mobile app WebViews - they're difficult to interact with, don't submit properly, and create a poor user experience. 

Instead, mobile apps should display a button that opens the form page in the external browser, where users can complete the form with full browser functionality.

## Goals

1. Detect form blocks (`type: form`) in page content when generating mobile API responses
2. Replace form blocks with button blocks that link to the form's web page URL
3. Ensure buttons are styled consistently with other buttons in the mobile app
4. Forms should still appear normally on the web version (no changes to web rendering)

## Acceptance Criteria

- Form blocks in mobile API responses are replaced with button blocks
- Button text is clear and actionable (e.g., "Submit Prayer Request →")
- Button links to the form's web page URL (opens in external browser)
- Web version continues to show forms normally (no regression)
- Works for all form types across the site (Prayer Request, Chaplain Request, etc.)
- Button styling matches existing mobile button styles

## Technical Approach

**Location:** `wsp-mobile` plugin - likely in the content transformation logic

**Implementation:**
1. Detect blocks with `type: "form"` in the content structure
2. Extract the form page UUID/URL from the form block
3. Generate a button block instead:
   ```php
   [
     'type' => 'buttongroup',
     'content' => [
       'buttons' => [
         [
           'type' => 'button',
           'content' => [
             'text' => 'Submit Prayer Request',
             'link_to' => 'page',
             'page' => [form_page_uuid],
             'kind' => '_button-priority'
           ]
         ]
       ]
     ]
   ]
   ```
4. Ensure this transformation only happens in mobile API endpoints, not web rendering

## References

- Resources page UUID: `uezb3178BtP3oGuU`
- Prayer Request form page UUID: `iTQ9ZV8UId5Chxew` (from API response)
- Related: Ticket 220 (Membership Form Button Open Browser) - similar pattern
- wsp-mobile plugin: `/Users/anthony/mip/fiveq-plugins/wsp-mobile/`
- Current form block structure visible in Resources page API response

## Notes

- This is an API-side solution (cleaner than client-side HTML manipulation)
- Affects both iOS and Android apps automatically
- May need to handle different form types/configurations
- Consider adding a "Open in Browser" icon/arrow to the button text for clarity
