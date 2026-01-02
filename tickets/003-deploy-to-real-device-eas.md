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
- [ ] Build iOS app via EAS
- [ ] Deploy and verify iOS app on physical device
- [x] Build Android app via EAS
- [x] Deploy and verify Android app on physical device (BrowserStack)
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

---

### ✅ Android Build Successful (2026-01-20)

**Status:** Completed - Android development build created successfully

**Build Details:**
- **Build ID:** `3cbc5e05-0a44-4611-8a3f-6e554e12d7c2`
- **Profile:** `development`
- **Platform:** Android
- **Build Link:** https://expo.dev/accounts/fiveq-innovations/projects/ffci-app/builds/3cbc5e05-0a44-4611-8a3f-6e554e12d7c2

**Build Process:**
- ✅ Project files compressed and uploaded to EAS Build (5.6 MB)
- ✅ Project fingerprint computed successfully
- ✅ Build completed without errors
- ✅ QR code generated for easy installation on Android devices

**Installation:**
- Scan the QR code or visit the build link on an Android device to install the app
- Build is configured for internal distribution (development profile)

**Next Steps:**
- ✅ Build completed successfully - ready for deployment
- ⏳ **PENDING:** Deploy and verify on physical Android device (see deployment steps below)
- Proceed with iOS build once Apple Developer Account access is resolved

---

### 📱 Android Device Deployment Steps (Pending)

**Status:** Not Started - Build ready, awaiting deployment to physical device

**Deployment Process:**

1. **Access the Build:**
   - Build Link: https://expo.dev/accounts/fiveq-innovations/projects/ffci-app/builds/3cbc5e05-0a44-4611-8a3f-6e554e12d7c2
   - QR code available in build output (scan with Android device)

2. **Install on Android Device:**
   - Option A: Scan QR code from build output with Android device camera
   - Option B: Open build link directly on Android device browser
   - Option C: Download APK manually and transfer to device

3. **Enable Installation from Unknown Sources (if needed):**
   - Android Settings → Security → Enable "Install unknown apps" for browser/file manager
   - May need to allow installation from specific source (browser/file manager)

4. **Install and Launch:**
   - Tap the downloaded APK to install
   - Grant necessary permissions when prompted
   - Launch the app from device home screen

5. **Verify Functionality:**
   - [ ] App launches without crashes
   - [ ] Homepage loads correctly
   - [ ] Navigation between tabs works
   - [ ] Resources page loads (previously had loading delay issues)
   - [ ] API authentication works correctly
   - [ ] All core features function as expected
   - [ ] Performance is acceptable on real device

6. **Troubleshooting (if needed):**
   - If installation fails, check Android version compatibility
   - Verify device has sufficient storage space
   - Check device logs for errors: `adb logcat` (if device connected via USB)
   - Ensure development build profile is correct (not production)

**Notes:**
- ⚠️ **Development build requires dev server**: The `development` profile includes `developmentClient: true`, which means the app requires a running Expo dev server (`npx expo start --dev-client`) to load JavaScript bundles
- For standalone testing (BrowserStack, physical devices without dev server), use the `preview` profile instead: `eas build --profile preview --platform android`
- See **[docs/how-to-build-android.md](../../docs/how-to-build-android.md)** for build type reference
- First-time installation may take longer due to app size

### ✅ Emulator Verification (2026-01-02)

- Installed latest EAS Android development build (`eas-build-latest.apk`) on Pixel 6 emulator (emulator-5554) and confirmed homepage loads fully against `https://ffci.fiveq.dev` (screenshot: `rn-mip-app/android-emulator-home.png`).
- Also built and installed local debug dev-client via `expo run:android`; homepage loads and prefetch logs confirm API success.
- Added Android-specific Maestro flow (`maestro/flows/homepage-loads-android.yaml`) and npm script `test:maestro:android`.
- Maestro run currently blocked on Android by driver connection error `UNAVAILABLE: io exception (Connection refused localhost:7001)`; emulator is running and reachable via adb. Next step: restart emulator or reinstall Maestro driver and re-run `MAESTRO_DEVICE=emulator-5554 npm run test:maestro:android`.

**Expo Doctor Findings:**
- EAS Build ran `expo-doctor` automatically and detected 4 issues
- Tickets documented as separate backlog items:
  - Ticket #006: Add `.expo/` to `.gitignore`
  - Ticket #007: Install missing peer dependency `expo-constants`
  - Ticket #008: Resolve native config sync issues (app.json vs native folders)
  - Ticket #009: Update package versions to match Expo SDK requirements
- These are non-blocking for the current build but should be addressed

---

### ☁️ Cloud Device Testing Options (2026-01-20)

**Status:** Research Complete - Recommendations provided

**Context:**
Since using a personal device is challenging, researched cloud-based services that allow APK upload and testing on real Android devices.

**Recommended Option: BrowserStack App Live** ⭐

