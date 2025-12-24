# Internal Link Resolution Options

This document describes two approaches for making content links navigate within the Astro app instead of linking to the external Kirby site.

## Problem

Content pages (like About) contain HTML with links to other pages (like "Our Mission"). These links currently point to the Kirby site URLs (e.g., `https://example.com/about/our-mission`), causing users to leave the Astro app when clicking them.

The Astro app uses UUID-based routing (`/page/{uuid}`), so these URL-based links need to be resolved to their corresponding UUIDs.

---

## Option 3: Transform Links at API Level (Recommended First)

### Approach

Modify the Kirby plugin to rewrite internal links in `page_content` before sending the JSON response. The API already knows the URL-to-UUID mapping, so it can transform links inline.

### Where to Implement

**Kirby plugin:** `plugins/mobile-api/` (or wherever the mobile API plugin lives)

### Implementation Steps

1. **In the page endpoint response builder:**
   - Before returning `page_content`, scan the HTML for `<a>` tags
   - For each link, check if the href points to an internal page
   - If internal, look up the page's UUID and rewrite the href to `/page/{uuid}`

2. **Pseudo-code:**

```php
function transformInternalLinks(string $html, Site $site): string
{
    // Match all href attributes
    return preg_replace_callback(
        '/<a\s+([^>]*href=["\'])([^"\']+)(["\'][^>]*)>/i',
        function ($matches) use ($site) {
            $prefix = $matches[1];
            $href = $matches[2];
            $suffix = $matches[3];
            
            // Try to find a page matching this URL
            $page = $site->index()->findBy('url', $href);
            
            if ($page) {
                // Rewrite to Astro app route
                $newHref = '/page/' . $page->uuid();
                return '<a ' . $prefix . $newHref . $suffix . '>';
            }
            
            // Also check relative URLs
            if (str_starts_with($href, '/')) {
                $page = $site->find(ltrim($href, '/'));
                if ($page) {
                    $newHref = '/page/' . $page->uuid();
                    return '<a ' . $prefix . $newHref . $suffix . '>';
                }
            }
            
            // Not internal, return unchanged
            return $matches[0];
        },
        $html
    );
}
```

3. **Apply the transformation:**

```php
// In the page API response
$pageContent = $page->page_content()->kirbytext();
$pageContent = transformInternalLinks($pageContent, $site);

return [
    'page_type' => 'content',
    'title' => $page->title()->value(),
    'page_content' => $pageContent,
    // ... other fields
];
```

### Pros

- ✅ Server is source of truth
- ✅ No additional API requests (transformation happens during existing fetch)
- ✅ Minimal server overhead (string processing only)
- ✅ No changes needed in Astro app
- ✅ Links work immediately after page fetch

### Cons

- ⚠️ Requires Kirby plugin modification
- ⚠️ Need to handle edge cases (fragments, query params, etc.)

---

## Option 5: Return URL Mappings with Site Data

### Approach

Extend the `/mobile-api` response to include a mapping of all page URLs to their UUIDs. The Astro app uses this map for client-side link resolution.

### Where to Implement

**Kirby plugin:** Extend the site data endpoint  
**Astro app:** Extend `ContentView.astro` to use the mappings

### Implementation Steps

#### Kirby Plugin Changes

1. **Add `urlMappings` to the site data response:**

```php
// In /mobile-api endpoint
function getUrlMappings(Site $site): array
{
    $mappings = [];
    
    foreach ($site->index() as $page) {
        // Map full URL
        $mappings[$page->url()] = $page->uuid();
        
        // Map relative path
        $path = '/' . $page->uri();
        $mappings[$path] = $page->uuid();
    }
    
    return $mappings;
}

return [
    'menu' => $menu,
    'site_data' => $siteData,
    'url_mappings' => getUrlMappings($site),  // Add this
];
```

#### Astro App Changes

1. **Update the `SiteData` type in `api.ts`:**

```typescript
export interface SiteData {
  menu: MenuItem[];
  site_data: SiteMeta;
  url_mappings?: Record<string, string>;  // Add this
}
```

2. **Update `ContentView.astro` to use the mappings:**

