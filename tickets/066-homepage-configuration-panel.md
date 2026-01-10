---
status: backlog
area: wsp-mobile
phase: nice-to-have
created: 2026-01-20
---

# Homepage Configuration in Kirby Panel

## Context

Currently, the homepage Quick Tasks and Featured sections are hardcoded in `HomeScreen.tsx` (see ticket 064). To allow clients to customize their homepage content without code changes, we need to add configuration options in the Kirby Panel via the `wsp-mobile` plugin.

## Goals

1. **Quick Tasks Configuration**: Allow clients to configure which pages/links appear in the Quick Tasks horizontal scroll section
2. **Featured Section Configuration**: Allow clients to configure which items appear in the Featured section
3. **Panel Integration**: Add these configuration options to the existing Mobile Settings tab in Kirby Panel
4. **API Integration**: Expose homepage configuration through the mobile API so the React Native app can consume it

## Tasks

### Backend (wsp-mobile)

- [ ] Add `mobileHomepageQuickTasks` structure field to `blueprints/tabs/mobile.yml`
  - Fields: page (pages field), label (text), description (text), image (files), external_url (url, optional)
  - Sortable to allow reordering
- [ ] Add `mobileHomepageFeatured` structure field to `blueprints/tabs/mobile.yml`
  - Fields: page (pages field), title (text), description (text), image (files), badge_text (text, optional), external_url (url, optional)
  - Sortable to allow reordering
- [ ] Update `lib/site.php` `SiteApi::site()` method to include homepage configuration in API response
  - Add `homepage_quick_tasks` array with page UUID, label, description, image URL, navigation type
  - Add `homepage_featured` array with page UUID, title, description, image URL, badge text, navigation type
- [ ] Handle both in-app navigation (page UUID) and external URLs
- [ ] Generate CDN URLs for images using `toCDNFile()->url()` pattern

### Frontend (rn-mip-app)

- [ ] Update `lib/api.ts` `SiteMeta` interface to include homepage configuration arrays
- [ ] Update `components/HomeScreen.tsx` to consume homepage configuration from `siteData` instead of hardcoded arrays
- [ ] Maintain backward compatibility: fallback to hardcoded values if configuration is empty
- [ ] Handle navigation logic for both page UUIDs and external URLs
- [ ] Test that configured images display correctly

### Testing

- [ ] Test configuration in Kirby Panel (add/edit/remove/reorder items)
- [ ] Test API returns correct homepage configuration data
- [ ] Test mobile app displays configured content correctly
- [ ] Test fallback behavior when configuration is empty
- [ ] Test both in-app navigation and external URL navigation
- [ ] Update Maestro tests if needed for new dynamic content

## Related

- **Ticket 064**: Implement Card Component Layout on Homepage (prerequisite - establishes card layout)
- `wsp-mobile/blueprints/tabs/mobile.yml` - Mobile Settings blueprint
- `wsp-mobile/lib/site.php` - Site API implementation
- `rn-mip-app/components/HomeScreen.tsx` - Homepage component
- `rn-mip-app/lib/api.ts` - API client and types

## Technical Notes

### Configuration Structure

The homepage configuration should support:
- **Page-based navigation**: Link to internal pages via UUID
- **External URLs**: Link to external websites
- **Images**: Upload custom images for each card
- **Metadata**: Labels, descriptions, badge text for featured items
- **Ordering**: Sortable structure fields to control display order

### API Response Format

```typescript
interface HomepageQuickTask {
  uuid?: string;           // Page UUID if in-app navigation
  label: string;
  description: string;
  image_url: string | null;
  external_url?: string;   // If provided, navigate externally instead of UUID
}

interface HomepageFeatured {
  uuid?: string;           // Page UUID if in-app navigation
  title: string;
  description: string;
  image_url: string | null;
  badge_text?: string;     // Optional badge (e.g., "Featured")
  external_url?: string;   // If provided, navigate externally instead of UUID
}

interface SiteMeta {
  // ... existing fields ...
  homepage_quick_tasks?: HomepageQuickTask[];
  homepage_featured?: HomepageFeatured[];
}
```

### Navigation Logic

- If `external_url` is provided, use `Linking.openURL()`
- If `uuid` is provided, check if it's a tab (use `onSwitchTab`) or push to stack (`router.push`)
- If neither is provided, skip the item (or show error in dev mode)
