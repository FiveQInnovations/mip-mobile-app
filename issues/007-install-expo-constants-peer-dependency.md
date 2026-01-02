---
status: backlog
area: rn-mip-app
created: 2026-01-20
---

# Install missing peer dependency: expo-constants

## Context
The `expo-router` package requires `expo-constants` as a peer dependency, but it's not currently installed. This can cause the app to crash outside of Expo Go. Native module peer dependencies must be installed directly.

## Tasks
- [ ] Install `expo-constants` using `npx expo install expo-constants`
- [ ] Verify installation doesn't break existing functionality
- [ ] Test app runs correctly with the new dependency

## Notes

### Discovery (2026-01-20)
- Found by `expo-doctor` during EAS Android build process
- Required by: `expo-router`
- **Important:** App may crash outside of Expo Go without this dependency
- Native module peer dependencies must be installed directly (not just listed in package.json)

