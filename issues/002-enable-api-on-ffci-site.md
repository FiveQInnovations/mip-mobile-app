---
status: done
area: ws-ffci-copy
created: 2026-01-02
completed: 2026-01-02
---

# Enable API on the real FFCI site

## Context
Currently need to run a local server to test the mobile app. Need to enable the mobile API on the production FFCI site so that local development/testing doesn't require running a local Kirby instance.

**Target:** Deployed API at `https://ffci.fiveq.dev`
- **Must work with deployed server** (not local)
- Simulator should be able to access this directly (no proxy needed)
- Must verify mobile app works without local DDEV server running
- This confirms production-ready configuration

**Note:** Issue #001 verified X-API-Key auth works with local server. This issue is specifically about making it work with the deployed production server.

**Authentication Requirements:**
- X-API-Key header: `777359235aecc10fdfb144041dfdacfc80ca0751c7bed7b14c96f935456fc4ce`
- HTTP Basic Auth credentials: `fiveq/demo` (username/password)
  - **Note:** This Basic Auth requirement is likely temporary for the staging/dev environment and may not be needed in production

## Tasks
- [x] Verify/configure mobile API settings in Kirby Panel on `ffci.fiveq.dev` ✅ **VERIFIED - Already configured**
- [x] Verify/set up API key/authentication: `777359235aecc10fdfb144041dfdacfc80ca0751c7bed7b14c96f935456fc4ce` ✅ **VERIFIED - Already configured**
- [x] Update mobile app to include HTTP Basic Auth credentials (`fiveq/demo`) in API requests ✅ **COMPLETED**
- [x] Verify API endpoints are accessible from simulator ✅ **VERIFIED - Homepage loads successfully**
- [x] Update `rn-mip-app/configs/ffci.json` to use `https://ffci.fiveq.dev` ✅ **COMPLETED**
- [x] Test mobile app connection to deployed API (stop local server first) ✅ **VERIFIED - App works without local server**
- [x] Verify Maestro tests pass with deployed API ✅ **VERIFIED - home-action-hub flow passes**
- [x] Document API endpoint URL and credentials (including Basic Auth requirement) ✅ **COMPLETED**

## Notes

**Current Status (2026-01-02):**
- ✅ X-API-Key authentication implemented and working locally
- ✅ Local DDEV site (`ws-ffci.ddev.site`) working with proxy
- ✅ Deployed API at `ffci.fiveq.dev` is FULLY CONFIGURED and working
  - Mobile API endpoint: ENABLED ✅
  - API Key authentication: CONFIGURED ✅
  - Requires both X-API-Key header AND HTTP Basic Auth
  - Basic Auth credentials: `fiveq/demo` (likely temporary for staging/dev)
  - **Verified:** Tested on 2026-01-02 - API responds successfully with both auth methods
- ✅ Mobile app updated to include Basic Auth credentials
- ✅ Config updated to use `https://ffci.fiveq.dev`
- ✅ Verified on iOS simulator - homepage loads successfully
- ✅ **Issue resolved:** Resources page now loads successfully
  - **Root cause:** `lib/config.ts` was hardcoding proxy URL (`http://192.168.0.106:8888`) instead of using deployed API URL from `ffci.json`
  - **Fix:** Removed proxy URL override in `lib/config.ts` to use `https://ffci.fiveq.dev` from config file
  - **Additional fixes:**
    - Updated base64 encoding to use `base64-js` library for reliable encoding
    - Added Basic Auth header to all API requests
  - **Status:** ✅ **FULLY WORKING**
    - Homepage loads successfully ✅
    - Resources page loads successfully ✅
    - All tabs working ✅
    - App connects directly to deployed API without local server ✅
- ✅ Maestro tests pass with deployed API (homepage flows):
  - home-action-hub flow: ✅ All assertions pass
  - homepage-loads flow: ✅ Passes
  - home-tab-navigation flow: ✅ Passes
  - navigation-resources flow: ✅ **VERIFIED - All steps pass** (tested 2026-01-02)

**Implementation Summary:**
1. ✅ Verified API key on `ffci.fiveq.dev` - Already configured
2. ✅ Updated config: `apiBaseUrl: "https://ffci.fiveq.dev"`
3. ✅ Added HTTP Basic Auth to API client (`rn-mip-app/lib/api.ts`)
4. ✅ Tested app in iOS simulator without local DDEV server
5. ✅ Verified homepage loads successfully with deployed API
6. ✅ Ran Maestro tests - All flows pass:
   - home-action-hub ✅
   - homepage-loads ✅
   - home-tab-navigation ✅
   - navigation-resources ✅

**API Configuration:**
- Endpoint: `https://ffci.fiveq.dev/mobile-api`
- Authentication: X-API-Key header + HTTP Basic Auth
- API Key: `777359235aecc10fdfb144041dfdacfc80ca0751c7bed7b14c96f935456fc4ce`
- Basic Auth: `fiveq:demo` (base64 encoded in Authorization header)

