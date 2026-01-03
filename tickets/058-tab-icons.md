---
status: in-progress
area: rn-mip-app
phase: core
created: 2026-01-03
---

# Add Icons to Each Tab

## Context

The bottom tab bar currently shows text labels for each tab but lacks icons. The Home tab has a hardcoded emoji (🏠) but other tabs (Resources, Prayer Request, etc.) have no visual indicator. Native mobile apps typically use icons in tab bars for quick visual recognition.

## Current State

- `TabNavigator.tsx` already supports an `icon` property on menu items (line 126-128)
- Home tab has a hardcoded emoji icon (line 86)
- API menu items from `Mobilemainmenu` don't include icons
- Tab bar renders text-only for most tabs

## Solution

**Hardcode icons in app** - Map tab labels to icons using `@expo/vector-icons` (bundled with Expo). Icons are manually decided in the app code rather than driven by API.

## Tasks

- [ ] Import `Ionicons` from `@expo/vector-icons/Ionicons` in TabNavigator.tsx
- [ ] Create `TAB_ICONS` mapping for known tab labels
- [ ] Replace emoji icon rendering with `<Ionicons>` component (lines 126-128)
- [ ] Add `outline` variants for unselected state (e.g., `home-outline` vs `home`)
- [ ] Style icons with selected/unselected colors using `config.primaryColor`
- [ ] Test on iOS and Android

## Scouting Findings

### @expo/vector-icons Availability
- **Already included with Expo SDK 54** - no installation needed, just import
- SDK 50+ removed `ios-` and `md-` prefixes (e.g., `md-home` is now just `home`)
- Browse icons at: https://icons.expo.app

### Usage Pattern

```tsx
import Ionicons from '@expo/vector-icons/Ionicons';

<Ionicons name="home" size={24} color="#666" />
```

### Code References
- **TabNavigator.tsx lines 126-128**: Already has conditional icon rendering
- **TabNavigator.tsx line 86**: Home tab hardcoded with emoji `🏠`
- **TabNavigator.tsx lines 180-183**: `tabIcon` style already exists (fontSize: 20, marginBottom: 4)
- **api.ts lines 13-17**: `MenuItem` interface already has `icon?: string`

### Implementation Outline
1. Import `Ionicons` from `@expo/vector-icons/Ionicons`
2. Create icon mapping object:
   ```tsx
   const TAB_ICONS: Record<string, keyof typeof Ionicons.glyphMap> = {
     'Home': 'home',
     'Resources': 'library',
     'Prayer Request': 'heart',
     'Chaplain Request': 'person',
   };
   ```
3. Replace emoji rendering with Ionicons component
4. Add selected/unselected color styling (use `config.primaryColor` for selected)

## Notes

- `@expo/vector-icons` includes Ionicons, MaterialIcons, FontAwesome, etc.
- Icon suggestions:
  - Home: `home` (Ionicons)
  - Resources: `library` or `book` (Ionicons)
  - Prayer Request: `heart` or `hand-left` (Ionicons)
  - Chaplain Request: `person` or `chatbubbles` (Ionicons)
