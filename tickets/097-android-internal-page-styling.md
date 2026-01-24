---
status: done
area: android-mip-app
phase: core
created: 2026-01-24
---

# Android Internal Page Styling

## Context

Internal content pages need visual improvements. The current rendering of page content could be enhanced with better typography, spacing, and visual hierarchy for headings, paragraphs, and dividers.

## Goals

1. Improve visual presentation of internal page content
2. Better typography hierarchy (H1, H2, H3, body text)
3. Add visual dividers/separators where appropriate
4. Consistent spacing and padding

## Acceptance Criteria

- Headings are visually distinct and properly sized
- Body text is readable with appropriate line height
- Dividers/separators help organize content sections
- Images display properly with appropriate sizing
- Links are styled and tappable
- Overall design matches iOS app quality

## Notes

- Content comes from Kirby CMS as structured data
- May involve parsing and rendering different block types
- Consider using Material Design 3 typography scale

## References

- Previous ticket: 059-internal-page-visual-design.md
- Previous ticket: 078-content-page-design-improvements.md
- Material Design 3 typography guidelines

---

## Research Findings (Scouted)

### React Native Reference

The RN app has sophisticated HTML content styling implemented in `rn-mip-app/components/HTMLContentRenderer.tsx` (lines 321-446) using `react-native-render-html` with custom tag styles:

