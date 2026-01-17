---
status: done
area: rn-mip-app
phase: core
created: 2026-01-16
updated: 2026-01-17
---

# Add "Connect" Tab - Replace "Get Involved"

## Context

From the Jan 13, 2026 meeting with Mike Bell, the bottom navigation should replace the "Get Involved" tab with a "Connect" tab to centralize key social media and form links. This mirrors a popular feature from their existing Subsplash app.

## Goals

1. Replace "Get Involved" tab with "Connect" tab in bottom navigation
2. Centralize key links in the Connect section
3. Improve user access to social media and forms

## Acceptance Criteria

- "Get Involved" tab is replaced with "Connect" tab
- Connect tab includes links to:
  - Facebook
  - Instagram
  - Website
  - Membership form
  - Prayer request
  - Give
- Navigation functions correctly
- Tab bar displays properly on mobile

## Notes

- This is a high priority change requested by Mike Bell
- Mirrors the Connect feature from their existing app
- May require creating a Connect page on the website first

## References

- Meeting transcript: meetings/ffci-app-build-review-jan-13.md

---

## Scout Findings

### Current Tab Navigation Implementation

**Location:** `rn-mip-app/components/TabNavigator.tsx`

The tab navigation is dynamically built from the Kirby CMS mobile menu API:

- **Lines 18-28:** Icon mapping for all tabs (including both "Get Involved" and "Connect")
- **Line 23:** Get Involved currently uses `hand-left` icons (filled/outline)
- **Line 26:** Connect already has icons defined: `git-network` icons (filled/outline)
- **Lines 111-141:** Menu items are fetched from API and rendered dynamically
- **Lines 158-194:** Tab bar rendering loop that maps over menu items

**Data Flow:**
1. `getSiteData()` API call fetches menu from `/mobile-api` endpoint
2. Backend: `wsp-mobile/lib/menu.php` (lines 12-43) reads `site.mobileMainMenu()` structure field
3. Frontend: Menu items are prepended with a Home tab and rendered in tab bar

**Current Menu Structure (ws-ffci/content/site.txt, lines 111-133):**
```
Mobilemainmenu:
- Resources (uuid: uezb3178BtP3oGuU)
- Chapters (uuid: pik8ysClOFGyllBY)
- About (uuid: xhZj4ejQ65bRhrJg)
- Get Involved (uuid: 3e56Ag4tc8SfnGAv)
```

### Get Involved Tab Current Content

**CMS Location:** `ws-ffci/content/4_get-involved/default.txt`
**UUID:** `3e56Ag4tc8SfnGAv`

The "Get Involved" page currently shows:
- Hero section with title and background image
- Four card sections:
  1. **Become a Member** → Links to member form
  2. **Mission Trips** → Links to mission opportunities
  3. **FFC Events** → Links to events calendar
  4. **Donate** → External link to Aplos donation form (`https://www.aplos.com/aws/give/FirefightersForChristInternational`)
- FFC Chaplain Program section with buttons for:
  - Chaplain Request
  - Become a Volunteer

### Connect Tab Requirements & Existing Resources

**Required Links (from meeting notes, line 50-51):**
1. **Facebook** ✅ Available in `site.social` (site.txt line 50-53)
2. **Instagram** ✅ Available in `site.social` (site.txt line 55-57)
3. **Website** ✅ Can use `firefightersforchrist.org`
4. **Membership form** ✅ Exists at `content/4_get-involved/1_become-a-member/` (has embedded form)
5. **Prayer request** ✅ Exists at `content/forms/2_prayer-request/form.txt` (UUID: iTQ9ZV8UId5Chxew)
6. **Give** ✅ External link exists: `https://www.aplos.com/aws/give/FirefightersForChristInternational`

**Additional Related Forms:**
- **Chaplain Request:** `content/chaplain-request/default.txt` (UUID: M9GmWmqtvlpMuoLP)

### Implementation Plan

#### Phase 1: Create Connect Page in Kirby CMS (Backend)

**Action Required:** Create new page at `ws-ffci/content/5_connect/default.txt`

The Connect page should contain:
- Hero section with title "Connect"
- Link list with these items:
  - Facebook (from site.social)
  - Instagram (from site.social)
  - Website (firefightersforchrist.org)
  - Membership Form (internal page link)
  - Prayer Request (form page)
  - Give (external Aplos link)
  - Optional: Chaplain Request (form page)

