---
status: done
area: wsp-mobile
phase: core
created: 2026-01-20
---

# Homepage Configuration in Kirby Panel

## Context

Currently, the homepage Quick Tasks and Featured sections are hardcoded in `HomeScreen.tsx` (see ticket 064). Example:

```typescript
{
  key: 'about-us',
  label: 'About Us',
  description: 'Learn about the history of the FFC Ministry!',
  imageUrl: 'https://picsum.photos/seed/about/800/450', 
  onPress: () => handleNavigate('About', undefined, 'about-uuid-placeholder'),
}
```

To allow clients to customize their homepage content without code changes, we need to add configuration options in the Kirby Panel via the `wsp-mobile` plugin.

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

- [x] Test configuration in Kirby Panel (add/edit/remove/reorder items) - ✅ Configured "Get Involved" page in Quick Tasks
- [x] Test API returns correct homepage configuration data - ✅ Verified commit `810dcccc` in ws-ffci repo
- [x] Test mobile app displays configured content correctly - ✅ "Get Involved" Quick Task displaying correctly in app
- [ ] Test fallback behavior when configuration is empty
- [ ] Test both in-app navigation and external URL navigation
- [ ] Update Maestro tests if needed for new dynamic content

## Related

- **Ticket 064**: Implement Card Component Layout on Homepage (prerequisite - done)
- `wsp-mobile/blueprints/tabs/mobile.yml` - Mobile Settings blueprint
- `wsp-mobile/lib/site.php` - Site API implementation
- `rn-mip-app/components/HomeScreen.tsx` - Homepage component
- `rn-mip-app/lib/api.ts` - API client and types

---

## Scouting Notes (2026-01-10)

### Current Blueprint Structure (`wsp-mobile/blueprints/tabs/mobile.yml`)

The existing `mobileMainMenu` structure field provides the exact pattern to follow:

```yaml
mobileMainMenu:
  label: "Mobile Main Menu"
  type: structure
  sortable: true
  fields:
    page:
      type: pages
      label: Main Mobile Menu
      multiple: false
    label:
      type: text
      label: Label
    icon:
      type: files
      multiple: false
      search: true
```

New fields should be added after line 57 (after `mobileLogo`).

### Recommended Blueprint for Quick Tasks

Admin selects a page → API pulls title/description/cover from page by default. Optional override fields allow customization.

```yaml
mobileHomepageQuickTasks:
  label: "Homepage Quick Tasks"
  type: structure
  sortable: true
  fields:
    page:
      type: pages
      label: Page to Feature
      multiple: false
      required: true
    label:
      type: text
      label: Custom Label (optional)
      help: "Leave blank to use page title"
    description:
      type: text
      label: Custom Description (optional)
      help: "Leave blank to use page description"
    image:
      type: files
      label: Custom Image (optional)
      help: "Leave blank to use page cover image"
      multiple: false
      search: true
    external_url:
      type: url
      label: External URL (instead of page)
      help: "If provided, opens in browser instead of navigating to page"
```

### Recommended Blueprint for Featured Items

```yaml
mobileHomepageFeatured:
  label: "Homepage Featured Items"
  type: structure
  sortable: true
  fields:
    page:
      type: pages
      label: Page to Feature
      multiple: false
      required: true
    title:
      type: text
      label: Custom Title (optional)
      help: "Leave blank to use page title"
    description:
      type: text
      label: Custom Description (optional)
      help: "Leave blank to use page description"
    image:
      type: files
      label: Custom Image (optional)
      help: "Leave blank to use page cover image"
      multiple: false
      search: true
    badge_text:
      type: text
      label: Badge Text (optional)
      help: "E.g., 'Featured', 'New', 'Popular'"
    external_url:
      type: url
      label: External URL (instead of page)
      help: "If provided, opens in browser instead of navigating to page"
```

### API Implementation (`wsp-mobile/lib/site.php`)

Add these helper methods to `SiteApi` class (after `get_site_logo`):

