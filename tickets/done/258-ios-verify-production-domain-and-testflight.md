---
status: done
area: ios-mip-app
phase: production
created: 2026-03-18
---

# Verify iOS Against Production Domain and Ship TestFlight Build

## Context

The FFCI website has launched on `https://firefightersforchrist.org/` instead of
`https://ffci.fiveq.dev/`. The mobile app may still be pointed at API or domain
references on the old host, which could break content loading, navigation, or
other web-backed features.

We need to verify whether the current iOS app still works against the live
production setup, update any remaining old-domain references, get the app
running locally again, and deliver a fresh TestFlight build for QA.

## Goals

1. Verify whether the current iOS app is broken because it still depends on
   `ffci.fiveq.dev`
2. Update iOS configuration and code paths to use the correct live production
   domain/API
3. Get iOS building and running locally with the production-backed setup
4. Upload a working iOS build to TestFlight for review

## Acceptance Criteria

- [ ] Current iOS app behavior is verified against the live production
      environment, with any breakages documented
- [ ] Required API/base URL/domain references for iOS no longer depend on
      `ffci.fiveq.dev`
- [ ] iOS app builds and runs locally against the correct production-backed
      configuration
- [ ] Core app content loads successfully in local iOS testing
- [ ] A new iOS build is uploaded to TestFlight for QA

## Notes

- Confirm whether the mobile API moved to the new domain or still lives at a
  separate endpoint
- Check for hardcoded domain references in API client code, HTML rendering, and
  any in-app browser/web view logic
- Reuse any existing iOS configuration work where possible instead of adding
  one-off production overrides

## Progress

- 2026-03-18: Verified `https://firefightersforchrist.org/mobile-api` responds
  successfully while `https://ffci.fiveq.dev/mobile-api` times out
- 2026-03-18: Updated iOS app domain handling to use the production host for API
  requests, WebView first-party routing, and homepage logo URL resolution
- 2026-03-18: User manually verified the simulator build passes local smoke
  testing; remaining work is TestFlight deployment
- 2026-03-18: Moved to `qa` for review of the verified app-side fix before the
  TestFlight follow-up is completed

## References

- Live site: `https://firefightersforchrist.org/`
- Old site/domain: `https://ffci.fiveq.dev/`
- Prior iOS config ticket: `tickets/229-ios-multi-site-config-system.md`
- Prior TestFlight setup ticket: `tickets/240-setup-testflight-and-invite-testers.md`
- Likely iOS entry point: `ios-mip-app/FFCI/API/MipApiClient.swift`
