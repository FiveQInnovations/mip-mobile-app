---
status: done
area: rn-mip-app
created: 2026-01-20
---

# Resolve native config sync issues (app.json vs native folders)

## Context
This project contains native project folders (`android/` and `ios/`) but also has native configuration properties in `app.json`, indicating it is configured to use Prebuild. When native folders are present, EAS Build will not sync the following properties from `app.json`: `orientation`, `icon`, `userInterfaceStyle`, `splash`, `ios`, `android`, `scheme`, `plugins`.

This can lead to configuration drift between what's in `app.json` and what's actually used in the native projects.

## Tasks
- [x] Review native configuration properties in `app.json`
- [x] Determine if we should:
  - Option A: Remove native folders and use Prebuild (let Expo manage native code) ✅ **CHOSEN**
  - Option B: Remove native config from `app.json` and manage it directly in native folders
- [x] Implement chosen approach
  - [x] Updated `.gitignore` to ignore `ios/` and `android/` folders
  - [x] Remove native folders from git tracking: `git rm -r --cached ios/ android/`
  - [x] Commit changes
- [ ] Verify EAS builds use correct configuration
- [x] Document decision and rationale

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

### Resolution (2026-01-20) - CORRECTED
**Decision:** Switch to proper CNG (Continuous Native Generation) by gitignoring native folders.

**Rationale:**
- Project is intended to use CNG/Prebuild (evidenced by `.gitignore` comment "generated native folders" and `expo prebuild --clean` usage in setup)
- Native folders (`ios/` and `android/`) are currently committed to git, which makes EAS Build treat them as bare workflow
- All custom native configurations (e.g., `NSAppTransportSecurity` in Info.plist) are already properly configured in `app.json` and will be regenerated correctly
- With CNG, EAS Build will automatically run prebuild and sync all `app.json` properties, ensuring consistency
- Native folders should be gitignored so they're regenerated from `app.json` on each build

**Action Items:**
1. ✅ Add `ios/` and `android/` to `.gitignore` - **COMPLETED**
2. ✅ Remove native folders from git tracking: `git rm -r --cached ios/ android/` - **COMPLETED**
3. ✅ Commit the changes - **COMPLETED** (commit: `95248d4`)
4. ⏳ Verify EAS builds regenerate native folders correctly from `app.json` - **PENDING** (next EAS build)
5. ✅ Local development: Run `npx expo prebuild` when needed, or let `expo run:ios`/`expo run:android` handle it automatically - **DOCUMENTED**

**Implementation Summary (2026-01-20):**
- Updated `.gitignore` to ignore `ios/` and `android/` folders completely
- Removed 68 native files from git tracking (all iOS and Android native project files)
- Committed changes with message: "Switch to CNG: gitignore native folders"
- Native folders still exist locally but are now gitignored
- EAS Build will now automatically run `expo prebuild` to generate native folders from `app.json` on each build
- All `app.json` properties will be synced during builds (orientation, icon, splash, ios, android, scheme, plugins)

**Note:** The custom `NSAppTransportSecurity` settings in `app.json` (lines 18-36) will be automatically applied to the regenerated `Info.plist` during prebuild, so no custom config plugins are needed for this use case.

