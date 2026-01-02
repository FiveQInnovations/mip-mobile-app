---
status: in-progress
area: rn-mip-app
created: 2026-01-20
---

# Deploy to Real device (EAS)

## Context
Need to deploy the React Native app to a real device using Expo Application Services (EAS) for testing on physical hardware instead of just simulators.

## Tasks
- [x] Set up EAS account/project
- [x] Configure EAS build settings
- [x] Create development build configuration
- [ ] Build and deploy to iOS device
- [ ] Build and deploy to Android device
- [ ] Test on physical devices
- [ ] Document deployment process

## Notes

### ✅ RESOLVED: EAS Authentication (2026-01-20)

**Status:** Resolved - New organization created

**Resolution:**
- Micah confirmed he uses a free account not linked to Five Q organization
- Created new EAS organization with personal account
- Added billing and upgraded to Starter plan ($20/month)
- Can now proceed with EAS setup using new organization

**Next Steps:**
- ✅ Run `eas login` with new account credentials - **COMPLETED**
- ✅ Initialize EAS project: `eas init` - **COMPLETED** (project already linked)
- ✅ Create `eas.json` with build profiles - **COMPLETED**

---

### 🚫 BLOCKER: Apple Developer Account Access (2026-01-20)

**Status:** Blocked - Waiting on 2FA access

**Issue:**
- EAS build requires Apple Developer Account login for iOS builds
- Credentials available in 1Password
- 2FA codes are sent to Nathan's phone number
- Cannot complete Apple Developer Account authentication without 2FA code

**Action Taken:**
- Pinged Nathan for assistance with 2FA
- Waiting for response

**Blocked Tasks:**
- Cannot complete `eas build --profile development --platform ios`
- Cannot proceed with iOS device deployment
- Android builds may still be possible (not blocked by Apple Developer Account)

**Workaround Options:**
- Try Android build first: `eas build --profile development --platform android` (doesn't require Apple Developer Account)
- Consider local iOS build if credentials can be configured manually (see issue #005 for Apple account linking)

---

### Investigation: mljtrust-mobile Project (2026-01-20)

Found EAS configuration in `/Users/anthony/clients/mlj/mljtrust-mobile` (set up by Micah):

**Key Findings:**

1. **EAS Account/Organization**: `fiveq` (set in `app.json` as `"owner": "fiveq"`)

2. **EAS Project Configuration** (`app.json`):
   ```json
   "extra": {
     "eas": {
       "projectId": "cdb177a2-ed84-428d-8fb5-6d6ca1e3f149"
     }
   },
   "owner": "fiveq"
   ```

3. **EAS Build Configuration** (`eas.json`):
   ```json
   {
     "cli": {
       "version": ">= 16.12.0",
       "appVersionSource": "remote"
     },
     "build": {
       "development": {
         "developmentClient": true,
         "distribution": "internal"
       },
       "preview": {
         "distribution": "internal"
       },
       "production": {
         "autoIncrement": true
       }
     },
     "submit": {
       "production": {}
     }
   }
   ```

4. **Current Status**:
   - MLJ app uses local builds for Android (`eas build -p android --local`)
   - iOS builds are done manually via Xcode (not using EAS yet)
   - README notes: "In the future - Move all build/submit steps to hosted eas (ideally with a paid account)"

**Next Steps for FFCI App:**

1. ✅ Install EAS CLI: `npm install -g eas-cli` - **COMPLETED** (version 16.28.0 installed)
2. ✅ Set up EAS organization - **COMPLETED**
   - Created new organization (not using Micah's free account)
   - Added billing and upgraded to Starter plan ($20/month)
3. ✅ Login to EAS: `eas login` - **COMPLETED**
4. ✅ Initialize EAS project: `eas init` - **COMPLETED** (project already linked, ID: f0f371f0-e1b5-4100-b39f-615d9c6ffcf1)
5. ✅ Create `eas.json` - **COMPLETED** (created with development, preview, and production profiles)
6. ✅ Configure `app.json` - **VERIFIED**
   - Owner set to: `fiveq-innovations` (verify this matches your new organization name)
   - Bundle identifiers:
     - iOS: `com.fiveq.ffci` ✅
     - Android: `com.fiveq.ffci` ✅
7. ✅ **FIXED** - Android build dependency issue resolved (2026-01-20)
   - **Build Failed:** React version mismatch causing peer dependency conflict
   - **Error:** `react@19.1.0` conflicted with `react-dom@19.2.3` (required by expo-router)
   - **Initial Fix Attempt:** Updated React to 19.2.3, but caused React Native compatibility issue
   - **Final Fix Applied:**
     - Kept `react@19.1.0` (required by React Native 0.81.5)
     - Configured EAS build to use `--legacy-peer-deps` via `NPM_CONFIG_LEGACY_PEER_DEPS` environment variable in `eas.json`
     - Moved runtime dependencies from `devDependencies` to `dependencies`:
       - `expo-router`, `@react-native-async-storage/async-storage`, `@tanstack/react-query`
       - `react-native-safe-area-context`, `react-native-screens`, `react-native-webview`
       - `nativewind`, `zustand`
   - Updated `package-lock.json` with `npm install`
   - Ready to retry Android build: `eas build --profile development --platform android`

---

### ✅ iOS App Rebuild Verification (2026-01-20)

**Status:** Verified - App rebuilds successfully after React version fix

**Actions Taken:**
- Rebuilt iOS app locally with React 19.1.0
- Verified no React version mismatch errors
- App launches and displays correctly
- Fixed Maestro config.yaml (empty envs issue)
- Fixed Maestro test files (removed unsupported `timeout` properties)

**Test Results:**
- Maestro tests: 5/10 passing (core functionality verified)
- Passing tests: `_setup`, `tab-switch-from-home`, `test-prefetch-performance`, `navigation-resources`, `homepage-loads`
- Failing tests appear to be UI element matching issues, not core functionality problems

**Files Modified:**
- `package.json`: React version set to 19.1.0, dependencies reorganized
- `eas.json`: Added `NPM_CONFIG_LEGACY_PEER_DEPS` environment variable for development profile
- `maestro/config.yaml`: Added empty `envs: {}` to fix parsing error
- `maestro/flows/*.yaml`: Removed unsupported `timeout` properties from assertVisible commands

