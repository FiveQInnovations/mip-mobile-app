# React Native Mobile App - TODO

This document tracks items that need to be revisited or improved in the mobile app.

## Images

### Current Status
- ✅ Fixed Redbox error for invalid image URLs (`about:///blank`)
- ✅ Added custom image renderer in `HTMLContentRenderer` that validates and filters invalid image sources
- ⚠️ Basic image rendering implemented but needs refinement

### Issues to Address

1. **Image Loading & Error Handling**
   - Currently invalid images are silently skipped (return `null`)
   - Should consider showing placeholder images or error indicators
   - Need to handle image loading states (loading spinner, error state)

2. **Image Sizing & Layout**
   - Current implementation uses fixed aspect ratio (16:9) for all images
   - Should respect image dimensions from HTML or use responsive sizing
   - Need to handle images of different aspect ratios properly
   - Consider using `onLoad` and `onError` handlers for better UX

3. **Image Performance**
   - No image caching strategy implemented
   - Should consider using `react-native-fast-image` or similar for better performance
   - Need to handle large images and optimize loading

4. **Image Sources**
   - Relative URLs are resolved against `apiBaseUrl`, but may need better handling
   - Should verify CDN URLs work correctly
   - Need to handle SVG images (currently may not render properly)

5. **Accessibility**
   - Missing `alt` text handling for images
   - Should add proper accessibility labels

### Related Files
- `components/HTMLContentRenderer.tsx` - Image renderer implementation
- `components/PageScreen.tsx` - Cover image rendering
- `components/TabScreen.tsx` - Cover image rendering
- `components/HomeScreen.tsx` - Logo image rendering

---

## Internal Links

### Current Status
- ✅ Basic internal link detection implemented
- ✅ Navigation to `/page/{uuid}` links works
- ⚠️ Other internal links need proper handling

### Issues to Address

1. **Internal Link Resolution**
   - Currently only handles `/page/{uuid}` format links
   - Need to map other internal URLs (e.g., `/about`, `/resources`) to their corresponding page UUIDs
   - Should handle relative links within the same site
   - Need to handle links to collection items, tabs, etc.

2. **Link Navigation**
   - Internal links that aren't `/page/{uuid}` currently just log to console
   - Should implement proper navigation for all internal link types
   - Need to handle deep linking scenarios

3. **Link Detection**
   - `isInternalLink()` function exists but may need refinement
   - Should verify domain matching works correctly for all scenarios
   - Need to handle edge cases (query params, fragments, etc.)

4. **User Experience**
   - Should provide visual feedback when links are tapped
   - Need to handle link errors gracefully
   - Consider adding link preview or context

### Related Files
- `components/HTMLContentRenderer.tsx` - Link renderer implementation (`a` tag handler)
- `lib/api.ts` - May need API endpoint to resolve internal URLs to UUIDs

---

## Notes

- Both issues were identified while fixing the Redbox error for `about:///blank` image URLs
- The current implementations are functional but need refinement for production use
- Consider creating separate components for image and link handling to improve maintainability

