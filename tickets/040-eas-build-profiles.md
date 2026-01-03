---
status: backlog
area: rn-mip-app
created: 2026-01-02
---

# Set Up EAS Build Profiles for Multiple Sites

## Context
The spec requires separate EAS build profiles for each site. This allows building separate app binaries from the same codebase, each with its own configuration, branding, and app store listing.

## Tasks
- [ ] Create `ffci` build profile in eas.json
- [ ] Create `c4i` build profile in eas.json
- [ ] Configure build script to inject site config at build time
- [ ] Test build command: `eas build --profile ffci --platform all`
- [ ] Test build command: `eas build --profile c4i --platform all`
- [ ] Document build process in README

## Notes
- Per spec: "Each site = separate EAS build profile"
- Build command specifies target site: `eas build --profile ffci --platform all`
- Produces separate app binaries per site (required for separate App Store listings)
