---
status: backlog
area: android-mip-app
phase: nice-to-have
created: 2026-01-24
---

# Improve PDF Download List Styling

## Context

The Chaplain Resources page (and similar pages with PDF download links) has several design issues that make the content harder to scan and visually cluttered. The current rendering shows download icons, link titles, and "(pdf)" labels on separate lines with redundant information.

## Goals

1. Clean up the visual presentation of PDF download lists
2. Reduce redundancy (icon AND "(pdf)" label is repetitive)
3. Improve scannability with better list structure
4. Fix quote mark rendering issues

## Acceptance Criteria

- PDF links are displayed in a clean, single-row format
- Either remove download icons OR remove "(pdf)" labels (not both)
- If "(pdf)" is kept, display as inline badge after title
- Consistent spacing between list items
- Quote marks render correctly (no stray marks on separate lines)
- Tap target is clear and encompasses the entire row

## Current Issues

1. **Redundant indicators**: Download icon + "(pdf)" label for each item
2. **Vertical sprawl**: Icon, title, and label on separate lines
3. **Visual noise**: Red icons and labels compete with link titles
4. **Quote bug**: Stray quote mark appearing on its own line
5. **Unclear interaction**: Not obvious what to tap

## Technical Notes

- PDF links come from Kirby CMS content
- Styling is controlled via CSS in `HtmlContent.kt` WebView
- May need to target specific HTML patterns (e.g., `<a>` tags with PDF hrefs)
- Consider using CSS to hide redundant elements or restructure visually

## References

- `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`
- Screenshot: Chaplain Resources page showing current styling issues
- Related: ticket 097 (internal page styling)

---

## Research Findings (Scouted)

### Current Implementation Analysis

The PDF download list is rendered using the **wsp-downloads** Kirby plugin, which transforms the content into HTML that's displayed in the Android WebView. The HTML structure originates from:

**Backend (Kirby CMS):**
- Content file: `/Users/anthony/mip/sites/ws-ffci/content/4_get-involved/3_ffc-chaplain-program/1_chaplain-resources/default.txt`
- Rendering snippet: `/Users/anthony/mip/fiveq-plugins/wsp-downloads/snippets/downloads_item.php` (lines 1-24)

**HTML Structure Generated:**
```html
<div class="_download-item my-1.5">
    <a class="flex group !no-underline" href="..." download>
        <i class="_download-icon">
            <svg>...</svg> <!-- Download arrow SVG -->
        </i>
        <div class="_download-title">
            Behavioral Signs
        </div>
        <span class="_download-type">
            (pdf)
        </span>
    </a>
</div>
```

**The Problem:**
1. The anchor tag has `class="flex"` (Tailwind utility) which should make children display inline
2. Android WebView CSS in `HtmlContent.kt` (lines 44-227) doesn't include styles for `._download-*` classes
3. Without explicit flexbox CSS, the `<i>`, `<div>`, and `<span>` default to block-level stacking
4. The Tailwind classes (`flex`, `group`, `my-1.5`) are not interpreted as CSS since there's no Tailwind processor in the WebView

**Visual Result (from screenshot):**
- Red download icon on its own line
- "Behavioral Signs" title on its own line (in red)
- "(pdf)" label on its own line (in red)
- Excessive vertical spacing between items

### React Native Reference

The React Native app (`rn-mip-app`) renders the same HTML using `react-native-render-html` in `HTMLContentRenderer.tsx`. It **also does not have specific CSS** for the `._download-*` classes (checked lines 298-446 `classesStyles` and `tagsStyles`). However, RN's RenderHTML library may handle the flexbox differently than Android WebView, or the issue may exist there too but hasn't been reported.

**Key difference:** RN uses `react-native-render-html` which parses HTML and renders native components, while Android uses a standard WebView that requires explicit CSS for all styling.

### Root Cause

The wsp-downloads plugin snippet includes Tailwind utility classes (`flex`, `group`, etc.) that work on the web because the web site processes these through PostCSS/Tailwind. When the HTML is sent to the mobile API via wsp-mobile plugin (`/Users/anthony/mip/fiveq-plugins/wsp-mobile/lib/pages.php` lines 235-238, 258-265), it's just raw HTML without the processed Tailwind CSS.

The mobile apps (both RN and Android) need **explicit CSS rules** in their HTML renderers to style these download items properly.

### Proposed CSS Solution

Add the following CSS rules to `HtmlContent.kt` in the `<style>` tag (after line 221, before closing `</style>`):

```css
/* PDF Download List Styling */
._downloads {
    margin: 16px 0;
}

._download-item {
    margin: 12px 0;
}

._download-item a {
    display: flex !important;
    flex-direction: row;
    align-items: center;
    gap: 8px;
    padding: 12px 16px;
    background-color: #f8f9fa !important;
    border: 1px solid #e2e8f0;
    border-radius: 8px;
    text-decoration: none !important;
    border-bottom: none !important;
}

._download-icon {
    flex-shrink: 0;
    width: 24px;
    height: 24px;
    color: #64748b;
}

._download-icon svg {
    width: 24px;
    height: 24px;
    fill: currentColor;
}

._download-title {
    flex: 1;
    font-size: 16px;
    font-weight: 600;
    color: #0f172a !important;
    line-height: 1.4;
}

/* Hide redundant (pdf) label - icon is sufficient */
._download-type {
    display: none;
}

/* Alternative: Keep (pdf) label but style it as subtle badge */
/*
._download-type {
    flex-shrink: 0;
    font-size: 12px;
    color: #64748b;
    background: #f1f5f9;
    padding: 2px 8px;
    border-radius: 4px;
    text-transform: uppercase;
    font-weight: 600;
}
*/
```

**Design Rationale:**
1. **Hide `._download-type` span** - The download icon already indicates it's a file, "(pdf)" is redundant
2. **Flexbox layout** - Forces icon, title inline with `display: flex` and `!important` to override defaults
3. **Subtle background** - Light gray background (#f8f9fa) instead of bright red to reduce visual noise
4. **Muted icon color** - Gray icon (#64748b) instead of red for better hierarchy
5. **Clear tap target** - Padding on entire anchor makes full row tappable
6. **Proper spacing** - 12px vertical margin between items, 8px gap between flex children

### Alternative Approach (Badge Style)

If the client prefers keeping the file type indicator, use the commented CSS for `._download-type` which styles it as a subtle uppercase badge to the right of the title.

### Files to Modify

| File | Changes Needed |
|------|----------------|
| `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt` | Add CSS rules after line 221 |

**No backend changes needed** - The HTML structure from wsp-downloads plugin is fine, we just need CSS to display it properly.

### Testing Checklist

1. Build and install Android app
2. Navigate to Get Involved → FFC Chaplain Program → Chaplain Resources
3. Verify PDF links display in single-row format
4. Verify download icon and title are horizontally aligned
5. Verify "(pdf)" label is hidden (or styled as badge if alternative approach chosen)
6. Verify tap target encompasses entire row
7. Verify spacing between items is consistent
8. Test a few download links to ensure they still download correctly

### Estimated Complexity

**Low** - This is a pure CSS fix. No logic changes, no API changes, no backend changes. Just add ~40 lines of CSS to the WebView style tag in `HtmlContent.kt`.
