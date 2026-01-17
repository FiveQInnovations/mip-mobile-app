---
status: in-progress
area: rn-mip-app
phase: core
created: 2026-01-16
---

# Homepage Logo - Make Firefighters for Christ Logo Smaller

## Context

From the Jan 13, 2026 meeting with Mike Bell, the large "Firefighters for Christ" logo on the homepage should be made smaller to save screen real estate and improve the overall design.

## Goals

1. Reduce the size of the large "Firefighters for Christ" logo on the homepage
2. Optimize screen real estate usage
3. Maintain logo readability and brand recognition

## Acceptance Criteria

- Homepage logo is visibly smaller than current size
- Logo remains readable and recognizable
- Screen real estate is better utilized for content
- Design maintains visual hierarchy

## Notes

- This is separate from the header logo change
- Logo should still be prominent but less dominating
- Consider responsive design across different screen sizes
- **Feedback (2026-01-17):** The logo size is better, but there is still excessive white/gray space in the logo section. Investigate if the logo image itself has built-in whitespace at the top and bottom that should be removed.

## References

- Meeting transcript: meetings/ffci-app-build-review-jan-13.md

---

## Scout Findings

### Current Implementation Analysis

**Homepage Logo Location:**
- **File:** `rn-mip-app/components/HomeScreen.tsx`
- **Lines:** 177-194 (Logo render section)
- **Lines:** 49-52 (Logo size calculation logic)
- **Lines:** 302-311 (Logo section styling)

**Current Logo Implementation:**

```tsx
// Lines 49-52: Responsive size calculation
const screenWidth = Dimensions.get('window').width;
const logoWidth = Math.min(Math.max(screenWidth * 0.85, 280), 400);
const logoHeight = logoWidth * 0.6; // Maintain 5:3 aspect ratio (200:120)

// Lines 177-194: Logo rendering
<View style={styles.logoSection}>
  {logoUrl && (
    isSvgLogo ? (
      <SvgUri
        uri={logoUrl}
        width={logoWidth}
        height={logoHeight}
        style={styles.logo}
      />
    ) : (
      <Image
        source={{ uri: logoUrl }}
        style={[styles.logo, { width: logoWidth, height: logoHeight }]}
        resizeMode="contain"
      />
    )
  )}
</View>
```

**Current Dimensions:**
- **Width:** 85% of screen width, with constraints:
  - Minimum: 280px
  - Maximum: 400px
- **Height:** 60% of width (5:3 aspect ratio)
- **Responsive:** Automatically scales based on device width

**Example Sizes by Device:**
- iPhone SE (375px): Logo width = 318px, height = 191px
- iPhone 14 (390px): Logo width = 331px, height = 199px
- iPhone 14 Pro Max (430px): Logo width = 365px, height = 219px
- iPad (768px): Logo width = 400px (capped), height = 240px

**Logo Section Styling (lines 302-311):**
- Background: #f8fafc (light gray)
- Padding: 30px vertical, 20px horizontal
- Center-aligned
- Bottom margin: 20px

### Logo Asset Details

**Logo Source:**
- Loaded from API via `site_data.logo` field (line 43-47)
- Managed in Kirby CMS via `wsp-mobile` plugin
- Configuration: `lib/site.php` line 11-20 (`get_site_logo` method)
- CMS field: `site->mobileLogo()`

**Current Logo Asset:**
- File: `/Users/anthony/mip/sites/ws-ffci/www/assets/img/logo.svg`
- Format: SVG (scalable vector graphic)
- Content: Full "Firefighters for Christ" wordmark with Maltese Cross icon
- Dimensions: 195x56 viewBox (approximately 3.5:1 aspect ratio)

**Logo Rendering Logic:**
- Supports both SVG and raster images (PNG, JPG)
- SVG detection: checks if URL ends with `.svg` (line 167)
- Uses `react-native-svg` SvgUri component for SVGs
- Falls back to Image component for raster formats

### Layout and Spacing Context

**Homepage Structure:**
1. **CustomHeader** (lines 17-34) - Persistent header with small logo + search
2. **Logo Section** (lines 177-194) - LARGE logo hero area ← THIS IS THE TARGET
3. **Horizontal Quick Tasks Scroll** (lines 197-214) - Card carousel
4. **Featured Section** (lines 217-233) - Vertical list of featured items

**Spacing Relationships:**
- Logo section has 30px top/bottom padding (line 304)
- Logo section has 20px bottom margin (line 307)
- Total vertical space consumed: ~30 + logo height + 30 + 20 = logo height + 80px
- On iPhone 14: 199px (logo) + 80px = **279px of screen real estate**

