---
status: done
area: rn-mip-app
phase: bug
created: 2026-01-21
---

# Content Page Images Not Rendering

## Problem
Images are not appearing in the mobile app on content pages, even though they appear correctly in the browser version of the site.

## Testing Performed (2026-01-21)

**Browser Version (https://ffci.fiveq.dev/resources):**
- ✅ Shows multiple images:
  - Black and white image of firemen with hoses (top of page)
  - "Do You Know God?" - silhouette image
  - "Daily Verse & Bible Search" - man reading Bible image
  - "FFC Media Library" - computer screenshot image
  - "FFC Mobile App" - fireman with phone image

**Mobile App (iOS Simulator):**
- ❌ Shows NO images on Resources page
- ✅ HTML content is rendering (text, headings, links all visible)
- ✅ Confirmed `HTMLContentRenderer` component has image rendering support (lines 64-84)
- ✅ View hierarchy shows no `<img>` elements present in rendered HTML

---

## Root Cause Analysis (2026-01-03)

### ✅ CONFIRMED: API returns images with correct absolute URLs

The mobile API **does return image tags** with full CDN URLs. Example from `/mobile-api/page/uezb3178BtP3oGuU`:

```html
<figure class="_image w-full flex flex-col items-center">
    <div class="w-full">
        <picture>
            <source srcset="https://ffci-5q.b-cdn.net/image/adobestock_739818183.jpeg?crop=..." media="(min-width: 1280px)" type="image/webp">
            <source srcset="..." media="(min-width: 1024px)" type="image/webp">
            <source srcset="..." media="(min-width: 768px)" type="image/webp">
            <source srcset="..." media="(min-width: 2px)" type="image/webp">
            <img loading='lazy' src='https://ffci-5q.b-cdn.net/image/adobestock_739818183.jpeg?crop=...' srcset="..." width="800" height="448" alt="silhouette of a man kneeling in front of a cross">
        </picture>
    </div>
</figure>
```

### ❌ ROOT CAUSE: `<picture>` element not supported by react-native-render-html

The `react-native-render-html` library does not natively render `<picture>` elements. When it encounters a `<picture>` tag:
1. It likely treats it as an unknown/ignored element
2. The nested `<img>` tag inside is never reached by the custom `img` renderer
3. This results in images being silently dropped from the output

**Key Evidence:**
- The `HTMLContentRenderer.tsx` has a custom renderer for `img` (lines 64-84)
- No custom renderers exist for `picture`, `source`, or `figure`
- The API returns all images wrapped in `<picture>` elements (from `wsp-image` plugin)

### Image Block Rendering Chain

1. **Kirby content** stores images as blocks: `{"type":"image", "content":{"image":[{"id":"file.jpg", "crop":{...}}]}}`
2. **wsp-mobile plugin** (`lib/pages.php`) calls `$page->content()->page_content()->toBlocks()->toHTML()`
3. **wsp-image plugin** (`snippet.php`) generates responsive HTML with `<picture>`, `<source>`, and `<img>` elements
4. **Mobile app** receives this HTML but can't render `<picture>` elements

### Background Blocks Also Affected

The `background` block type (used for hero images) also generates `<picture>` elements via `wsp-background/snippet.php`. These background images will also not render.

---

## Solution Options

### Option A: Client-side fix (Recommended - Fastest)

Add custom renderers for `picture` and `figure` in `HTMLContentRenderer.tsx`:

```tsx
const renderers = {
  picture: ({ TDefaultRenderer, tnode, ...props }: any) => {
    // Find the <img> child inside <picture> and render it
    const imgNode = tnode.children?.find((child: any) => child.tagName === 'img');
    if (imgNode) {
      const src = imgNode.attributes?.src;
      const resolvedSrc = resolveImageSource(src);
      if (resolvedSrc) {
        return (
          <Image
            source={{ uri: resolvedSrc }}
            style={[styles.htmlImage, { width: imageWidth }]}
            resizeMode="contain"
          />
        );
      }
    }
    return null;
  },
  figure: ({ TDefaultRenderer, ...props }: any) => {
    // Render figure contents (will now properly handle picture inside)
    return <TDefaultRenderer {...props} />;
  },
  // ... existing img and a renderers
};
```

**Pros:** No API changes needed, quick to implement
**Cons:** Responsive srcset is ignored (uses only `src` attribute)

### Option B: API-side fix (More robust)

Create a mobile-specific block snippet that outputs simple `<img>` tags instead of `<picture>` elements. Add a new file like `wsp-mobile/snippets/blocks/image.php`:

```php
<?php
// Simple image output for mobile API
$image = $block->image()->toCropImage();
if ($image) {
    $src = $image->hasCrop() ? $image->getCropURL() : $image->url();
    $alt = htmlentities($block->alt()->or($image->alt())->value());
    echo "<img src=\"{$src}\" alt=\"{$alt}\" width=\"{$image->width()}\" height=\"{$image->height()}\" />";
}
?>
```

Then modify `pages.php` to use these snippets when generating HTML for mobile.

**Pros:** Cleaner HTML, smaller payload, better control
**Cons:** Requires API changes, need to handle all block types

### Option C: HTML preprocessing (Middle ground)

Pre-process HTML on the client before passing to RenderHTML:

```tsx
function simplifyPictureElements(html: string): string {
  // Use regex or DOM parser to extract <img> from <picture> elements
  return html.replace(
    /<picture[^>]*>[\s\S]*?<img\s+([^>]+)>[\s\S]*?<\/picture>/gi,
    '<img $1>'
  );
}
```

**Pros:** Works with existing API, can be done in one place
**Cons:** Regex parsing is fragile, may miss edge cases

---

## Investigation Steps (Completed)

- [x] Inspect API response to see if HTML includes image tags - **YES, images are present**
- [x] Check if image URLs are absolute vs relative - **Absolute CDN URLs confirmed**
- [x] Verify image rendering code handles all image tag variations - **`<picture>` not handled**
- [ ] Test image loading with network debugging enabled
- [ ] Check iOS network security settings (NSAppTransportSecurity)
- [x] Compare HTML content from browser vs mobile API endpoint - **Same HTML structure**

## Related Files

### Mobile App
- `rn-mip-app/components/HTMLContentRenderer.tsx` - Image rendering component (needs `picture` renderer)
- `rn-mip-app/lib/api.ts` - API client that fetches page content
- `rn-mip-app/app.json` - iOS network security configuration

### Kirby API Plugin
- `wsp-mobile/lib/pages.php` - Calls `toBlocks()->toHTML()` to generate page_content
- `wsp-mobile/index.php` - Routes for mobile API endpoints

### Block Rendering (Source of `<picture>` elements)
- `wsp-image/snippet.php` - Image block template (generates `<picture>` with `<source>` and `<img>`)
- `wsp-image/index.php` - Registers `blocks/image` snippet
- `wsp-background/snippet.php` - Background block template (also uses `<picture>`)

## Implementation (2026-01-03)

**Solution Implemented:** Option A - Client-side custom renderers

Added custom renderers for `picture` and `figure` elements in `HTMLContentRenderer.tsx`:
- `picture` renderer: Recursively finds nested `<img>` elements and renders them using the existing image rendering logic
- `figure` renderer: Passes through to default rendering to allow `picture` elements inside to be processed

**Changes Made:**
- Added `picture` renderer that extracts `<img>` from `<picture>` elements
- Added `figure` renderer for proper handling of figure wrappers
- Moved `imageWidth` calculation outside renderers for reuse

**Testing Completed (2026-01-03):**

✅ **All images verified rendering on Resources page:**
- Black and white image of firemen with hoses (top of page) - ✅ Rendered
- "Do You Know God?" - silhouette image - ✅ Rendered  
- "Daily Verse & Bible Search" - man reading Bible image - ✅ Rendered
- "FFC Media Library" - computer screenshot image - ✅ Rendered
- "FFC Mobile App" - fireman with phone image - ✅ Rendered

**Test Method:**
- Built iOS Release app and installed on iPhone 16 Plus simulator
- Navigated to Resources tab using Maestro MCP tools
- Verified all 5 images mentioned in ticket are visible and rendering correctly
- Screenshot saved: `rn-mip-app/resources-page-images-verified-ios.png`

**Status:** ✅ **FIXED** - All images now render correctly. The custom `picture` and `figure` renderers successfully extract and display images from `<picture>` elements.

## Notes

- Text content renders correctly, so HTML parsing is working
- Image rendering code exists but `<picture>` wrapper prevents `<img>` from being found
- Issue affects all content pages, not just Resources page
- CDN is `ffci-5q.b-cdn.net` (BunnyCDN) - images are already optimized/cropped server-side
