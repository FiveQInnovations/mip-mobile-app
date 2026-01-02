---
status: in-progress
area: ws-ffci-copy
created: 2026-01-20
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
- [ ] Configure mobile API settings in Kirby Panel on `ffci.fiveq.dev`
- [ ] Set up API key/authentication: `777359235aecc10fdfb144041dfdacfc80ca0751c7bed7b14c96f935456fc4ce`
- [ ] Update mobile app to include HTTP Basic Auth credentials (`fiveq/demo`) in API requests
- [ ] Verify API endpoints are accessible from simulator
- [ ] Update `rn-mip-app/configs/ffci.json` to use `https://ffci.fiveq.dev`
- [ ] Test mobile app connection to deployed API (stop local server first)
- [ ] Verify Maestro tests pass with deployed API
- [ ] Document API endpoint URL and credentials (including Basic Auth requirement)

## Notes

**Current Status (2026-01-02):**
- ✅ X-API-Key authentication implemented and working locally
- ✅ Local DDEV site (`ws-ffci.ddev.site`) working with proxy
- ⚠️ Deployed API at `ffci.fiveq.dev` requires both X-API-Key header and HTTP Basic Auth
  - Basic Auth credentials: `fiveq/demo` (likely temporary for staging/dev)
  - Need to configure API key on production server
  - Need to verify mobile API endpoint is enabled
  - Mobile app must be updated to include Basic Auth credentials

**Testing Plan:**
1. Configure API key on `ffci.fiveq.dev`
2. Update config: `apiBaseUrl: "https://ffci.fiveq.dev"`
3. Stop local DDEV server and proxy
4. Launch app in simulator
5. Verify homepage loads successfully
6. Run Maestro test to confirm end-to-end functionality

