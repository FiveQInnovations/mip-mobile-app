# Mobile API Prototype Results

## Summary

The `wsp-mobile` plugin has been successfully installed and configured on ws-ffci-copy. The API endpoints are functional and returning data structures that will power the mobile app.

## Installation Status

✅ Plugin installed at `sites/ws-ffci-copy/site/plugins/wsp-mobile`  
✅ Mobile Settings tab added to site blueprint  
✅ Panel configuration completed (App Name, Logo, Menu, Homepage Type configured)

## Working Endpoints

### `/mobile-api` (GET)

**Status**: ✅ Working

**Response Structure** (Actual Response):
```json
{
  "menu": [
    {
      "label": "About",
      "page": {
        "uuid": "xhZj4ejQ65bRhrJg",
        "type": "default",
        "url": "https://ws-ffci-copy.ddev.site/about"
      }
    },
    {
      "label": "Chapters",
      "page": {
        "uuid": "pik8ysClOFGyllBY",
        "type": "default",
        "url": "https://ws-ffci-copy.ddev.site/chapters"
      }
    }
  ],
  "site_data": {
    "title": "Firefighters for Christ International",
    "social": [],
    "logo": "https://ffci-5q.b-cdn.net/image/logo-mobile.svg",
    "app_name": "FFCI"
  }
}
```

**Notes**:
- ✅ Menu items are returned with labels, UUIDs, and URLs
- ✅ `page.type` returns template name string (e.g., "default")
- ✅ Logo URL is returned correctly
- ✅ App name is returned correctly

### `/mobile-api/menu` (GET)

**Status**: ✅ Working

**Response Structure** (Actual Response):
```json
[
  {
    "label": "About",
    "page": {
        "uuid": "xhZj4ejQ65bRhrJg",
        "type": "default",
        "url": "https://ws-ffci-copy.ddev.site/about"
    }
  },
  {
    "label": "Chapters",
    "page": {
        "uuid": "pik8ysClOFGyllBY",
        "type": "default",
        "url": "https://ws-ffci-copy.ddev.site/chapters"
    }
  }
]
```

**Note**: Returns the same menu array as the main endpoint. The routing issue was resolved after DDEV restart.

### `/mobile-api/page/{uuid}` (GET)

**Status**: ✅ Working

**Actual Response Structure** (Content Page Example - About page):
```json
{
  "page_type": "content",
  "cover": null,
  "type": "default",
  "title": "About",
  "content": {
    "title": "About",
    "page_content": "[{\"attrs\":{...},\"columns\":[...]}]",
    "page_title": "Firefighters for Christ: About Us",
    "page_description": "..."
  },
  "page_content": "<html>...</html>",
  "children": []
}
```

**Notes**:
- ✅ Returns full page data including title, content, and rendered HTML
- ✅ `page_content` contains the rendered HTML from blocks
- ✅ `content.page_content` contains the raw block structure (JSON string)
- ✅ `page_type` is correctly set to "content" for regular content pages

- **Collection Page**:
  ```json
  {
    "page_type": "collection",
    "type": "video|audio",
    "title": "Collection Title",
    "cover": "https://...",
    "content": {...},
    "children": [
      {
        "uuid": "...",
        "type": "...",
        "url": "..."
      }
    ]
  }
  ```

- **Collection Item** (Video/Audio):
  ```json
  {
    "page_type": "collection-item",
    "type": "video|audio",
    "title": "Item Title",
    "cover": "https://...",
    "data": {
      "page_content": "<html>...</html>",
      "content": {...},
      "video": {
        "source": "url",
        "url": "https://..."
      }
    }
  }
  ```

### `/mobile-api/kql` (GET|POST)

**Status**: ⚠️ Needs KQL Plugin

This endpoint requires the `getkirby/kql` plugin to be installed. It provides a passthrough to KQL queries with caching.

**Note**: The mobile app spec indicates this will be the primary API method, but the structured endpoints above provide a simpler alternative for basic use cases.

## Data Gaps vs. Mobile App Specification

### Missing from Site Data Response

The `SiteApi::site()` method currently does NOT return:
- `mobileHomepageType` (content/collection/navigation)
- `mobileHomepageContent` (page UUID for content homepage)
- `mobileHomepageCollection` (page UUID for collection homepage)

**Recommendation**: Add these fields to `lib/site.php`:
```php
"homepage_type" => $site->mobileHomepageType()->value() ?: null,
"homepage_content" => $site->mobileHomepageContent()->toPage()?->uuid()->id(),
"homepage_collection" => $site->mobileHomepageCollection()->toPage()?->uuid()->id(),
```

### Missing from Menu Response

The menu response includes basic page info:
- ✅ `page.type` returns template name string (e.g., "default") - **Fixed**
- Icon URL not included (if icons are configured in Panel)

### Page Data Enhancements Needed

- **Video data**: Currently only handles `source: "url"` - may need YouTube/Vimeo embed support
- **Audio data**: `audio_data()` method is empty (TODO in code)
- **Children pagination**: No pagination support for collection children lists

## Next Steps

1. **Enhance Plugin**:
   - Add homepage fields (`mobileHomepageType`, `mobileHomepageContent`, `mobileHomepageCollection`) to site response
   - Add icon URL to menu items if configured
   - Implement audio data method
   - Add pagination support for collections

3. **Test Additional Scenarios**:
   - Test with collection pages (video/audio collections)
   - Test with collection items (video/audio items)
   - Test with pages that have children
   - Test with pages that have cover images

## Code Fixes Applied

1. ✅ Fixed PHP 8.2+ deprecation warnings by adding `private $kirby;` property declarations
2. ✅ Added null checks for missing configuration (logo, menu, app_name)
3. ✅ Fixed `Json` class reference in KQL endpoint (`\Kirby\Toolkit\Json`)
4. ✅ Reordered routes so more specific patterns come first
5. ✅ Fixed `page.type` returning `{}` in menu response (changed to `intendedTemplate()->name()`)
6. ✅ Fixed `page_type` being set to "collection-item" for regular content pages (changed to "content")

## Files Modified

- `plugins/wsp-mobile/lib/menu.php` - Added property declaration, error handling, and fixed `page.type` bug
- `plugins/wsp-mobile/lib/site.php` - Added property declaration and null checks
- `plugins/wsp-mobile/lib/pages.php` - Added property declaration and fixed `page_type` bug
- `plugins/wsp-mobile/index.php` - Fixed Json reference and route ordering
- `sites/ws-ffci-copy/site/plugins/wsp-mobile/lib/menu.php` - Fixed `page.type` bug (use `intendedTemplate()->name()`)
- `sites/ws-ffci-copy/site/plugins/wsp-mobile/lib/pages.php` - Fixed `page_type` bug (changed to "content")
- `sites/ws-ffci-copy/site/blueprints/site.yml` - Added mobile tab reference
