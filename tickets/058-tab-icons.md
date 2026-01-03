---
status: backlog
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

## Solution Options

1. **Hardcode icons in app** - Map tab labels to appropriate icons in the React Native app
2. **Add icons to API** - Extend wsp-mobile plugin to include icon names in menu response
3. **Use icon library** - Install `@expo/vector-icons` or similar for native icons

## Tasks

- [ ] Install `@expo/vector-icons` (included with Expo)
- [ ] Create icon mapping for known tab labels (Home, Resources, Prayer Request, etc.)
- [ ] Update `TabNavigator.tsx` to render icons from the mapping
- [ ] Style icons appropriately (size, color for selected/unselected states)
- [ ] Test on iOS and Android

## Notes

- `@expo/vector-icons` includes Ionicons, MaterialIcons, FontAwesome, etc.
- Icon suggestions:
  - Home: `home` (Ionicons)
  - Resources: `library` or `book` (Ionicons)
  - Prayer Request: `heart` or `hand-left` (Ionicons)
  - Chaplain Request: `person` or `chatbubbles` (Ionicons)
