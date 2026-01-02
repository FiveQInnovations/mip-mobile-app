---
status: backlog
area: rn-mip-app
created: 2026-01-20
---

# Link Apple Account with EAS

## Context
During EAS build setup, EAS prompts to optionally link Apple account credentials. This allows EAS to automatically generate and validate all necessary iOS build credentials (certificates, provisioning profiles, etc.) rather than requiring manual configuration.

**Current State:**
- EAS build can proceed without Apple account linking
- Without Apple account access, missing values must be provided manually
- Only minimal validation can be performed without Apple account credentials

**Benefits of Linking:**
- Automatic generation of all iOS build credentials
- Full validation of credentials
- Simplified iOS build process
- Reduced manual configuration overhead

## Tasks
- [ ] Link Apple account credentials with EAS
- [ ] Verify automatic credential generation works
- [ ] Test iOS build with linked credentials
- [ ] Document the linking process

## Notes

### EAS Prompt (2026-01-20)
When running `eas build --profile development --platform ios`, EAS prompts:
> If you provide your Apple account credentials we will be able to generate all necessary build credentials and fully validate them.
> This is optional, but without Apple account access you will need to provide all the missing values manually and we can only run minimal validation on them.

**Decision:** Defer Apple account linking to a future task to unblock initial build testing.

