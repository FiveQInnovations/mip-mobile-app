---
status: blocked
area: rn-mip-app
created: 2026-01-21
paused: 2026-01-21
---

# Build and Upload iOS to BrowserStack Without Apple Developer Account

## Context
Need to build and upload iOS apps to BrowserStack for testing. Initially explored if this was possible without a paid Apple Developer Account. **Finding:** EAS Build for iOS requires a paid Apple Developer Program membership ($99/year). Free Apple IDs are not supported by EAS Build. 

**Current Status:** Paused until access to Five Q paid Apple Developer account is available (expected next week). Once access is obtained, will proceed with linking account to EAS and building iOS preview IPA for BrowserStack testing.

## Tasks
- [x] Research BrowserStack iOS upload requirements and limitations
- [x] Investigate if BrowserStack supports unsigned or ad-hoc signed iOS builds
- [x] Check if EAS can build iOS without Apple Developer Account (development builds)
- [x] Explore Expo development builds for iOS (may not require paid Apple Developer Account)
- [x] Research if BrowserStack accepts TestFlight builds or other distribution methods
- [x] Test building iOS development build via EAS without Apple Developer credentials (FAILED - requires paid account)
- [ ] Verify if BrowserStack App Live API accepts unsigned iOS builds
- [ ] Document findings and any workarounds discovered
- [x] Compare with Android workflow to identify differences

## Notes

### Research: BrowserStack iOS Upload Requirements (2026-01-21)

**Status:** Research Complete

**Key Findings:**

1. **BrowserStack Accepts IPA Files:**
   - Format: `.ipa` files
   - Maximum file size: 1 GB
   - Upload methods:
     - Direct upload from system
     - Upload from public URL
     - TestFlight integration (if app is in TestFlight)

2. **BrowserStack iOS Signing Requirements:**
   - BrowserStack can accept unsigned or ad-hoc signed IPA files
   - For unsigned IPAs, BrowserStack requires:
     - App must be instrumented via BrowserStack's instrumentation endpoint (requires contacting support)
     - After instrumentation, app must be signed with your own certificate
     - Requires `.mobileprovision` file and signing certificate
   - **Important:** Even with unsigned IPAs, you still need signing certificates and provisioning profiles to properly sign the instrumented app

3. **TestFlight Option:**
   - BrowserStack supports installing apps directly from TestFlight
   - This requires:
     - App to be uploaded to TestFlight (requires Apple Developer Account)
     - TestFlight beta testing setup
   - **Limitation:** Still requires Apple Developer Account to use TestFlight

**Conclusion:** BrowserStack does support unsigned/ad-hoc signed IPAs, but the process is complex and still requires certificates/provisioning profiles. TestFlight option also requires Apple Developer Account.

---

### Research: EAS iOS Builds Without Paid Apple Developer Account (2026-01-21)

**Status:** Research Complete

**Key Findings:**

1. **Free Apple ID / Personal Team Option:**
   - EAS can build iOS apps using a free Apple ID (Personal Team)
   - Uses Apple's free provisioning profile (valid for 7 days)
   - Allows testing on physical devices without paid Apple Developer Program membership
   - Process:
     - Register device with EAS: `eas device:create`
     - Build with EAS: `eas build --platform ios --profile development`
     - EAS handles Personal Team provisioning profile creation automatically

2. **Limitations of Free Apple ID Approach:**
   - **Provisioning Profile Expiry:** Profiles expire after 7 days, requiring rebuild and reinstall
   - **Device Limitations:** Limited number of devices can be registered
   - **Capability Restrictions:** Some iOS capabilities require paid Apple Developer Account:
     - Apple Sign In
     - Push Notifications (production)
     - App Store distribution
     - Some advanced entitlements
   - **Not Suitable for Production:** Free accounts are for development/testing only

3. **EAS Build Process:**
   - EAS prompts for Apple account credentials (can use free Apple ID)
   - If credentials provided, EAS can generate provisioning profiles automatically
   - Without credentials, manual configuration required (more complex)

**Conclusion:** EAS can build iOS apps with a free Apple ID, but the resulting builds have limitations (7-day expiry, device restrictions). This could work for BrowserStack testing if the build can be uploaded within the validity period.

---

### Research: Expo Development Builds for iOS (2026-01-21)

**Status:** Research Complete

**Key Findings:**

1. **Development Builds vs Preview/Production:**
   - **Development builds** (`developmentClient: true`):
     - Require Expo dev server running
     - Use Personal Team provisioning (free Apple ID works)
     - Good for local development with hot reload
   - **Preview builds** (standalone):
     - Don't require dev server
     - Better for BrowserStack testing (like Android preview builds)
     - Still require signing (can use Personal Team)

2. **iOS Simulator Builds:**
   - Can build for iOS Simulator without any Apple Developer Account
   - These builds only work on simulators, not physical devices
   - Not useful for BrowserStack (BrowserStack uses real devices)

**Conclusion:** Expo development builds can use free Apple ID, but preview builds (needed for BrowserStack) still require signing. The free Apple ID approach should work for preview builds too.

---

### Comparison: iOS vs Android Workflow (2026-01-21)

**Status:** Analysis Complete

