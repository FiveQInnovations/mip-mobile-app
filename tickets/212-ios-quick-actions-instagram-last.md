---
status: qa
area: ios-mip-app
phase: core
created: 2026-01-24
---

## Implementation Complete (TDD Verified)

**Fix applied:** Changed ForEach identity from `\.element.uuid` to `\.offset` in `ResourcesScrollView.swift`

**Maestro test:** `ios-mip-app/maestro/flows/ticket-212-instagram-last-ios.yaml`
- Test result: **PASSED**
- Verified: Instagram card appears last when scrolling right in Resources section

**Root cause:** Facebook and Instagram shared the same UUID (`gnf1dvBkM4SJWQdA`) because they point to the same Kirby page. SwiftUI's ForEach was using UUID as identity, treating them as the same element.

---


# iOS Quick Actions Should Show Instagram Last, Not Facebook

## Context

The Quick Actions (Resources) section on the home screen should display Instagram as the last item, but currently shows Facebook instead. The user has verified in the Kirby panel that both Facebook and Instagram exist, and both point to the same Kirby page (Privacy Policy).

## Problem

The Quick Actions list is not displaying Instagram as the last item. Facebook appears last instead of Instagram.

## Goals

1. Ensure Instagram appears as the last Quick Action card
2. Verify the order matches what's configured in Kirby panel
3. Fix any data ordering issues from the API

## Acceptance Criteria

- Instagram Quick Action card appears last in the horizontal scroll
- Facebook appears before Instagram (not last)
- Order matches Kirby panel configuration
- All Quick Actions are still visible and functional

## Related Files

- `ios-mip-app/FFCI/Views/ResourcesScrollView.swift`
- `ios-mip-app/FFCI/Views/HomeView.swift`
- API endpoint that provides `homepageQuickTasks` data

## Notes

- User verified in Kirby panel that both Facebook and Instagram exist
- Both currently point to the same Kirby page (Privacy Policy)
- May be an API ordering issue or data mapping problem
- After fixing, verify horizontal scrolling works correctly (see ticket 213)

## Research Findings (Scouted)

### Root Cause Identified: Duplicate UUID Issue

**The API order is CORRECT** - Instagram is last in the API response:
1. About Us
2. What We Believe
3. Peace With God
4. Facebook (uuid: `gnf1dvBkM4SJWQdA`)
5. Instagram (uuid: `gnf1dvBkM4SJWQdA`) - LAST

**Bug Location**: `ios-mip-app/FFCI/Views/ResourcesScrollView.swift` line 39

```swift
ForEach(Array(quickTasks.enumerated()), id: \.element.uuid) { index, task in
```

**Problem**: SwiftUI uses `uuid` as the identity for ForEach. Since Facebook and Instagram have the SAME UUID (both point to the same Kirby page), SwiftUI treats them as the same element, causing unpredictable display behavior.

### Fix Required

Change the ForEach identity to use a unique identifier. Options:
1. Use index directly: `id: \.offset`
2. Use combination: Create a computed ID from index + uuid
3. Make HomepageQuickTask identifiable by a synthesized unique ID

### Verification

After fix, the Resources section should show cards in this order:
1. About Us
2. What We Believe  
3. Peace With God
4. Facebook
5. Instagram (LAST - scroll right to verify)

---

## Research Findings (Scouted)

### Root Cause Analysis

**Verdict: This is a Kirby CMS data ordering issue, NOT a code issue.**

The ordering of Quick Actions is determined entirely by the Kirby CMS panel. Both the API and iOS app preserve the order exactly as stored in Kirby—no sorting or manipulation occurs in code.

### Current Implementation Analysis

#### Content Storage
Location: `/Users/anthony/mip/sites/ws-ffci/content/site.txt`, lines 140-188

Current order in the content file (as of 2026-01-24):
1. About Us (lines 142-151)
2. FFC Info (lines 152-159)
3. Peace With God (lines 160-170)
4. **Facebook** (lines 171-179) ← 4th item
5. **Instagram** (lines 180-188) ← **5th item (LAST)**