```php
private function get_homepage_quick_tasks($site) {
    $tasks = $site->mobileHomepageQuickTasks();
    if (!$tasks || $tasks->isEmpty()) {
        return [];
    }
    return $tasks->toStructure()->map(function ($item) {
        $page = $item->page()->toPages()->first();
        
        // Custom image, or fall back to page cover
        $imageFile = $item->image()->toFile();
        $imageUrl = null;
        if ($imageFile && $imageFile->exists()) {
            $imageUrl = $imageFile->toCDNFile()->url();
        } elseif ($page && $page->cover()->isNotEmpty()) {
            $coverFile = $page->cover()->toFile();
            if ($coverFile && $coverFile->exists()) {
                $imageUrl = $coverFile->toCDNFile()->url();
            }
        }
        
        return [
            "uuid" => $page ? $page->uuid()->id() : null,
            "label" => $item->label()->value() ?: ($page ? $page->title()->value() : ''),
            "description" => $item->description()->value() ?: ($page ? $page->description()->value() : ''),
            "image_url" => $imageUrl,
            "external_url" => $item->external_url()->value() ?: null,
        ];
    })->filter(fn($item) => $item['uuid'] || $item['external_url'])->data();
}

private function get_homepage_featured($site) {
    $featured = $site->mobileHomepageFeatured();
    if (!$featured || $featured->isEmpty()) {
        return [];
    }
    return $featured->toStructure()->map(function ($item) {
        $page = $item->page()->toPages()->first();
        
        // Custom image, or fall back to page cover
        $imageFile = $item->image()->toFile();
        $imageUrl = null;
        if ($imageFile && $imageFile->exists()) {
            $imageUrl = $imageFile->toCDNFile()->url();
        } elseif ($page && $page->cover()->isNotEmpty()) {
            $coverFile = $page->cover()->toFile();
            if ($coverFile && $coverFile->exists()) {
                $imageUrl = $coverFile->toCDNFile()->url();
            }
        }
        
        return [
            "uuid" => $page ? $page->uuid()->id() : null,
            "title" => $item->title()->value() ?: ($page ? $page->title()->value() : ''),
            "description" => $item->description()->value() ?: ($page ? $page->description()->value() : ''),
            "image_url" => $imageUrl,
            "badge_text" => $item->badge_text()->value() ?: null,
            "external_url" => $item->external_url()->value() ?: null,
        ];
    })->filter(fn($item) => $item['uuid'] || $item['external_url'])->data();
}
```

Then add to the `site()` return array:
```php
"homepage_quick_tasks" => $this->get_homepage_quick_tasks($site),
"homepage_featured" => $this->get_homepage_featured($site),
```

### Frontend Integration (`rn-mip-app/components/HomeScreen.tsx`)

**Current state:**
- `quickTasks` and `featuredItems` arrays are hardcoded with placeholder images
- `handleNavigate()` already supports UUID-based and external URL navigation
- `ContentCard` component accepts all needed props

**Integration approach:**
```typescript
// Use API data with fallback to hardcoded defaults
const quickTasksFromApi = site_data.homepage_quick_tasks || [];
const quickTasks = quickTasksFromApi.length > 0 
  ? quickTasksFromApi.map((item, idx) => ({
      key: `api-quick-${idx}`,
      label: item.label,
      description: item.description,
      imageUrl: item.image_url,
      onPress: () => item.external_url 
        ? Linking.openURL(item.external_url)
        : handleNavigate('', undefined, item.uuid),
    }))
  : DEFAULT_QUICK_TASKS;
```

### Test UUIDs for FFCI Site

| Page | UUID |
|------|------|
| About | `xhZj4ejQ65bRhrJg` |
| What We Believe | `fZdDBgMUDK3ZiRID` |
| Chaplain Resources | `PCLlwORLKbMnLPtN` |
| Events | `6ffa8qmIpJHM0C3r` |
| Get Involved | `3e56Ag4tc8SfnGAv` |

---

## Progress Notes

### 2026-01-20 - Initial Testing ✅

- **Kirby Panel Configuration**: Successfully configured "Get Involved" page (`3e56Ag4tc8SfnGAv`) as first Quick Task in Mobile Settings
- **Backend Verification**: Confirmed configuration saved to `content/site.txt` in commit `810dcccc` (ws-ffci repo)
- **Mobile App Display**: ✅ **VERIFIED** - "Get Involved" Quick Task is displaying correctly in the mobile app with page title, description, and cover image
- **Next Steps**: Continue testing with additional Quick Tasks and Featured items