---
status: backlog
area: rn-mip-app
phase: core
created: 2026-01-02
---

# Android Back Button Tab Navigation History

## Status Note
**Paused 2026-01-03:** Implementation complete and manually verified working (via adb screenshots). Ran out of disk space before Maestro tests could run. Resume by freeing disk space and running `./scripts/run-maestro-android-all.sh`.

## Context
Currently, the Android back button always navigates back to the Home tab, regardless of which tabs the user has visited. While this works, it doesn't follow the expected Android navigation pattern where the back button should maintain a navigation history.

## Problem
When a user navigates through tabs (e.g., Home → Resources → Chapters) and presses the back button, they expect to go back to the previous tab (Resources), but currently they're taken directly to Home.

**Example:**
- User opens Resources tab
- User opens Chapters tab  
- User presses back button
- **Current behavior:** Goes to Home tab
- **Expected behavior:** Goes back to Resources tab

## Current Implementation
The `BackHandler` in `TabNavigator.tsx` currently:
- Checks if user is on Home tab
- If not on Home, navigates to Home
- If on Home, allows app exit

## Proposed Solution
Implement a tab navigation history stack:
- Maintain a history array of visited tabs
- When user switches tabs, add to history
- When back button is pressed, pop from history and navigate to previous tab
- If history is empty (or only contains Home), allow app exit

## Benefits
- More intuitive Android navigation experience
- Follows Android navigation guidelines more closely
- Users can navigate back through their tab browsing history

## Related Files
- `rn-mip-app/components/TabNavigator.tsx` - Tab navigation component with BackHandler

## Notes
- Promoted to core functionality for proper Android navigation experience
- User tested on BrowserStack and confirmed current behavior works, but noted this would be an improvement
- Related to ticket #011 (Android Baseline UX) which implemented the basic back button functionality