| Aspect | Android | iOS (Free Apple ID) | iOS (Paid Account) |
|--------|---------|---------------------|---------------------|
| **EAS Build** | ✅ Works without Google account | ⚠️ Works with free Apple ID | ✅ Works with paid account |
| **Signing** | ✅ Automatic (no account needed) | ⚠️ Personal Team (7-day expiry) | ✅ Full certificates |
| **BrowserStack Upload** | ✅ Direct APK upload | ⚠️ IPA upload (complex signing) | ✅ IPA upload |
| **Build Validity** | ✅ Permanent | ❌ 7 days | ✅ Permanent |
| **Device Limits** | ✅ Unlimited | ⚠️ Limited devices | ✅ Unlimited |
| **Capabilities** | ✅ All features | ❌ Some restricted | ✅ All features |

**Key Differences:**
- Android: No account needed, builds work indefinitely
- iOS (Free): Requires Apple ID, builds expire in 7 days, limited devices
- iOS (Paid): Full functionality, permanent builds, unlimited devices

---

### Test Results: EAS iOS Build with Free Apple ID (2026-01-21)

**Status:** ❌ Failed - EAS Requires Paid Apple Developer Account

**Objective:** Verify if EAS can build iOS preview IPA using free Apple ID (Personal Team) and if BrowserStack accepts the resulting build.

**Prerequisites:**
- Free Apple ID (not enrolled in Apple Developer Program)
- EAS CLI installed and logged in
- BrowserStack account credentials

**Test Execution:**

1. **Attempted iOS Preview Build:**
   ```bash
   cd rn-mip-app
   ./scripts/pre-build-check.sh  # ✅ Passed
   eas build --profile preview --platform ios
   ```

2. **Results:**
   - ✅ Pre-build validation passed
   - ✅ Apple ID authentication successful (anthony.elliott@fiveq.com)
   - ✅ 2FA code accepted
   - ❌ **EAS Build Failed:** "You have no team associated with your Apple account, cannot proceed."
   - ❌ **Error Message:** "Authentication with Apple Developer Portal failed! (Do you have a paid Apple Developer account?)"

**Key Finding:**
**EAS Build for iOS requires a paid Apple Developer Program membership.** Free Apple IDs (Personal Team) are not supported by EAS Build, even though they work for local Xcode builds.

**Why This Happens:**
- EAS Build uses Apple Developer Portal APIs that require a paid account
- Personal Team provisioning profiles are only available through Xcode locally
- EAS cannot generate Personal Team credentials remotely

**Conclusion:**
The free Apple ID approach does **NOT work** with EAS Build for iOS. A paid Apple Developer account ($99/year) is required for iOS builds via EAS.

---

### Alternative Approaches (2026-01-21)

**Status:** Researching Options

Since EAS Build requires a paid Apple Developer account, here are alternative approaches:

**Option 1: Local iOS Build for Simulator**
- Build locally: `eas build --platform ios --profile development --local`
- Works without paid account
- **Limitation:** Only works on iOS Simulator, not real devices
- **Not suitable for BrowserStack** (BrowserStack uses real devices)

**Option 2: Local iOS Build with Xcode**
- Build using Xcode directly on macOS
- Can use free Apple ID (Personal Team)
- Can install on physical devices (with 7-day expiry)
- **Limitation:** Requires manual Xcode setup, not automated via EAS
- **Potential:** Could manually create IPA and upload to BrowserStack

**Option 3: Paid Apple Developer Account**
- Enroll in Apple Developer Program ($99/year)
- Full EAS Build support
- Permanent builds, unlimited devices
- **Best option** for production workflow

**Option 4: TestFlight Distribution**
- Requires paid Apple Developer account
- BrowserStack supports TestFlight integration
- Good for beta testing workflow

**Recommendation:**
For BrowserStack testing without a paid account, **Option 2** (local Xcode build) is the only viable path, but it's manual and has limitations. For a production-ready workflow, **Option 3** (paid account) is recommended.

---

### 🚫 BLOCKED (2026-01-21)

**Status:** Blocked - Waiting for access to Five Q paid Apple Developer account (expected next week)

**Reason:** EAS Build for iOS requires a paid Apple Developer Program membership. Free Apple ID approach does not work with EAS Build.

**Plan When Resumed:**
1. Get access to Five Q Apple Developer account credentials
2. Link Apple Developer account with EAS (see ticket #005)
3. Retry iOS preview build: `eas build --profile preview --platform ios`
4. Download IPA from successful build
5. Upload IPA to BrowserStack App Live
6. Test iOS app on BrowserStack devices
7. Document complete iOS deployment workflow

**Related Tickets:**
- Ticket #003: Deploy to Real device (EAS) - iOS build blocked by Apple Developer account access
- Ticket #005: Link Apple Account with EAS - Will need to complete this when account access is available

---

### Next Steps (When Resumed)

1. ✅ **Research Complete** - BrowserStack requirements and EAS capabilities documented
2. ✅ **Test iOS Build** - Attempted build with free Apple ID - **FAILED** (requires paid account)
3. 🚫 **Blocked** - Waiting for Five Q Apple Developer account access (next week)
4. ⏳ **Link Apple Account** - Link paid account with EAS when access available
5. ⏳ **Retry iOS Build** - Build iOS preview IPA with paid account
6. ⏳ **Test BrowserStack Upload** - Upload IPA and verify installation
7. ⏳ **Document Workflow** - Finalize iOS deployment documentation

---
