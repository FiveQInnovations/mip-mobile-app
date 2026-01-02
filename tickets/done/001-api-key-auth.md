---
status: done
area: rn-mip-app
created: 2026-01-20
completed: 2026-01-02
---

# Update RN app to use X-API-Key authentication

## Context
The `wsp-mobile` plugin was updated to switch from Bearer Token authentication to X-API-Key header authentication. The React Native app (`rn-mip-app`) currently uses Bearer tokens and needs to be updated to match the new API authentication method.

Related commits:
- `b1c5fbb` - Switch auth from Bearer Token to X-API-Key header (wsp-mobile)
- `60a3691` - feat: add optional shared secret authentication (wsp-mobile)

## Tasks
- [x] Review current authentication implementation in `rn-mip-app/lib/api.ts`
- [x] Update API client to use X-API-Key header instead of Authorization Bearer token
- [x] Ensure API key is loaded from config (check `rn-mip-app/lib/config.ts`)
- [x] Test authentication against local Kirby instance
- [x] Update any related documentation

## Notes

### Implementation Complete (2026-01-20)

**Changes Made:**

1. **Updated `rn-mip-app/lib/config.ts`**:
   - Renamed `apiToken` to `apiKey` in `SiteConfig` interface
   - Updated development config value to: `777359235aecc10fdfb144041dfdacfc80ca0751c7bed7b14c96f935456fc4ce`

2. **Updated `rn-mip-app/configs/ffci.json`**:
   - Added `apiKey` field with the new API key value

3. **Updated `rn-mip-app/lib/api.ts`**:
   - Changed header from `Authorization: Bearer ${config.apiToken}` to `X-API-Key: config.apiKey`

**Verification:**

- ✅ Maestro test `homepage-loads.yaml` passed successfully
- ✅ App launched and homepage content loaded (confirms API authentication working)
- ✅ Navigation tabs visible (Resources, Chapters, Connect, Give, Home, About)
- ✅ No TypeScript or linter errors

The migration from Bearer token to X-API-Key authentication is complete and verified working with local server.

**Note:** Verification with deployed server (`ffci.fiveq.dev`) is tracked in issue #002.