```typescript
// In the client-side script, extend buildUrlMap()
function buildUrlMap() {
  if (urlToUuidMap) return urlToUuidMap;
  
  urlToUuidMap = new Map();
  
  if (window.__mipApi) {
    window.__mipApi.getSiteData().then((siteData) => {
      // Use url_mappings if available
      if (siteData.url_mappings) {
        Object.entries(siteData.url_mappings).forEach(([url, uuid]) => {
          urlToUuidMap!.set(url, uuid);
          // Also map just the path
          try {
            const parsed = new URL(url, window.location.origin);
            urlToUuidMap!.set(parsed.pathname, uuid);
          } catch {}
        });
      }
      
      // Also include menu items as before
      siteData.menu.forEach((item) => {
        if (item.page?.url && item.page?.uuid) {
          const url = new URL(item.page.url, window.location.origin);
          urlToUuidMap!.set(url.pathname, item.page.uuid);
          urlToUuidMap!.set(item.page.url, item.page.uuid);
        }
      });
    });
  }
  
  return urlToUuidMap;
}
```

### Pros

- ✅ Server is source of truth
- ✅ No per-click API requests (map is cached)
- ✅ Flexible — client can resolve any link
- ✅ Works even if Option 3 misses some links

### Cons

- ⚠️ Payload size grows with number of pages
- ⚠️ Requires changes in both Kirby plugin and Astro app
- ⚠️ Slight delay on first page load while map is fetched

---

## Recommendation

**Try Option 3 first** — it's simpler, keeps all logic server-side, and has zero overhead beyond the existing page fetch.

**Add Option 5 as a fallback** if:
- Some links aren't caught by Option 3 (e.g., dynamically generated links)
- You want belt-and-suspenders reliability
- You need the mapping for other features (e.g., search, sitemap)

Both options can coexist — Option 3 handles most cases at the API level, while Option 5 provides a client-side fallback for edge cases.

---

## Implementation Status

### ✅ Option 3: Transform Links at API Level — IMPLEMENTED

**Status**: Fully implemented and active

**Location**: `plugins/wsp-mobile/lib/pages.php`

**Implementation Details**:

The `transformInternalLinks()` method is implemented in the `PagesApi` class and is called automatically when processing page content:

```80:190:plugins/wsp-mobile/lib/pages.php
private function transformInternalLinks(string $html): string {
    $site = $this->kirby->site();
    $baseUrl = $this->kirby->url();
    
    // Match all <a> tags with href attributes
    $result = preg_replace_callback(
        '/<a\s+([^>]*href=["\'])([^"\']+)(["\'][^>]*)>/i',
        function ($matches) use ($site, $baseUrl) {
            // ... implementation handles:
            // - Fragment and query param preservation
            // - Domain checking (skips external links)
            // - Multiple matching strategies (URI, URL path, etc.)
            // - Rewrites to /page/{uuid} format
        },
        $html
    );
    
    return $result;
}
```

**Features**:
- ✅ Transforms links in both `content_data()` and `collection_item_data()` responses
- ✅ Preserves query parameters and fragments (`?param=value#anchor`)
- ✅ Checks domain to avoid transforming external links
- ✅ Multiple matching strategies: URI matching, URL path matching, and full site index search
- ✅ Skips non-HTTP links (mailto:, tel:, javascript:, anchor-only)
- ✅ Handles both absolute and relative URLs

**Usage**: Applied automatically to all `page_content` fields in API responses.

---

### ⚠️ Option 5: URL Mappings — PARTIALLY IMPLEMENTED

**Status**: Client-side code ready, server-side not implemented

**Client-Side Implementation**:

The Astro app has full support for `url_mappings`:

- ✅ TypeScript types defined in `src/lib/api.ts`:
```40:40:astro-prototype/src/lib/api.ts
  url_mappings?: Record<string, string>;
```

- ✅ `ContentView.astro` includes `buildUrlMap()` function that uses `url_mappings` if available:
```84:118:astro-prototype/src/components/ContentView.astro
  function buildUrlMap() {
    if (urlToUuidMap) return urlToUuidMap;
    
    urlToUuidMap = new Map();
    
    // Try to get site data from window (set by layout or API)
    if (window.__mipApi) {
      window.__mipApi.getSiteData().then((siteData: any) => {
        // Use url_mappings if available (Option 5)
        if (siteData.url_mappings) {
          Object.entries(siteData.url_mappings).forEach(([url, uuid]) => {
            urlToUuidMap!.set(url, uuid as string);
            // Also normalize and map path component
            try {
              const parsed = new URL(url, window.location.origin);
              urlToUuidMap!.set(parsed.pathname, uuid as string);
            } catch {
              // If URL parsing fails, just use as-is
            }
          });
        }
        
        // Also include menu items as before (for backward compatibility)
        if (siteData.menu) {
          siteData.menu.forEach((item: MenuItem) => {
            if (item.page?.url && item.page?.uuid) {
              // Normalize URL - remove domain, keep path
              const url = new URL(item.page.url, window.location.origin);
              const path = url.pathname;
              urlToUuidMap!.set(path, item.page.uuid);
              // Also map full URL
              urlToUuidMap!.set(item.page.url, item.page.uuid);
            }
          });
        }
      }).catch(() => {
```

