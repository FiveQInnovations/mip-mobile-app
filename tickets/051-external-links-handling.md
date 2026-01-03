---
status: in-progress
area: rn-mip-app
phase: core
created: 2026-01-03
researched: 2026-01-03
---

# External Links Handling

## Problem

External links in HTML content don't open when tapped. The Resources page crashes before links can even be tested.

## Root Cause (Confirmed)

**Two separate issues identified:**

### Issue 1: Page Crash

The API returns HTML with `<picture>` elements containing `<source>` children:

```html
<a class="_image-link" href="https://harvest.org/...">
  <figure>
    <div>
      <picture>
        <source srcset="..." media="..." type="image/webp">
        <source srcset="..." media="..." type="image/webp">
        <img src="..." alt="...">
      </picture>
    </div>
  </figure>
</a>
```

The `react-native-render-html` library doesn't handle `<source>` elements. When processing the complex nested structure (`<a>` → `<figure>` → `<div>` → `<picture>`), the library's internal code crashes with `Cannot read property 'type' of undefined` at `getNativePropsForTNode.ts:52`.

### Issue 2: Touch Events Not Firing

The current `a` renderer wraps links in `TouchableOpacity`:

```tsx
<TouchableOpacity onPress={() => Linking.openURL(href)}>
  <TDefaultRenderer {...restProps} tnode={tnode} />
</TouchableOpacity>
```

When content inside is deeply nested HTML, touch events don't propagate correctly through the React Native view hierarchy.

## Solution

```tsx
<RenderHTML
  contentWidth={width - 32}
  source={source}
  ignoredDomTags={['source']}  // Fix crash - source has no visual representation
  renderersProps={{
    a: {
      onPress: (event, href) => {
        // Handle all link navigation here
        const uuid = extractUuidFromUrl(href);
        if (uuid) {
          onNavigate ? onNavigate(uuid) : router.push(`/page/${uuid}`);
        } else if (!isInternalLink(href)) {
          Linking.openURL(href);
        }
      }
    }
  }}
  renderers={renderers}  // Keep img/picture/figure, REMOVE 'a' renderer
/>
```

**Changes required:**
1. Add `ignoredDomTags={['source']}` to `RenderHTML` component
2. Add `renderersProps.a.onPress` callback for link handling
3. Remove or simplify the custom `a` renderer (no more `TouchableOpacity` wrapping)

## Tasks

- [x] Identify root cause of crash
- [x] Identify root cause of links not working
- [ ] Add `ignoredDomTags={['source']}` to RenderHTML
- [ ] Implement `renderersProps.a.onPress` for link handling
- [ ] Remove custom `a` renderer TouchableOpacity wrapping
- [ ] Test external links open in browser
- [ ] Test internal `/page/{uuid}` links navigate in-app
- [ ] Test on iOS and Android

## Related

- **Ticket 048** (done): Fixed `<picture>` element rendering for images
- **Ticket 052**: Internal links URL mapping (depends on this fix)
- `rn-mip-app/components/HTMLContentRenderer.tsx`

---

## Working Notes

### API Response Analysis (2026-01-03)

Fetched actual HTML from mobile API to understand structure:

```bash
curl -H "X-API-Key: ..." -H "Authorization: Basic ..." \
  "https://ffci.fiveq.dev/mobile-api/page/uezb3178BtP3oGuU"
```

**Key findings from HTML:**

1. **External links exist in two forms:**
   - Image links: `<a class="_image-link">` wrapping `<figure>` → `<picture>` → `<img>`
   - Button links: `<a class="_button-priority">` containing `<span>text</span>`

2. **Complex nesting causes issues:**
   ```
   <a href="https://harvest.org/...">
     └─ <figure>
         └─ <div>
             └─ <picture>
                 ├─ <source> (4x)
                 └─ <img>
   ```

3. **`<source>` elements are void/self-closing HTML tags** with no visual representation in React Native. The library attempts to process them, causing crashes.

### Previous Debugging Attempts

1. **Defensive tnode check** - Added null check before TDefaultRenderer call. Crash still occurred because issue is in nested rendering, not the `a` renderer's direct tnode.

2. **Props destructuring changes** - Tried various ways to pass props to TDefaultRenderer. No effect.

3. **Console logging** - Unable to see logs because page crashes before rendering completes.

### Control Test Results

- ✅ **Donate button works** - Uses `Linking.openURL()` directly in HomeScreen, bypasses HTMLContentRenderer
- ❌ **"Find Out How" link** - Crashes page
- ❌ **"BibleGateway.com" link** - Crashes page

### Library Documentation

From `react-native-render-html` docs:
- `ignoredDomTags` - Array of tag names to skip during parsing
- `renderersProps.a.onPress` - Callback for anchor press events (recommended approach)
- Custom renderers with `TDefaultRenderer` should handle all child rendering

### Environment

- React Native: 0.81.5
- Expo SDK: 54.0.0
- react-native-render-html: ^6.3.4
- Platform: iOS Simulator (iPhone 16 Plus)

### Error Details

```
Error: Cannot read property 'type' of undefined
Location: getNativePropsForTNode.ts:52:11
Stack: TDefaultRenderer → renderBlockContent → View → AnimatedComponent
```

### HTML Block Rendering Chain

1. **Kirby CMS** stores images as blocks with crop data
2. **wsp-mobile plugin** calls `toBlocks()->toHTML()` 
3. **wsp-image plugin** generates responsive HTML with `<picture>`, `<source>`, `<img>`
4. **wsp-button plugin** generates `<a>` tags with `<span>` children
5. **Mobile app** receives this HTML but crashes on `<source>` elements
