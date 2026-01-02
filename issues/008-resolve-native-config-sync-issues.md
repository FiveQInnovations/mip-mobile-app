---
status: backlog
area: rn-mip-app
created: 2026-01-20
---

# Resolve native config sync issues (app.json vs native folders)

## Context
This project contains native project folders (`android/` and `ios/`) but also has native configuration properties in `app.json`, indicating it is configured to use Prebuild. When native folders are present, EAS Build will not sync the following properties from `app.json`: `orientation`, `icon`, `userInterfaceStyle`, `splash`, `ios`, `android`, `scheme`, `plugins`.

This can lead to configuration drift between what's in `app.json` and what's actually used in the native projects.

## Tasks
- [ ] Review native configuration properties in `app.json`
- [ ] Determine if we should:
  - Option A: Remove native folders and use Prebuild (let Expo manage native code)
  - Option B: Remove native config from `app.json` and manage it directly in native folders
- [ ] Implement chosen approach
- [ ] Verify EAS builds use correct configuration
- [ ] Document decision and rationale

## Notes

### Discovery (2026-01-20)
- Found by `expo-doctor` during EAS Android build process
- Project has both `android/` and `ios/` folders AND native config in `app.json`
- EAS Build ignores these `app.json` properties when native folders exist:
  - `orientation`
  - `icon`
  - `userInterfaceStyle`
  - `splash`
  - `ios`
  - `android`
  - `scheme`
  - `plugins`

### Considerations
- If using Prebuild (managed workflow), native folders should be gitignored
- If using bare workflow, native config should be in native project files, not `app.json`
- Current setup is a hybrid that can cause confusion

