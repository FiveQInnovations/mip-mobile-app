---
status: done
area: wsp-mobile
phase: core
created: 2026-01-17
---

# Icon Management in Website (No Upload Required)

## Context

Currently, tab icons are hardcoded in the mobile app (`rn-mip-app/components/TabNavigator.tsx` lines 18-28). The Kirby CMS blueprint already has an `icon` field in the mobile menu structure (`wsp-mobile/blueprints/tabs/mobile.yml` lines 22-24), but it's configured as a `files` type, which would require users to upload icon files. This is not user-friendly.

Icons should be managed in the website so that site administrators can choose appropriate icons for each tab without needing to upload files or modify app code.

## Goals

1. Allow website users to select icons from a predefined list (no file uploads)
2. Update the mobile menu API to return icon information
3. Update the mobile app to use icons from the API instead of hardcoded mappings
4. Provide a user-friendly icon selector in the Kirby Panel

## Current State

**Backend (Kirby CMS):**
- `wsp-mobile/blueprints/tabs/mobile.yml` has an `icon` field (lines 22-24) but it's a `files` type
- `wsp-mobile/lib/menu.php` does NOT return icon information in the API response (lines 28-35)

**Frontend (React Native App):**
- `rn-mip-app/components/TabNavigator.tsx` has hardcoded `TAB_ICONS` mapping (lines 18-28)
- Icons are mapped by tab label (e.g., 'Home' → 'star', 'Resources' → 'book')
- Uses Ionicons from `@expo/vector-icons/Ionicons`

## Solution

**Use Kirby's `select` field type** with predefined icon names from Ionicons. The website user selects an icon name from a dropdown, and the app uses that icon name directly.

### Implementation Plan

#### Phase 1: Update Kirby Blueprint
**File:** `wsp-mobile/blueprints/tabs/mobile.yml`

Change the `icon` field from `files` type to `select` type with predefined Ionicons options:

```yaml
icon:
  type: select
  label: Icon
  help: "Choose an icon for this tab"
  options:
    # Navigation & Core
    home: Home
    star: Star
    book: Book
    book-outline: Book (Outline)
    # People & Community
    people: People
    people-outline: People (Outline)
    person: Person
    person-outline: Person (Outline)
    # Information
    information-circle: Information Circle
    information-circle-outline: Information Circle (Outline)
    # Actions & Engagement
    hand-left: Hand Left
    hand-left-outline: Hand Left (Outline)
    heart: Heart
    heart-outline: Heart (Outline)
    git-network: Network/Connect
    git-network-outline: Network/Connect (Outline)
    # Fallback
    ellipse: Default Circle
    ellipse-outline: Default Circle (Outline)
  default: ellipse
```

#### Phase 2: Update Mobile Menu API
**File:** `wsp-mobile/lib/menu.php`

Add icon to the API response (line 28-35):

```php
return [
    "label" => $item->label()->value(),
    "icon" => $item->icon()->value() ?: null,  // Add this line
    "page" => [
        "uuid" => $page->uuid()->id(),
        "type" => $page->intendedTemplate()->name(),
        "url" => $page->url()
    ]
];
```

#### Phase 3: Update Mobile App
**File:** `rn-mip-app/components/TabNavigator.tsx`

1. Update `MenuItem` interface in `api.ts` to include `icon?: string`
2. Modify `TAB_ICONS` usage to prefer API icon over hardcoded mapping
3. Fallback to hardcoded mapping if API doesn't provide icon
4. Ensure both `filled` and `outline` variants work (app can append `-outline` if needed)

**Implementation approach:**
- If API provides icon name, use it directly
- If icon name ends with `-outline`, use as-is for unselected state
- If icon name doesn't have `-outline`, append it for unselected state
- Fallback to `TAB_ICONS` mapping if no icon from API
- Fallback to `DEFAULT_ICON` if icon name not found in Ionicons

## Acceptance Criteria

- [ ] Website users can select icons from a dropdown (no file uploads)
- [ ] Icon selection includes common tab icons (home, book, people, heart, etc.)
- [ ] Mobile menu API returns icon information
- [ ] Mobile app uses icons from API when available
- [ ] Mobile app falls back gracefully to hardcoded icons if API doesn't provide icon
- [ ] Both filled and outline icon variants work correctly
- [ ] Existing tabs continue to work (backward compatible)

## Technical Notes

**Ionicons Naming:**
- Filled icons: `home`, `star`, `book`, etc.
- Outline icons: `home-outline`, `star-outline`, `book-outline`, etc.
- App can automatically append `-outline` for unselected state if needed

**Backward Compatibility:**
- If API doesn't return icon, use existing `TAB_ICONS` mapping
- If icon name not found in Ionicons, use `DEFAULT_ICON`
- Existing sites without icons configured will continue to work

**Icon Selection UX:**
- Dropdown should show icon name + description (e.g., "home - Home")
- Consider grouping icons by category in the dropdown
- Default to a sensible icon if none selected

## References

- Current icon implementation: `rn-mip-app/components/TabNavigator.tsx` lines 18-32
- Mobile menu API: `wsp-mobile/lib/menu.php`
- Mobile menu blueprint: `wsp-mobile/blueprints/tabs/mobile.yml`
- Related ticket: [072](072-connect-tab-navigation.md) - Connect tab navigation
- Previous icon work: [058](done/058-tab-icons.md) - Add Icons to Each Tab

## Dependencies

- Requires access to Kirby CMS to update blueprint
- Requires backend API update (`wsp-mobile`)
- Requires frontend app update (`rn-mip-app`)

## QA Notes

**Implementation complete.** User verified all icons display correctly:
- Icons are selectable via dropdown in Kirby Panel
- API returns icon values
- App displays correct icons (outlined when unselected, filled when selected)

### Commits
- wsp-mobile: `98d229b` - feat(ticket-084): Add icon dropdown to mobile menu blueprint and API (deployed 2026-01-23)
- rn-mip-app: `4c3a6fe` - feat(ticket-084): Use icons from API in mobile app

### Verification (2026-01-23)
- API deployed to ffci.fiveq.dev
- User configured icons in Kirby Panel: Resources=book, Chapters=information-circle-outline, Connect=heart
- User manually verified all 4 tabs display correct icons with proper filled/outline states
