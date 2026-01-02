---
status: in-progress
area: rn-mip-app
created: 2026-01-20
---

# Deploy to Real device (EAS)

## Context
Need to deploy the React Native app to a real device using Expo Application Services (EAS) for testing on physical hardware instead of just simulators.

## Tasks
- [ ] Set up EAS account/project
- [ ] Configure EAS build settings
- [ ] Create development build configuration
- [ ] Build and deploy to iOS device
- [ ] Build and deploy to Android device
- [ ] Test on physical devices
- [ ] Document deployment process

## Notes

### 🚫 BLOCKER: EAS Authentication (2026-01-20)

**Status:** Blocked - Waiting on credentials

**Issue:**
- Cannot log in to EAS account (`eas login` fails)
- Credentials in 1Password do not work
- "Forgot Password" email not received when requested
- Cannot proceed with EAS setup without valid credentials

**Action Taken:**
- Contacted main dev (Micah) via text for current EAS credentials
- Waiting for response

**Blocked Tasks:**
- Cannot run `eas login`
- Cannot run `eas init` to set up project
- Cannot proceed with any EAS build configuration

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
2. 🚫 **BLOCKED** - Login to EAS: `eas login` - **WAITING FOR CREDENTIALS**
   - 1Password credentials do not work
   - Password reset email not received
   - Contacted Micah for current credentials
3. Initialize EAS project: `eas init` (will create `eas.json` and add project ID to `app.json`)
4. Configure `app.json`:
   - Add `"owner": "fiveq"` to `expo` object
   - Ensure bundle identifiers match:
     - iOS: `com.fiveq.ffci` (already set)
     - Android: `com.fiveq.ffci` (already set)
5. Create development build: `eas build --profile development --platform ios` (or android)

