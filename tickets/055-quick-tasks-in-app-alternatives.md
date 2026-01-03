---
status: backlog
area: rn-mip-app
phase: nice-to-have
created: 2026-01-19
---

# Quick Tasks In-App Alternatives

## Context

Currently, 3 out of 4 Quick Tasks on the home screen open content in an external browser:
- **Prayer Request** - Opens `https://ffci.fiveq.dev/prayer-request` in Safari/Chrome
- **Chaplain Request** - Opens `https://ffci.fiveq.dev/chaplain-request` in Safari/Chrome  
- **Donate** - Opens `https://www.firefightersforchrist.org/donate` in Safari/Chrome
- **Resources** - Only one that navigates in-app ✅

**Note**: For v1, we want to keep the browser-based approach for forms and donations (they work well and don't require additional complexity). Instead, we should explore **alternative Quick Tasks** that are better suited for in-app navigation.

## Problem

Having 3 out of 4 Quick Tasks open external browsers creates a fragmented experience, but we don't want to extend scope by building WebViews for forms/payments. Instead, we should identify other content/actions that work well as Quick Tasks and keep users engaged in-app.

## Goals

1. **Research available content** from the site menu and API
2. **Identify candidate Quick Tasks** that:
   - Navigate in-app (have page UUIDs)
   - Are frequently accessed or high-value actions
   - Work well as quick actions (not just content pages)
3. **Recommend replacements** for some/all browser-based Quick Tasks
4. **Implement** the new Quick Tasks

## Research Areas

### Available Menu Items
- Review `siteData.menu` to see what pages are available
- Check which menu items have page UUIDs (can navigate in-app)
- Identify high-value pages that users might want quick access to

### Current Quick Tasks Analysis
- **Prayer Request** - Form (keep browser-based for v1)
- **Chaplain Request** - Form (keep browser-based for v1)
- **Donate** - Payment processing (keep browser-based for v1)
- **Resources** - Already in-app ✅ (good example)

### Potential Alternatives
- **Chapters** - Find a Chapter (already in "Get Connected" section)
- **Events** - Upcoming Events (already in "Get Connected" section)
- Other frequently accessed content pages
- Collection pages that work well as quick actions

## Tasks

### Research (Completed 2026-01-19)
- [x] Review site menu structure and available pages
- [x] Identify pages with UUIDs that can navigate in-app
- [x] Research what content types work well as Quick Tasks
- [x] Document candidate Quick Tasks with pros/cons
- [x] Recommend new Quick Task configuration

### Implementation (Pending)
- [ ] Update `HomeScreen.tsx` with new Quick Tasks
- [ ] Test navigation works correctly for new tasks
- [ ] Update Maestro tests if Quick Tasks change
- [ ] Consider keeping some browser-based tasks vs replacing all

## Related

- **Ticket 017** (done): Prayer Request form handling - browser-based approach (keeping for v1)
- **Ticket 018** (done): Chaplain Request form handling - browser-based approach (keeping for v1)
- `rn-mip-app/components/HomeScreen.tsx` - Quick Tasks implementation
- `rn-mip-app/lib/api.ts` - SiteData and MenuItem interfaces

## Notes

- Current Quick Tasks are hardcoded in `HomeScreen.tsx` (lines 53-87)
- "Get Connected" section already has Chapters and Events that navigate in-app
- Could potentially promote some "Get Connected" items to Quick Tasks
- Consider user behavior: what actions do users take most frequently?
- Balance between action-oriented tasks (forms, donations) vs content navigation

---

## Research Findings (2026-01-19)

### Available Menu Items (from `site.txt`)

The mobile menu is configured in `content/site.txt` under `Mobilemainmenu:`:

1. **Resources** (UUID: `uezb3178BtP3oGuU`)
   - Already a Quick Task ✅
   - Navigates in-app
   - Contains links to FFC Media, Bible Gateway, Store, Chaplain Resources

2. **Chapters** (UUID: `pik8ysClOFGyllBY`)
   - Currently in "Get Connected" section
   - Navigates in-app
   - Landing page with "Find a Chapter", "Start a Chapter", "Chapter Resources"
   - High-value action for connecting users

3. **About** (UUID: `xhZj4ejQ65bRhrJg`)
   - In main menu tabs
   - Content page (likely about FFCI organization)
   - Less action-oriented

4. **Get Involved** (UUID: `3e56Ag4tc8SfnGAv`)
   - In main menu tabs
   - Contains outreach opportunities, training trips, emergency relief
   - Action-oriented but broader scope

### Other Available Pages

5. **Events** (UUID: `6ffa8qmIpJHM0C3r`)
   - Currently in "Get Connected" section
   - Navigates in-app
   - Calendar/events listing page
   - High-value for engagement

6. **FFC Store** (UUID: `lLzSDKBGJdNxpeGU`)
   - Referenced in Resources page
   - Not in main menu
   - Could be Quick Task for shopping/merchandise

7. **Prayer Request** (UUID: `LP0WESdsu4tWpbGA`)
   - Form page (requires browser for v1)
   - Currently a Quick Task (browser-based)

8. **Chaplain Request** (UUID: `M9GmWmqtvlpMuoLP`)
   - Form page (requires browser for v1)
   - Currently a Quick Task (browser-based)

### Current Quick Tasks Analysis

| Task | Type | Navigation | Status |
|------|------|------------|--------|
| Prayer Request | Form | Browser | Keep for v1 |
| Chaplain Request | Form | Browser | Keep for v1 |
| Resources | Content | In-app ✅ | Keep |
| Donate | Payment | Browser | Keep for v1 |

**Current ratio**: 1 in-app, 3 browser-based

### Current "Get Connected" Section

| Item | UUID | Navigation | Potential for Quick Task |
|------|------|------------|-------------------------|
| Chapters | `pik8ysClOFGyllBY` | In-app ✅ | **High** - Core action |
| Events | `6ffa8qmIpJHM0C3r` | In-app ✅ | **Medium** - Engagement |

### Recommended Quick Task Alternatives

#### Option 1: Replace 2 browser tasks with in-app content
**Replace**: Prayer Request + Chaplain Request  
**With**: Chapters + Events  
**Result**: 3 in-app, 1 browser (Donate)

**Pros**:
- Better in-app experience (75% in-app vs 25%)
- Chapters is a core action users take frequently
- Events drives engagement
- Both already work perfectly in-app

**Cons**:
- Loses quick access to forms (but forms still accessible via menu)
- Less action-oriented (content navigation vs form submission)

#### Option 2: Replace 1 browser task, keep 1 form
**Replace**: Chaplain Request  
**With**: Chapters  
**Keep**: Prayer Request (browser)  
**Result**: 2 in-app, 2 browser

**Pros**:
- Balanced mix (50/50)
- Keeps one form easily accessible
- Chapters is high-value action

**Cons**:
- Still 50% browser-based
- Asymmetric (why keep Prayer but not Chaplain?)

#### Option 3: Replace Donate with Store
**Replace**: Donate (external payment)  
**With**: FFC Store (in-app page)  
**Result**: 2 in-app, 2 browser (forms)

**Pros**:
- Store is shopping/merchandise (action-oriented)
- Navigates in-app
- Different type of action (shopping vs donation)

**Cons**:
- Store might not be as high-value as donation
- Store page might link out anyway (needs verification)

#### Option 4: Hybrid - Replace 1 form + Donate
**Replace**: Chaplain Request + Donate  
**With**: Chapters + Events  
**Result**: 3 in-app, 1 browser (Prayer Request)

**Pros**:
- Best in-app ratio (75%)
- Keeps most important form (Prayer Request)
- Adds high-value content navigation

**Cons**:
- Loses quick access to Chaplain Request form
- Loses quick access to Donate

### Recommendation: **Option 1** (Chapters + Events)

**Rationale**:
1. **Chapters** is a core action - users frequently need to find/connect with chapters
2. **Events** drives engagement - users want to see upcoming events
3. Both already work perfectly in-app (no WebView needed)
4. Forms remain accessible via main menu tabs or "Get Connected" section
5. Maximizes in-app experience (75% in-app vs 25%)

**Implementation**:
- Replace Prayer Request and Chaplain Request Quick Tasks
- Add Chapters and Events as Quick Tasks
- Keep Resources and Donate
- Forms remain accessible via menu navigation

**New Quick Tasks**:
1. **Chapters** - Find/connect with local chapters (in-app)
2. **Events** - View upcoming events (in-app)
3. **Resources** - Browse PDFs and links (in-app) ✅
4. **Donate** - Opens donation page (browser)

### Additional Considerations

- **FFC Store**: Could be considered but needs verification that it navigates fully in-app (might link out to external store)
- **Get Involved**: Too broad for Quick Task (better as main menu item)
- **About**: Content page, not action-oriented enough
- **Forms**: Keep accessible via menu but don't need Quick Task slots (forms work better in browser for v1)

### Menu Structure Reference

The menu API (`wsp-mobile/lib/menu.php`) reads from `site->mobileMainMenu()` which is a structure field in the site blueprint (`wsp-mobile/blueprints/tabs/mobile.yml`). Each menu item has:
- `label`: Display name
- `page`: Page reference with UUID
- `icon`: Optional icon file

The mobile app uses `handleNavigate()` to find menu items by label and navigate to their UUIDs.
