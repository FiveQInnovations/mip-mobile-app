---
status: done
area: rn-mip-app
phase: core
created: 2026-01-16
---

# Header Logo - Replace Default Logo with Maltese Cross

## Context

From the Jan 13, 2026 meeting with Mike Bell, the persistent header should use the Maltese Cross logo instead of the current "FFC" text. Mike stated: "what we had up there was our little Maltese Cross logo up in the upper left corner, and then it said FFC next to it, which if it's not functional, I'd rather just have the little logo up there, just because it looks cool."

## Goals

1. Replace the "FFC" text in the header with just the Maltese Cross logo
2. Maintain header functionality and styling

## Acceptance Criteria

- Maltese Cross logo appears in the header upper left corner
- "FFC" text is removed (replaced by logo only)
- Logo is properly sized and positioned
- Header functionality remains intact
- Design maintains visual consistency

## Notes

- This is a separate task from making the large homepage logo smaller
- Maltese Cross logo file needed from Adam Hardy
- Michael specifically wants "just the little logo up there" without the text

## References

- Meeting transcript: meetings/ffci-app-build-review-jan-13.md (lines 1555-1557)

---

## Research Findings (Scouted)

### Current Implementation Analysis

**Header Component Location:**
- **File:** `rn-mip-app/components/HomeScreen.tsx`
- **Lines:** 17-34 (CustomHeader component definition)
- **Lines:** 21-26 (Current logo + text implementation)

**Current Header Structure:**
```tsx
// Line 21-26: Current implementation
<Image 
  source={require('../assets/adaptive-icon.png')} 
  style={styles.headerLogo} 
  resizeMode="contain"
/>
<Text style={styles.headerTitle}>FFC</Text>
```

**Current Header Styling:**
- `headerLogo`: 24x24px (line 279-282)
- `headerTitle`: 18px font, 700 weight, color #0f172a (line 283-287)
- Header uses flexDirection: 'row' with gap: 8 between logo and text (line 274-278)

**Other Components Using Headers:**
- `rn-mip-app/components/TabScreen.tsx` - Uses a different header style (dynamic header for navigation)
- `rn-mip-app/app/_layout.tsx` - Root layout, no custom header here

### Logo Asset Status

**Existing Logo Files in Kirby Site:**
- `/Users/anthony/mip/sites/ws-ffci/content/logo-mark.svg` - **CORRECT:** Standalone Maltese Cross icon (no text) - 100x100 viewBox
- `/Users/anthony/mip/sites/ws-ffci/www/assets/img/logo.svg` - Full logo with "COLOR LOGO" text + Maltese Cross
- `/Users/anthony/mip/sites/ws-ffci/www/assets/img/logo-mobile.svg` - Mobile version with text

**Current App Assets:**
- `rn-mip-app/assets/icon.png` - **CORRECT:** App icon (Maltese Cross) - Use this for header
- `rn-mip-app/assets/adaptive-icon.png` - **INCORRECT:** Currently used in header (24x24) - Wrong logo
- `rn-mip-app/assets/favicon.png` - **INCORRECT:** Wrong logo
- `rn-mip-app/assets/splash-icon.png` - **INCORRECT:** Wrong logo

**Maltese Cross Asset:**
The correct Maltese Cross logo is `icon.png`. The header currently uses `adaptive-icon.png` which is the wrong logo. We need to change the header to use `icon.png` instead.

### Implementation Plan

1. **Copy Correct Logo Asset**
   - Copy `rn-mip-app/assets/icon.png` to `rn-mip-app/assets/adaptive-icon.png` (replace existing file)
   - This ensures the header uses the correct Maltese Cross logo without code changes

2. **Update HomeScreen.tsx** (lines 21-26)
   - Keep using `adaptive-icon.png` (now contains correct logo after copy)
   - Remove the `<Text style={styles.headerTitle}>FFC</Text>` line entirely
   - Adjust image size if needed (currently 24x24, may want slightly larger without text)

4. **Update Styles** (lines 279-287)
   - Keep `headerLogo` style
   - Consider increasing size to 28-32px since text will be removed
   - Remove `headerTitle` style (no longer used)
   - Remove `gap: 8` from headerLeft since no text to space

5. **Update Tests**
   - `maestro/flows/verify-header-renders.yaml` (line 6) - Currently expects "FFC" text
   - `maestro/flows/search-not-done-ios.yaml` (lines 15, 81) - References "FFC" text
   - Update these tests to verify logo image instead of text

### Code Locations

| File | Lines | Purpose | Changes Needed |
|------|-------|---------|----------------|
| `rn-mip-app/assets/adaptive-icon.png` | N/A | Header logo asset | Copy `icon.png` to replace this file with correct Maltese Cross |
| `rn-mip-app/components/HomeScreen.tsx` | 21-26 | Header logo + text | Keep `adaptive-icon.png` reference (now correct after asset copy), remove Text element |
| `rn-mip-app/components/HomeScreen.tsx` | 279-282 | Header logo styles | Potentially increase size (24→28/32px) |
| `rn-mip-app/components/HomeScreen.tsx` | 283-287 | Header title styles | Can be removed (unused) |
| `rn-mip-app/components/HomeScreen.tsx` | 274-278 | Header left container | Remove gap: 8 (no text to space) |
| `maestro/flows/verify-header-renders.yaml` | 6 | Test expects "FFC" text | Update to verify logo instead |
| `maestro/flows/search-not-done-ios.yaml` | 15, 81 | Test expects "FFC" text | Update to verify logo instead |

### Files That DON'T Need Changes

| File | Reason |
|------|--------|
| `rn-mip-app/components/TabScreen.tsx` | Uses different header style for page navigation |
| `rn-mip-app/app/_layout.tsx` | Root layout, no custom header implementation |
| `rn-mip-app/components/PageScreen.tsx` | If exists, likely uses TabScreen's header |
| `rn-mip-app/lib/config.ts` | Configuration file, no header logic |
| `rn-mip-app/app.json` | App metadata, full name stays "FFCI Mobile" |

### Styling Considerations

**Responsive Design:**
- Current header is consistent across all screen sizes
- Header height: auto-sized by paddingVertical: 12 (line 269)
- Logo size should remain proportional (suggest 28-32px for better visibility)

**Color/Theme:**
- Header background: #ffffff (white)
- Border bottom: #f1f5f9 (light gray)
- Current text color: #0f172a (dark slate) - won't matter after removal
- Ensure Maltese Cross icon has good contrast on white background

**Accessibility:**
- Image should have appropriate accessibilityLabel (e.g., "FFC Logo" or "Firefighters for Christ")
- Remove accessibilityLabel from deleted text element

### Estimated Complexity

**Low-Medium Complexity**

**Reasoning:**
- Simple asset copy (copy icon.png to adaptive-icon.png)
- Simple code change (remove 1 line - the Text element)
- Need to update 2-3 Maestro test files
- Straightforward styling adjustments
- No data flow or API changes required

**Time Estimate:**
- Asset copy: 1 minute
- Code changes: 5-10 minutes
- Test updates: 10-15 minutes
- Visual verification: 10 minutes
- Total: ~25-35 minutes of development work

**Blockers:**
- None - the correct Maltese Cross is already available as `icon.png` in the app assets