---
status: in-progress
area: rn-mip-app
phase: core
created: 2026-01-23
---

# Resources Tab Active State Styling Inconsistent

## Context

During visual testing of ticket 084, it was discovered that the Resources tab uses a different active state indicator than other tabs. While Home and Chapters tabs show filled icons when active, the Resources tab shows an outline icon with an underline instead.

This creates visual inconsistency in the tab bar.

## Current Behavior

| Tab | Active State |
|-----|--------------|
| Home | ✅ Filled icon (red) |
| Resources | ❌ Outline icon + underline |
| Chapters | ✅ Filled icon (red) |
| Connect | Unable to verify (routing issue - see ticket 090) |

## Goals

1. Make Resources tab show filled icon when active (consistent with other tabs)
2. Remove the underline indicator if it's specific to Resources tab
3. Ensure all tabs have consistent active state styling

## Acceptance Criteria

- [ ] Resources tab shows filled icon when active (not outline)
- [ ] Resources tab uses same color (red/accent) as other active tabs
- [ ] No underline or extra indicator on Resources tab
- [ ] All four tabs have identical active state behavior

## Technical Notes

Investigate why Resources tab behaves differently:
- Is it using a different component?
- Is there special styling applied?
- Is the tab definition different in some way?

## References

- Discovered during: [084](084-icon-management-website.md) - Icon Management in Website
- Related: [058](done/058-tab-icons.md) - Add Icons to Each Tab
- Tab implementation: `rn-mip-app/components/TabNavigator.tsx`

---

## Research Findings (Scouted)

### Current Implementation Analysis

**Tab Icon System Architecture:**

The app uses a three-tier fallback system for tab icons (lines 37-84 in `TabNavigator.tsx`):

1. **API-provided icons** (highest priority) - from `item.icon` field
2. **TAB_ICONS hardcoded mapping** (fallback) - local constant
3. **DEFAULT_ICON** (last resort) - generic ellipse

**CMS Configuration** (`/Users/anthony/mip/sites/ws-ffci/content/site.txt` lines 116-132):
All three menu tabs have empty icon fields:
```yaml
Mobilemainmenu:
- page: [page://uezb3178BtP3oGuU]
  label: Resources
  icon: [ ]  # Empty - should trigger fallback
- page: [page://pik8ysClOFGyllBY]
  label: Chapters
  icon: [ ]  # Empty - should trigger fallback
- page: [page://qNkTQQFxM96ThPKK]
  label: Connect
  icon: [ ]  # Empty - should trigger fallback
```

**API Response** (`/Users/anthony/mip/fiveq-plugins/wsp-mobile/lib/menu.php` line 30):
```php
"icon" => $item->icon()->value() ?: null
```
Empty arrays become `null`, so all tabs should fall back to TAB_ICONS mapping.

**TAB_ICONS Mapping** (`TabNavigator.tsx` lines 18-28):
```typescript
'Home': { filled: 'star', outline: 'star-outline' },
'Resources': { filled: 'book', outline: 'book-outline' },
'Chapters': { filled: 'people', outline: 'people-outline' },
'Connect': { filled: 'git-network', outline: 'git-network-outline' },
```

**Icon Rendering** (line 240):
```typescript
name={iconConfig[isSelected ? 'filled' : 'outline']}
```
When tab is active (`isSelected=true`), uses `filled` variant.

### Root Cause Hypothesis

**Primary Suspect: Ionicons `book` Icon Visual Design**

The Ionicons `book` icon may not have a visually distinct "filled" appearance compared to its "outline" variant. Some Ionicons have minimal visual difference between their base and outline versions, making them appear identical or nearly identical.

**Evidence:**
- Home tab uses `star`/`star-outline` - works correctly ✅
- Chapters tab uses `people`/`people-outline` - works correctly ✅  
- Resources tab uses `book`/`book-outline` - appears as outline when active ❌

The code logic is identical for all tabs, so the issue is likely with the specific icon choice rather than a code bug.

**Regarding the "underline":**
No underline styling exists in the code. This may be:
- Visual misinterpretation (selected tab has `backgroundColor: '#f5f5f5'`)
- Rendering artifact in simulator
- Stale UI from hot reload

### Implementation Plan

**Step 1: Verify Icon Appearance**
Test render `book` vs `book-outline` side-by-side to confirm visual difference.

**Step 2: Choose Better Icon**
Replace `book` with an icon that has a clear filled/outline distinction:

**Option A - Use `bookmarks` icon:**
```typescript
'Resources': { filled: 'bookmarks', outline: 'bookmarks-outline' },
```

**Option B - Use `library` icon:**
```typescript
'Resources': { filled: 'library', outline: 'library-outline' },
```

**Option C - Add debug logging first:**
```typescript
console.log(`[TabNavigator] Resources icon config:`, iconConfig);
console.log(`[TabNavigator] IsSelected: ${isSelected}, Icon: ${iconConfig[isSelected ? 'filled' : 'outline']}`);
```

### Code Locations

| File | Line(s) | Purpose | Change Required? |
|------|---------|---------|------------------|
| `rn-mip-app/components/TabNavigator.tsx` | 18-28 | TAB_ICONS constant | ✅ YES - Update Resources icon |
| `rn-mip-app/components/TabNavigator.tsx` | 37-84 | `getIconForMenuItem()` function | ❌ NO - Logic is correct |
| `rn-mip-app/components/TabNavigator.tsx` | 221-255 | Tab rendering loop | ❌ NO - Logic is correct |
| `rn-mip-app/lib/api.ts` | 13-17 | MenuItem interface | ❌ NO - Structure is correct |
| `wsp-mobile/lib/menu.php` | 30 | API icon field | ❌ NO - Returns null correctly |
| `ws-ffci/content/site.txt` | 116-132 | Mobile menu config | ❌ NO - Empty icons are intentional |

### Variables/Data Reference

- `TAB_ICONS`: Hardcoded icon mapping (line 18)
- `iconConfig`: Result of `getIconForMenuItem()` (line 224)
- `isSelected`: Boolean for active tab state (line 222)
- `item.label.trim()`: Used for TAB_ICONS lookup (line 77)

### Estimated Complexity

**LOW** - Single line change in TAB_ICONS constant.

**Recommended Fix:**
Change line 20 from:
```typescript
'Resources': { filled: 'book', outline: 'book-outline' },
```
To:
```typescript
'Resources': { filled: 'bookmarks', outline: 'bookmarks-outline' },
```

**Testing:**
1. Hot reload the app
2. Navigate to Resources tab
3. Verify filled icon appears (visually distinct from outline)
4. Compare with Home and Chapters tabs for consistency

**Alternative if `bookmarks` doesn't look good:**
Try `library`, `albums`, `folder`, or `filing` icons - all have clear filled/outline variants in Ionicons.