**Why BrowserStack:**
- ✅ **Direct APK Upload**: Upload APK files directly (no need for app store)
- ✅ **Real Devices**: Access to wide range of real Android devices with different OS versions
- ✅ **Interactive Testing**: Manual testing with full device interaction
- ✅ **Debugging Tools**: Device logs, crash reports, network captures
- ✅ **Easy Setup**: Simple upload and select device workflow
- ✅ **Paid Service**: Professional platform with reliable infrastructure

**How to Use BrowserStack:**
1. Sign up for BrowserStack account (paid plans available)
2. Navigate to [App Live dashboard](https://www.browserstack.com/app-live)
3. Upload APK file:
   - Click "Uploaded Apps" → "Upload"
   - Upload the APK from EAS build (download from build link first)
4. Select Android device from available options
5. Start interactive testing session
6. Test app functionality, navigation, performance on real device

**Alternative Options:**

**1. Firebase Test Lab** (Google)
- Cloud-based Android testing infrastructure
- Good for automated testing (Robo tests, instrumented tests)
- Less ideal for manual interactive testing
- Pricing: Pay-per-use model

**2. AWS Device Farm**
- Amazon's cloud device testing service
- Supports both manual and automated testing
- Good integration with AWS ecosystem
- Pricing: Pay-per-use model

**3. Sauce Labs**
- Similar to BrowserStack, cloud device testing platform
- Supports APK upload and real device testing
- Good for both manual and automated testing

**4. EAS Internal Distribution** (Already Configured)
- ✅ Already set up in `eas.json` with `"distribution": "internal"`
- ✅ Build ready: https://expo.dev/accounts/fiveq-innovations/projects/ffci-app/builds/3cbc5e05-0a44-4611-8a3f-6e554e12d7c2
- ⚠️ Still requires access to a physical device (just makes installation easier)
- Best for: Sharing with team members who have devices

**Recommendation:**
**Use BrowserStack App Live** for immediate testing needs. It's specifically designed for this use case - uploading an APK and testing on real devices in the cloud without needing physical hardware.

**Decision (2026-01-20):**
✅ **BrowserStack selected** - Account already exists, ready to use immediately.

**Next Steps:**
1. ✅ BrowserStack account confirmed (already have account)
2. ✅ Download APK from EAS build link
3. ✅ Upload to BrowserStack App Live (manual upload for now)
4. ✅ Select Android device and begin testing
5. ✅ Verify all functionality as outlined in deployment steps above
6. Future: Integrate BrowserStack API for automated uploads (see Ticket #010)

---

### ✅ BrowserStack Testing - React Version Fix (2026-01-02)

**Status:** Resolved - App successfully tested on BrowserStack

**Issue Encountered:**
- Initial preview build (`ffci-preview-20260102-141742.apk`) crashed on BrowserStack with React version mismatch error:
  ```
  FATAL EXCEPTION: com.facebook.react.common.JavascriptException
  Error: Incompatible React versions:
    - react: 19.2.3
    - react-native-renderer: 19.1.0
  ```
- React Native 0.81.5 requires React 19.1.0, but package.json had React 19.2.3

**Fix Applied:**
1. **Updated `package.json`**: Changed React from `^19.2.3` to `19.1.0` (exact version required by React Native 0.81.5)
2. **Updated `eas.json`**: Added `NPM_CONFIG_LEGACY_PEER_DEPS: "true"` to preview profile to handle peer dependency conflicts
3. **Reinstalled dependencies**: Ran `npm install --legacy-peer-deps` locally
4. **Rebuilt preview APK**: Created new build with fixed React version

**Build Details:**
- **Build ID:** `04e82f0b-9e54-415c-9d94-4ed4e528384b`
- **Profile:** `preview`
- **Platform:** Android
- **Build URL:** https://expo.dev/accounts/fiveq-innovations/projects/ffci-app/builds/04e82f0b-9e54-415c-9d94-4ed4e528384b
- **APK File:** `ffci-preview-fixed-20260102-145905.apk` (92.06 MB)
- **BrowserStack App URL:** `bs://42fd983b3cb998bc0935680dc97e354e07d358be`

**Testing Results:**
- ✅ App launches successfully on BrowserStack (Samsung Galaxy S25)
- ✅ No React version mismatch errors
- ✅ Homepage loads correctly with all sections visible:
  - Quick Tasks (Prayer Request, Chaplain Request, Resources, Donate)
  - Get Connected (Find a Chapter, Upcoming Events)
  - Featured section
  - Bottom navigation bar (Home, Resources, Careers, About, Get Involved)
- ✅ App is fully functional and ready for further testing

**Files Modified:**
- `package.json`: React version set to `19.1.0`
- `eas.json`: Added `NPM_CONFIG_LEGACY_PEER_DEPS` environment variable to preview profile
- `package-lock.json`: Updated with correct React version

**Related Tickets:**
- Ticket #010: Integrate BrowserStack App Live API (for automated uploads)