**Important:** The content file shows Instagram is ALREADY the last item. This was last modified today at 14:47 local time.

#### Data Flow (API → iOS)

**API Side** (`wsp-mobile/lib/site.php`):
```php
// Line 22-50: get_homepage_quick_tasks()
$tasks = $site->mobileHomepageQuickTasks();  // Line 23
return $tasks->toStructure()->map(function ($item) {
    // ... mapping logic ...
})->data();  // Line 49 - returns array in Kirby structure order
```

**No sorting applied** - the API returns items in the exact order they appear in the Kirby structure field.

**iOS App** (`ios-mip-app/FFCI/Views/ResourcesScrollView.swift`):
```swift
// Line 39: Display in order received
ForEach(Array(quickTasks.enumerated()), id: \.element.uuid) { index, task in
    // ... render card ...
}
```

**No sorting applied** - the iOS app displays items in the exact order received from the API.

### Implementation Plan

Since the content file already shows the correct order (Instagram last), the issue is likely one of these:

1. **Kirby Panel vs File Mismatch**: The Kirby panel might show a different order than what's in the file. The user needs to check the actual panel order.

2. **Cache Issue**: The iOS app or API might be serving cached data with the old order.

3. **Recent Change**: The user may have just reordered items in Kirby today, and the app needs to be refreshed.

**Resolution Steps:**

1. **First, verify Kirby panel order:**
   - Log into Kirby panel at `https://firefightersforchrist.org/panel`
   - Navigate to Site settings → Mobile Settings tab
   - Check the "Homepage Quick Tasks" section
   - Verify Instagram comes AFTER Facebook in the list
   - If not, drag Instagram to the last position and save

2. **Clear API/app cache:**
   - Force quit the iOS app completely
   - Relaunch and pull to refresh on home screen
   - Or clear app data/reinstall if needed

3. **Verify fix:**
   - Scroll through Resources section
   - Confirm order: ...Peace With God → Facebook → Instagram (last)

### Code Locations

| File | Purpose | Changes Needed |
|------|---------|----------------|
| `/Users/anthony/mip/sites/ws-ffci/content/site.txt` | Kirby content storage | Already correct (Instagram at line 180-188, last) |
| `/Users/anthony/mip/fiveq-plugins/wsp-mobile/lib/site.php` | API data generation | **No changes needed** - preserves Kirby order |
| `/Users/anthony/mip/fiveq-plugins/wsp-mobile/blueprints/tabs/mobile.yml` | Kirby field definition | **No changes needed** - `sortable: true` allows manual ordering |
| `/Users/anthony/mip-mobile-app/ios-mip-app/FFCI/Views/ResourcesScrollView.swift` | iOS display component | **No changes needed** - displays in API order |
| `/Users/anthony/mip-mobile-app/ios-mip-app/FFCI/API/ApiModels.swift` | Data models | **No changes needed** - array preserves order |

### Data Structure Reference

**Kirby Structure Field** (`mobileHomepageQuickTasks`):
- Type: `structure` with `sortable: true`
- Defined in: `wsp-mobile/blueprints/tabs/mobile.yml` (line 43-70)
- Allows manual drag-and-drop ordering in Kirby panel

**API Response** (`homepage_quick_tasks`):
- Returns array of objects with: `uuid`, `label`, `description`, `image_url`, `external_url`
- Order matches Kirby structure field order

**iOS Model** (`HomepageQuickTask`):
- Defined in: `ios-mip-app/FFCI/API/ApiModels.swift` (line 26-40)
- Array type preserves ordering

### Estimated Complexity

**Low** - This is a content management issue, not a code issue.

- **IF** the Kirby panel order is wrong: User needs to reorder in panel (2 minutes)
- **IF** it's a cache issue: Force refresh app (30 seconds)
- **IF** content file needs manual edit: Edit lines 171-188 to swap Facebook/Instagram (5 minutes)

No code deployment required—this is purely a data/content fix.
