---
status: backlog
area: android-mip-app
phase: nice-to-have
created: 2026-01-28
---

# Android Build Variants for Multi-Site Deployment

## Context

This ticket covers Phase 3 of the Android Multi-Site Configuration System. Phase 1 & 2 (configuration infrastructure and value extraction) are complete. This ticket implements the build variant system so that adding a new site requires only creating a new config.json and build flavor.

## Goals

1. Set up product flavors in `build.gradle.kts` for different sites
2. Each flavor gets its own `config.json` and `applicationId`
3. App name per flavor via resource qualifiers
4. Document the process for creating a new site config

## Implementation Approach

### Phase 3: Build Variants

- Set up product flavors in `build.gradle.kts` for different sites
- Each flavor gets its own `config.json` and `applicationId`
- App name per flavor via resource qualifiers

### Documentation

- Create step-by-step guide for adding a new site
- Document config.json structure and required fields
- Document build flavor setup process

## Acceptance Criteria

- [ ] Adding a new site requires only: new config.json + build flavor
- [ ] Document the process for creating a new site config
- [ ] Can build separate APKs for different sites from same codebase
- [ ] Each site has unique package name and app name

## Success Metrics

- Adding a hypothetical second site config takes < 30 minutes
- Documentation is clear and complete
- Build process is straightforward

## Notes

- Android product flavors: https://developer.android.com/build/build-variants
- Reference completed Phase 1 & 2 work in ticket 230
- Config structure already defined in ticket 230

## References

- Android MipApiClient: `android-mip-app/app/src/main/java/com/fiveq/ffci/api/MipApiClient.kt`
- Android Theme: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/theme/Theme.kt`
- Config infrastructure: `android-mip-app/app/src/main/java/com/fiveq/ffci/config/AppConfig.kt`
- Current config: `android-mip-app/app/src/main/assets/config.json`