**Visual Impact:**
- The logo section dominates the top ~1/3 to 1/2 of the initial viewport on phones
- Light gray background (#f8fafc) creates a distinct "hero" area
- Content cards begin below the fold on most devices

### Recommended Changes

**Proposed New Size:**
- **Width:** 60% of screen width (down from 85%)
- **Minimum:** 200px (down from 280px)
- **Maximum:** 280px (down from 400px)
- **Height:** Keep 60% ratio (5:3 aspect)

**Rationale:**
- Reduces logo by ~30% on most devices
- Example sizes:
  - iPhone SE (375px): 225px wide (was 318px) - **saves 93px width**
  - iPhone 14 (390px): 234px wide (was 331px) - **saves 97px width**
  - iPhone 14 Pro Max (430px): 258px wide (was 365px) - **saves 107px width**
- On iPhone 14: New height ~140px vs current 199px - **saves ~59px vertical space**

**Additional Spacing Adjustments:**
- Reduce `paddingVertical` from 30px to 20px (saves 20px total)
- Reduce `marginBottom` from 20px to 12px (saves 8px)
- **Total vertical savings: ~87px** on typical phone (59 + 20 + 8)

### Implementation Plan

**Step 1: Update Logo Size Calculation** (line 51)
```tsx
// Change from:
const logoWidth = Math.min(Math.max(screenWidth * 0.85, 280), 400);

// Change to:
const logoWidth = Math.min(Math.max(screenWidth * 0.60, 200), 280);
```

**Step 2: Update Logo Section Padding** (line 304)
```tsx
// Change from:
paddingVertical: 30,

// Change to:
paddingVertical: 20,
```

**Step 3: Update Logo Section Margin** (line 307)
```tsx
// Change from:
marginBottom: 20,

// Change to:
marginBottom: 12,
```

### Code Locations Summary

| File | Lines | Purpose | Change Needed |
|------|-------|---------|---------------|
| `rn-mip-app/components/HomeScreen.tsx` | 51 | Logo width calculation | Change `0.85` to `0.60`, `280` to `200`, `400` to `280` |
| `rn-mip-app/components/HomeScreen.tsx` | 304 | Logo section vertical padding | Change `30` to `20` |
| `rn-mip-app/components/HomeScreen.tsx` | 307 | Logo section bottom margin | Change `20` to `12` |

### Files That DON'T Need Changes

| File | Reason |
|------|--------|
| `rn-mip-app/components/HomeScreen.tsx` (lines 17-34) | CustomHeader component - different logo (small header icon) |
| `rn-mip-app/lib/api.ts` | API interface - no size logic |
| `rn-mip-app/lib/config.ts` | Configuration - no logo sizing |
| `rn-mip-app/components/TabScreen.tsx` | Different screen type |
| `rn-mip-app/components/ContentCard.tsx` | Separate component |
| `wsp-mobile/lib/site.php` | Backend - only serves logo URL, not size |
| `maestro/flows/homepage-loads-*.yaml` | Tests don't verify logo size |

### Testing Considerations

**Visual Testing Required:**
- Test on iPhone SE (small screen)
- Test on iPhone 14 Pro Max (large screen)
- Test on iPad (tablet)
- Verify logo remains readable at new size
- Ensure content cards are more visible above the fold

**No Automated Test Changes Needed:**
- Maestro flows don't test logo dimensions
- They only verify text content ("About Us", "Featured", etc.)

### Potential Issues & Considerations

1. **Logo Readability:**
   - Current logo SVG has text "COLOR LOGO" + Maltese Cross
   - At 60% size, text will be smaller but still legible
   - SVG format ensures crisp rendering at any size
   - **Recommendation:** Preview on actual device before finalizing

2. **Brand Consistency:**
   - Mike Bell requested "make the large logo smaller" (meeting line 40)
   - This is separate from ticket 070 (header logo replacement)
   - Goal is to save screen real estate, not remove branding

3. **Responsive Design:**
   - New constraints maintain responsive behavior
   - Min 200px ensures small devices don't get too small
   - Max 280px prevents tablets from having oversized logo

4. **CMS Independence:**
   - Logo asset remains controlled by CMS
   - No backend changes required
   - Can swap logo file without code changes

5. **Related Work:**
   - This is distinct from ticket 070 (header Maltese Cross)
   - Both tickets address different logos on the same screen
   - Header logo stays at 24x24px (unchanged)

### Variables/Data Reference

| Variable | Type | Purpose | Location |
|----------|------|---------|----------|
| `screenWidth` | number | Device screen width in px | Line 50 |
| `logoWidth` | number | Calculated logo width | Line 51 |
| `logoHeight` | number | Calculated logo height (width * 0.6) | Line 52 |
| `logoUrl` | string \| null | Logo image URL from API | Lines 43-47 |
| `isSvgLogo` | boolean | Whether logo is SVG format | Line 167 |
| `site_data.logo` | string \| null | Logo URL from API response | API interface line 39 |
| `styles.logoSection` | StyleSheet | Container for logo | Lines 302-308 |
| `styles.logo` | StyleSheet | Logo image style | Lines 309-311 |

### Estimated Complexity

**Low Complexity**

**Reasoning:**
- Simple numeric constant changes (3 lines)
- No logic changes required
- No API or data flow changes
- No new dependencies
- SVG format handles scaling automatically
- Existing responsive logic remains intact

**Development Time:**
- Code changes: 5 minutes
- Visual testing on multiple devices: 15-20 minutes
- Total: **20-25 minutes**

**Risk Level:** Very Low
- Changes are purely visual/cosmetic
- Easy to revert if needed
- No breaking changes to other components
- No test updates required