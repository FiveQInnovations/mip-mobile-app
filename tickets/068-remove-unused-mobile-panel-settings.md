---
status: backlog
area: wsp-mobile
phase: core
created: 2026-01-20
---

# Remove Unused/Non-Functional Mobile Panel Settings

## Context

The Mobile Settings panel in Kirby currently includes several fields that are either non-functional or should not be configurable by clients:

1. **App Name** (`mobileAppName`) - Should not be client-configurable
2. **MobileHomepageType** (`mobileHomepageType`) - Already disabled, but still visible. Homepage type is automatically set to Action Hub.
3. **MobileHomepageContent** (`mobileHomepageContent`) - Already disabled, but still visible. Not functional with Action Hub layout.
4. **MobileHomepageCollection** (`mobileHomepageCollection`) - Related to `mobileHomepageType`, also disabled and not functional.

The **Site Logo** (`mobileLogo`) setting should be kept as it is functional and needed.

## Goals

1. Remove non-functional and unwanted settings from the Mobile Settings panel
2. Clean up the panel UI to only show settings that clients should configure
3. Update API to handle removal of these fields gracefully
4. Ensure Site Logo functionality remains intact

## Tasks

### Backend (wsp-mobile)

- [ ] Remove `mobileAppName` field from `blueprints/tabs/mobile.yml`
- [ ] Remove `mobileHomepageType` field from `blueprints/tabs/mobile.yml`
- [ ] Remove `mobileHomepageContent` field from `blueprints/tabs/mobile.yml`
- [ ] Remove `mobileHomepageCollection` field from `blueprints/tabs/mobile.yml` (related to homepageType)
- [ ] Update `lib/site.php` `SiteApi::site()` method to remove references to:
  - `mobileAppName()` → remove `app_name` from API response
  - `mobileHomepageType()` → remove `homepage_type` from API response
  - `mobileHomepageContent()` → remove `homepage_content` from API response
  - `mobileHomepageCollection()` → remove `homepage_collection` from API response
- [ ] Verify `mobileLogo` field remains functional and is still included in API response
- [ ] Test that existing sites with these fields in `content/site.txt` don't break (fields will be ignored)

### Frontend (rn-mip-app)

- [ ] Check `lib/api.ts` `SiteMeta` interface for `app_name`, `homepage_type`, `homepage_content`, `homepage_collection` fields
  - Remove these fields from interface if they exist
  - Ensure no code depends on these fields
- [ ] Check `lib/config.ts` for any references to `homepageType` from API
  - Verify app uses config file or hardcoded values instead
- [ ] Check `components/HomeScreen.tsx` and other components for any usage of these API fields
  - Remove or update any dependencies
- [ ] Verify app still works correctly without these fields

### Testing

- [ ] Verify Mobile Settings panel no longer shows removed fields
- [ ] Verify Site Logo field still appears and functions correctly
- [ ] Test API response no longer includes removed fields
- [ ] Test mobile app still loads and functions correctly
- [ ] Test with existing site that has these fields in `content/site.txt` (should ignore gracefully)

## Related

- `wsp-mobile/blueprints/tabs/mobile.yml` - Mobile Settings blueprint (lines 10-35)
- `wsp-mobile/lib/site.php` - Site API implementation (lines 97-120)
- `rn-mip-app/lib/api.ts` - API client and types
- **Ticket 066**: Homepage Configuration Panel (related - Action Hub is now standard)

## Notes

- These fields are currently visible in the panel but either disabled or should not be client-configurable
- The homepage is now standardized to use Action Hub layout (see ticket 066)
- App name should be determined by site configuration or branding, not client input
- Site Logo is functional and should remain as it's needed for app branding