**Typography Hierarchy:**
- **H1**: 34px, bold, textColor (#0f172a), letterSpacing: -1, lineHeight: 40
- **H2**: 28px, bold, textColor, letterSpacing: -0.6, lineHeight: 34
- **H3**: 23px, 700, secondaryColor (#024D91), lineHeight: 30, with 3px left border (primaryColor), 12px left padding
- **H4**: 20px, 600, textColor, lineHeight: 26
- **H5**: 18px, 700, secondaryColor, lineHeight: 24
- **H6**: 15px, 700, uppercase, letterSpacing: 1, gray color (#64748b), lineHeight: 20

**Body Text:**
- **Paragraphs**: 17px, lineHeight: 28px, color: #334155, 16px top/bottom margins

**Links:**
- Color: primaryColor (#D9232A)
- Font weight: 600
- Background: rgba(217, 35, 42, 0.08) with 4-6px horizontal padding
- Border bottom: 2px solid primaryColor
- Border radius: 4px

**Lists:**
- 16px top/bottom margins
- 24px left padding
- List items: 8px bottom margin

**Blockquotes:**
- 4px left border (primaryColor)
- 20px left padding
- Background: #f1f5f9
- Italic, 18px font size
- Color: #475569
- 24px top/bottom margins

**HR Dividers:**
- 32px top/bottom margins
- 1px top border
- Color: #cbd5e1

**Images:**
- 24px top/bottom margins
- Border radius: 8px
- Aspect ratio: 16:9

**Buttons:**
- Background: primaryColor
- White text, 600 weight
- 20px horizontal padding, 14px vertical
- Border radius: 8px
- Full width

**Spacing & Colors:**
- All colors use config values (primaryColor, secondaryColor, textColor)
- Generous margins between elements
- Strong visual hierarchy

### Current Android Implementation Analysis

The Android app renders HTML content using WebView in `HtmlContent.kt` (lines 32-148) with basic CSS styling:

**Current Styling (lines 38-143):**
```css
body: 16px, line-height 1.6, color #0f172a, 0 16px padding
h1-h6: color #0f172a, margin-top 1.5em, margin-bottom 0.5em (FLAT HIERARCHY)
p: 1em margins
a: color #D9232A, no decoration
img: max-width 100%, border-radius 8px
blockquote: 4px left border #D9232A, 1em margins, 16px left padding
```

**What's Missing:**
- ❌ No typography hierarchy (all headings use same basic style)
- ❌ No distinct sizes/weights for H1-H6
- ❌ No letter-spacing adjustments
- ❌ No line-height specifications for headings
- ❌ No secondary color accent on H3/H5
- ❌ No link background/underline styling
- ❌ Minimal blockquote styling (no background, no italic)
- ❌ No HR divider styling
- ❌ No specific margins for images, lists
- ❌ Less generous spacing overall

**What Works:**
- ✅ Basic font-family (system fonts)
- ✅ Primary color for links
- ✅ Image border-radius
- ✅ Button styling (._button classes)
- ✅ Responsive images

### Implementation Plan

**Step 1: Enhance Typography Hierarchy in HtmlContent.kt**

Update the `<style>` block (lines 37-143) to match RN styling:

1. **Add H1 styling** (after line 49):
   ```css
   h1 {
       font-size: 34px;
       font-weight: 700;
       margin-top: 36px;
       margin-bottom: 20px;
       color: #0f172a;
       letter-spacing: -1px;
       line-height: 40px;
   }
   ```

2. **Add H2 styling**:
   ```css
   h2 {
       font-size: 28px;
       font-weight: 700;
       margin-top: 32px;
       margin-bottom: 16px;
       color: #0f172a;
       letter-spacing: -0.6px;
       line-height: 34px;
   }
   ```

3. **Add H3 styling with left border accent**:
   ```css
   h3 {
       font-size: 23px;
       font-weight: 700;
       margin-top: 28px;
       margin-bottom: 12px;
       color: #024D91;
       line-height: 30px;
       padding-left: 12px;
       border-left: 3px solid #D9232A;
   }
   ```

4. **Add H4-H6 styling** (distinct sizes and weights)

5. **Enhance paragraph styling** (line 51-53):
   - Font-size: 17px (from 16px)
   - Line-height: 28px (from 1.6 = ~26px)
   - Margins: 16px top/bottom (from 1em)
   - Color: #334155 (slightly darker for better contrast)

6. **Enhance link styling** (line 54-57):
   - Add background: rgba(217, 35, 42, 0.08)
   - Add padding: 4px 6px
   - Add border-bottom: 2px solid #D9232A
   - Add border-radius: 4px
   - Keep font-weight: 600

7. **Enhance blockquote styling** (line 98-103):
   - Add background: #f1f5f9
   - Add font-style: italic
   - Increase padding-left to 20px
   - Add padding: 12px 0 12px 20px
   - Update margins: 24px 0
   - Font-size: 18px
   - Color: #475569

8. **Add HR styling** (after blockquote):
   ```css
   hr {
       margin: 32px 0;
       border: none;
       border-top: 1px solid #cbd5e1;
   }
   ```

9. **Enhance list styling** (lines 92-97):
   - Margins: 16px 0
   - List items: 8px bottom margin

10. **Enhance image styling** (lines 58-62):
    - Add margins: 24px 0

**Step 2: Test Visual Changes**

1. Test on "About Us" page (content-heavy page)
2. Test on "Resources" page (mixed content)
3. Verify all heading levels render distinctly
4. Check link styling and tappability
5. Verify images display with proper spacing
6. Test blockquotes and HR dividers if present

**Step 3: Compare with iOS/RN**

1. Take screenshots of same content page on both platforms
2. Verify visual parity in:
   - Heading hierarchy
   - Text readability
   - Spacing and rhythm
   - Color usage

### Code Locations

| File | Lines | Purpose |
|------|-------|---------|
| `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt` | 37-143 | CSS styling for HTML content - **MODIFY THIS** |
| `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/screens/TabScreen.kt` | 1-314 | Page rendering - **NO CHANGES NEEDED** |
| `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/theme/Theme.kt` | 8-14 | Brand colors defined - **REFERENCE ONLY** |
| `rn-mip-app/components/HTMLContentRenderer.tsx` | 321-446 | RN reference implementation - **REFERENCE ONLY** |

### Variables/Data Reference

**Brand Colors (from Theme.kt):**
- `PrimaryColor`: #D9232A (red)
- `SecondaryColor`: #024D91 (blue)
- `TextColor`: #0F172A (dark slate)
- `BackgroundColor`: #F8FAFC (light gray)

**Typography Scale (RN → Android CSS):**
- H1: 34px → 34px
- H2: 28px → 28px
- H3: 23px → 23px
- H4: 20px → 20px
- H5: 18px → 18px
- H6: 15px → 15px
- Body: 17px → 17px

**Color Mapping:**
- `textColor` (#0f172a) → Use for H1, H2, H4, body text
- `secondaryColor` (#024D91) → Use for H3, H5
- `primaryColor` (#D9232A) → Use for links, H3 border, blockquote border

### Android-Specific Considerations

1. **WebView CSS**: All styling is done via CSS in the `styledHtml` string. No native Compose styling needed.

2. **No Dynamic Config**: Unlike RN which reads colors from config at runtime, Android CSS is static. Brand colors are hardcoded in the CSS string (could be made dynamic by string interpolation if needed for multi-tenant support).

3. **Font Rendering**: WebView uses system fonts. The CSS already specifies: `-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif` which works well on Android.

4. **Testing**: Use the existing TabScreen - no component changes needed. Just update the CSS and reload pages.

### Estimated Complexity

**Low-Medium**

**Reasoning:**
- ✅ All changes are CSS-only in one file (HtmlContent.kt)
- ✅ Clear reference implementation in RN app
- ✅ No API changes needed
- ✅ No new components needed
- ✅ Existing WebView infrastructure works
- ⚠️ Need careful testing to ensure all HTML elements render properly
- ⚠️ Need to verify visual parity with iOS

**Estimated Time:** 1-2 hours (mostly CSS tuning and testing)

**Testing Strategy:**
1. Visual comparison with RN app screenshots
2. Test multiple content pages (About, Resources, etc.)
3. Verify all heading levels appear distinct
4. Check link styling and interaction
5. Test blockquotes, lists, images, HR dividers if present