**Template:** Use similar structure to "Get Involved" page - a collection of links/buttons rather than full content pages.

#### Phase 2: Update Mobile Menu in Kirby (Backend)

**File:** `ws-ffci/content/site.txt`
**Lines:** 111-133 (Mobilemainmenu structure)

**Change Required:**
Replace:
```
- 
  page:
    - page://3e56Ag4tc8SfnGAv
  label: Get Involved
  icon: [ ]
```

With:
```
- 
  page:
    - page://[NEW_CONNECT_UUID]
  label: Connect
  icon: [ ]
```

#### Phase 3: App Frontend (if needed)

**File:** `rn-mip-app/components/TabNavigator.tsx`

**Good News:** No code changes needed! The icon for "Connect" is already defined (line 26).

**However, Monitor:**
- Tab bar rendering works dynamically from API
- Icon mapping already handles "Connect" label
- "Get Involved" icon mapping can remain (won't hurt anything)

#### Phase 4: Test Link Handling

**File:** `rn-mip-app/components/TabScreen.tsx`

The TabScreen component handles rendering pages. Need to verify:
- Internal page links work (membership form, prayer request)
- External links open in browser (Facebook, Instagram, Give)
- Form pages render correctly

**Note from meeting (line 52-53):** Forms should open in in-app browser for security/cost reasons.

### Code Locations Reference Table

| File | Lines | Purpose | Changes Needed |
|------|-------|---------|----------------|
| `rn-mip-app/components/TabNavigator.tsx` | 18-28 | Tab icon mapping | ✅ None - Connect icon already defined |
| `rn-mip-app/components/TabNavigator.tsx` | 111-141 | Menu data fetching & rendering | ✅ None - fully dynamic |
| `wsp-mobile/lib/menu.php` | 12-43 | Backend menu API | ✅ None - reads from CMS |
| `ws-ffci/content/site.txt` | 111-133 | Mobile menu structure | ✏️ **Replace "Get Involved" with "Connect"** |
| `ws-ffci/content/5_connect/` | N/A | Connect page content | ✏️ **Create new page** |

### Variables & Data Reference

**Social Media Links:**
- Stored in: `site.social` field (site.txt lines 48-62)
- API: Available via `site_data.social` from `/mobile-api`
- Format: Array of `{ platform: string, url: string }`

**Form Page UUIDs:**
- Prayer Request: `iTQ9ZV8UId5Chxew`
- Chaplain Request: `M9GmWmqtvlpMuoLP`
- Membership Form: `2E3lFqnOR6UULQfz` (from become-a-member page button)

**External Links:**
- Facebook: `https://www.facebook.com/groups/www.firefightersforchrist.org`
- Instagram: `https://www.instagram.com/firefighters_for_christ_intl/`
- Website: `https://firefightersforchrist.org`
- Give: `https://www.aplos.com/aws/give/FirefightersForChristInternational`

### Icon Recommendation

**Current Icon:** `git-network` (already configured at TabNavigator.tsx line 26)
- Filled: `git-network`
- Outline: `git-network-outline`

**Assessment:** This is a reasonable icon for "Connect" - it represents interconnected nodes/network. Consider alternatives if design feedback suggests:
- `link` / `link-outline` - More direct "link" representation
- `share-social` / `share-social-outline` - Social connection emphasis
- `people` / `people-outline` - Community/connection emphasis

**Recommendation:** Keep `git-network` unless Mike Bell or Adam Hardy provide different guidance.

### Complexity Assessment

**Level:** Medium

**Breakdown:**
- ✅ **Easy:** App code requires no changes (fully dynamic)
- ✅ **Easy:** Icon already configured
- ⚠️ **Medium:** Create Connect page in Kirby with proper link structure
- ⚠️ **Medium:** Update mobile menu structure in Kirby
- ⚠️ **Medium:** Test all link types (internal pages, external URLs, forms)
- ⚠️ **Medium:** Ensure form pages render correctly in mobile app

**Estimated Effort:** 
- Kirby CMS work: 1-2 hours (create page, update menu, test)
- App testing: 0.5-1 hour (verify links work, forms render)
- **Total: 2-3 hours**

**Dependencies:**
- Requires Kirby CMS access to create Connect page
- Requires decision on exact link order/presentation
- May need coordination with Adam Hardy on page design/layout

**Risk Factors:**
- Low risk overall - mostly configuration changes
- Main risk: Ensuring forms render properly in mobile app (in-app browser behavior)
- Minor risk: Icon choice might need adjustment based on design feedback

### Additional Notes

1. **"Get Involved" Content Migration:** The existing Get Involved page has valuable content (mission trips, events, chaplain program). Consider where this content should live after the Connect tab replaces it. Options:
   - Keep as a standalone page accessible via other navigation
   - Distribute content to other relevant sections
   - Include some elements in Connect page

2. **Connect Page Design:** The meeting notes (line 50-51) indicate this mirrors a feature from their existing Subsplash app. May want to review that app for UX patterns.

3. **Form Handling:** Per meeting notes (line 52-53), forms should open in in-app browser. Verify current implementation in TabScreen/HTMLContentRenderer handles this correctly.

4. **Homepage Quick Tasks:** The homepage already has Facebook/Instagram links in the quick tasks (site.txt lines 172-189). Coordinate with homepage redesign work to avoid duplication.

---

## Status Update - 2026-01-17

### Connect Page Verification

**Finding:** A "Connect With FFC" page already exists on the dev server at:
- URL: `https://ffci.fiveq.dev/connect-with-ffc`
- Screenshot: `assets/Screenshot_2026-01-17_at_11.39.44_AM-ed0985fc-036e-4857-bf0d-b74c7a1ad6ca.png`

### Link Verification Against Acceptance Criteria

Verified via `curl -u fiveq:demo "https://ffci.fiveq.dev/connect-with-ffc"`:

| Required Link | Present | Destination URL |
|--------------|---------|-----------------|
| Facebook | ✅ Yes | `https://www.facebook.com/groups/www.firefightersforchrist.org` |
| Instagram | ✅ Yes | `https://www.instagram.com/firefighters_for_christ_intl/` |
| Website | ✅ Yes | `https://firefightersforchrist.org` |
| Membership Form | ✅ Yes | `/get-involved/become-a-member` (internal) |
| Prayer Request | ✅ Yes | `/forms/prayer-request` (form page) |
| Give | ✅ Yes | `https://app.aplos.com/aws/give/FirefightersForChristInternational` |
| Chaplain Request | ✅ Yes | `/chaplain-request` (internal, bonus) |

**Page HTML Structure:**
```html
<div class="_button-group">
  <a class="_button" href="...">Facebook</a>
  <a class="_button" href="...">Instagram</a>
  <a class="_button" href="...">Website</a>
  <a class="_button" href="...">Membership Form</a>
  <a class="_button" href="...">Prayer Request</a>
  <a class="_button" href="...">Give</a>
  <a class="_button" href="...">Chaplain Request</a>
</div>
```

**Assessment: The existing page IS sufficient for the Connect tab.**

### Backend Work Status - ✅ COMPLETE

**Verified via `git pull` on 2026-01-17:**

1. **Connect Page Created** ✅
   - File: `ws-ffci/content/connect-with-ffc/default.txt`
   - UUID: `MMd2trinapbVIQVD`
   - Contains all 7 required links (Facebook, Instagram, Website, Membership Form, Prayer Request, Give, Chaplain Request)

2. **Mobile Menu Updated** ✅
   - File: `ws-ffci/content/site.txt` lines 113-116
   - "Get Involved" replaced with "Connect"
   - References correct UUID: `page://MMd2trinapbVIQVD`

**Git Commit:** `8d19c3c9` (pulled from `origin/master`)

### Remaining Work

**Frontend Testing Required:**

1. **Test in Mobile App Simulator**
   - Verify "Connect" tab appears in bottom navigation
   - Verify tab icon renders correctly (`git-network` icon already configured)
   - Verify tab label displays as "Connect"

2. **Test Link Functionality**
   - Verify all link types work:
     - External URLs (Facebook, Instagram, Website, Give) open in browser
     - Internal pages (Membership Form, Prayer Request, Chaplain Request) navigate correctly
   - Verify forms open in in-app browser per meeting notes (line 52-53)

3. **Verify Page Rendering**
   - Connect page content displays correctly
   - Button group renders properly
   - All 7 buttons are visible and clickable

### Next Steps

1. ✅ Backend complete - Connect page created and mobile menu updated
2. **Test in mobile app simulator** - Verify tab appears and functions correctly
3. **Test all links** - Ensure external/internal links work as expected
4. **Move ticket to QA** once testing confirms everything works