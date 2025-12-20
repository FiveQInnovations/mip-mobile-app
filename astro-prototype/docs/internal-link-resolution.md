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

## Testing

After implementing either option:

1. Navigate to a content page with internal links (e.g., About)
2. Click a link that previously went to the external site
3. Verify it navigates within the Astro app to `/page/{uuid}`
4. Check that external links still open in new tabs with the ↗ indicator
