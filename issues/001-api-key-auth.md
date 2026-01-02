---
status: backlog
area: rn-mip-app
created: 2026-01-20
---

# Update RN app to use X-API-Key authentication

## Context
The `wsp-mobile` plugin was updated to switch from Bearer Token authentication to X-API-Key header authentication. The React Native app (`rn-mip-app`) currently uses Bearer tokens and needs to be updated to match the new API authentication method.

Related commits:
- `b1c5fbb` - Switch auth from Bearer Token to X-API-Key header (wsp-mobile)
- `60a3691` - feat: add optional shared secret authentication (wsp-mobile)

## Tasks
- [ ] Review current authentication implementation in `rn-mip-app/lib/api.ts`
- [ ] Update API client to use X-API-Key header instead of Authorization Bearer token
- [ ] Ensure API key is loaded from config (check `rn-mip-app/lib/config.ts`)
- [ ] Test authentication against local Kirby instance
- [ ] Update any related documentation

## Notes
(Add notes as you work on this)