**Server-Side Status**: 
- ❌ `url_mappings` is **not** currently returned by the `/mobile-api` endpoint
- The API endpoint in `plugins/wsp-mobile/index.php` only returns `menu` and `site_data`
- To enable Option 5, add `url_mappings` to the API response (see Option 5 implementation steps above)

**Current Fallback**: The client-side code currently builds the URL map from menu items only, which provides partial coverage for links that weren't transformed by Option 3.

---

### Client-Side Link Processing

**Status**: Implemented as additional safety layer

**Location**: `astro-prototype/src/components/ContentView.astro`

The Astro app includes client-side link processing that:

1. **Marks internal links** with `data-internal-link="true"` attribute
2. **Preserves original href** in `data-original-href` attribute
3. **Handles clicks** on internal links that weren't transformed by the server:
   - Checks if link is already in `/page/{uuid}` format (transformed by server) → allows normal navigation
   - Otherwise, attempts client-side resolution using the URL map
   - Falls back to original URL if resolution fails

```162:228:astro-prototype/src/components/ContentView.astro
  // Handle internal link clicks
  document.addEventListener('click', (e) => {
    const link = (e.target as HTMLElement).closest('a[data-internal-link="true"]') as HTMLAnchorElement;
    if (!link) return;
    
    const href = link.getAttribute('href') || '';
    
    // If link is already in /page/{uuid} format (transformed by server), let it navigate normally
    if (href.startsWith('/page/') && /^\/page\/[a-zA-Z0-9]+/.test(href)) {
      // Already transformed - allow normal navigation
      return;
    }
    
    // Otherwise, handle client-side resolution
    e.preventDefault();
    const originalHref = link.getAttribute('data-original-href') || href;
    
    if (!originalHref) return;
    
    const map = buildUrlMap();
    
    // Try to find UUID in map
    let uuid: string | undefined;
    
    // Try exact match first
    uuid = map.get(originalHref);
    
    // Try normalized path
    if (!uuid) {
      try {
        const url = new URL(originalHref, window.location.origin);
        uuid = map.get(url.pathname);
      } catch {
        // If URL parsing fails, try as-is
        uuid = map.get(originalHref);
      }
    }
    
    // Try relative path match
    if (!uuid && originalHref.startsWith('/')) {
      uuid = map.get(originalHref);
    }
    
    if (uuid) {
      // Navigate to page using UUID
      window.location.href = `/page/${uuid}`;
      return;
    }
    
    // Fallback: Try to extract UUID from URL pattern
    // Some URLs might have UUIDs embedded
    const uuidPattern = /[a-zA-Z0-9]{16}/;
    const uuidMatch = originalHref.match(uuidPattern);
    
    if (uuidMatch) {
      window.location.href = `/page/${uuidMatch[0]}`;
      return;
    }
    
    // Last resort: navigate to original URL (might be a slug that needs API resolution)
    // For now, we'll navigate and let the server handle it
    if (originalHref.startsWith('/') || originalHref.startsWith('./') || originalHref.startsWith('../')) {
      window.location.href = originalHref;
    } else {
      // External or malformed - navigate anyway
      window.location.href = originalHref;
    }
  });
```

---

## Current Architecture

The implementation uses a **layered approach**:

1. **Primary**: Server-side transformation (Option 3) handles most links during API response
2. **Secondary**: Client-side processing marks remaining links and provides fallback resolution
3. **Tertiary**: URL map built from menu items provides coverage for links missed by server transformation

**Result**: Most internal links are transformed server-side and navigate directly. Links that weren't caught are handled client-side using menu data.

---

## Testing

After implementing either option:

1. Navigate to a content page with internal links (e.g., About)
2. Click a link that previously went to the external site
3. Verify it navigates within the Astro app to `/page/{uuid}`
4. Check that external links still open in new tabs with the ↗ indicator
