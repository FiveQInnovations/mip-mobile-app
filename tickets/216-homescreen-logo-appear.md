---
status: backlog
area: rn-mip-app
phase: core
created: 2026-01-26
---

# Homepage Logo Should Appear on Homescreen

## Context

The main Firefighters for Christ logo should be visible on the homescreen, but it is currently not appearing. This is the large logo that should be displayed in the logo section of the homepage, separate from the small Maltese cross in the header.

## Goals

1. Ensure the main homepage logo appears and is visible on the homescreen
2. Verify logo is properly loaded and rendered
3. Maintain proper sizing and positioning

## Acceptance Criteria

- Main Firefighters for Christ logo is visible on the homescreen
- Logo appears in the expected location (logo section area)
- Logo loads correctly from the API/CMS
- Logo displays properly on both iOS and Android

## Notes

- This is separate from the small Maltese cross that should appear in the header (ticket 217)
- Logo should be loaded from `site_data.logo` field via API
- Check if logo URL is being fetched correctly
- Verify logo rendering logic (SVG vs raster image handling)

## References

- Related: [071](071-homepage-logo-smaller.md) - Homepage Logo Size (already completed)
- Related: [217](217-header-maltese-cross-appear.md) - Small Maltese Cross in Header

---

## Research Findings (Scouted)

### Current Implementation Analysis

**Homepage Logo Location:**
- **File:** `rn-mip-app/components/HomeScreen.tsx`
- **Lines:** 234-258 (Logo section rendering)
- **Lines:** 54-58 (Logo URL extraction from API)
- **Lines:** 61 (Fallback logo asset reference)
- **Lines:** 64-66 (Responsive logo size calculation)
- **Lines:** 181 (SVG detection logic)
- **Lines:** 406-411 (Logo section styling)

**Logo Rendering Logic:**

The logo section is always rendered (line 234), but the content inside is conditional:

```tsx
// Lines 54-58: Extract logo URL from API
const logoUrl = site_data.logo
  ? site_data.logo.startsWith('http')
    ? site_data.logo
    : `${config.apiBaseUrl}${site_data.logo}`
  : null;

// Lines 61: Fallback asset reference
const fallbackLogoPath = require('../assets/ffci-logo.svg');

// Lines 235-257: Conditional rendering
{logoUrl ? (
  isSvgLogo ? (
    <SvgUri uri={logoUrl} ... />
  ) : (
    <Image source={{ uri: logoUrl }} ... />
  )
) : (
  <Image source={fallbackLogoPath} ... />
)}
```

**Current Behavior:**
1. If `site_data.logo` exists → renders API logo (SVG or raster)
2. If `site_data.logo` is null/undefined → should render fallback logo from `assets/ffci-logo.svg`
3. Logo section container is always visible (light gray background `#f8fafc`)

**Logo Size Calculation (lines 64-66):**
- Width: 60% of screen width, constrained between 200px-280px
- Height: 60% of width (maintains 5:3 aspect ratio)
- This sizing was implemented in ticket 071

**Backend API Implementation:**

- **File:** `wsp-mobile/lib/site.php`
- **Lines:** 11-20 (`get_site_logo()` method)
- **Lines:** 99 (Logo included in API response)

```php
private function get_site_logo($site) {
    $logo = $site->mobileLogo();
    if ($logo->isNotEmpty()) {
        $file = $logo->toFile();
        if ($file && $file->exists()) {
            return $file->toCDNFile()->url();
        }
    }
    return null; // Returns null if no logo configured
}
```

**API Response Structure:**
- Endpoint: `/mobile-api`
- Field: `site_data.logo` (string | null)
- Returns CDN URL if logo exists in CMS, `null` otherwise

**Fallback Asset:**
- **File:** `rn-mip-app/assets/ffci-logo.svg` ✅ (exists)
- Used when API returns `null` for logo field
- Should render via `Image` component with `require()` import

### Potential Issues Identified

1. **SVG Rendering Failure:**
   - Uses `react-native-svg` `SvgUri` component for SVG logos
   - If SVG fails to load/parse, might render nothing silently
   - No error handling or fallback within SVG render path

2. **Fallback Logo Not Loading:**
   - Fallback uses `require('../assets/ffci-logo.svg')` 
   - React Native may not handle SVG via `require()` correctly
   - Should verify if SVG assets work with standard `Image` component

3. **API Logo URL Construction:**
   - If `site_data.logo` is relative path, prepends `config.apiBaseUrl`
   - If URL construction fails or API base URL is wrong, logo won't load
   - No validation that constructed URL is valid

4. **Conditional Rendering Logic:**
   - Line 235: `{logoUrl ? (` - if `logoUrl` is empty string `""`, this evaluates to false
   - Empty string would trigger fallback, but might indicate API issue

5. **No Loading/Error States:**
   - No loading indicator while logo fetches
   - No error handling if image fails to load
   - Silent failures could make logo appear "missing"

### Android Implementation Reference

**File:** `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/screens/HomeScreen.kt`
**Lines:** 115-181

Android implementation shows:
- Logo section always renders (light gray background)
- Uses `SubcomposeAsyncImage` with proper loading/error states
- Shows site title as fallback if logo fails to load
- Handles both absolute and relative URLs correctly

**Key Difference:** Android has explicit error handling that shows fallback text, React Native might fail silently.

### Implementation Plan

**Step 1: Verify API Response**
- Check what `site_data.logo` actually returns in API response
- Verify if it's `null`, empty string, or a valid URL
- Test API endpoint: `${config.apiBaseUrl}/mobile-api`

**Step 2: Debug Logo Rendering**
- Add console logs to verify `logoUrl` value
- Check if `logoUrl` is truthy when API returns logo
- Verify fallback path executes when `logoUrl` is null

**Step 3: Fix SVG Fallback Handling**
- Verify `require('../assets/ffci-logo.svg')` works with React Native Image component
- If SVG doesn't work via `require()`, convert to PNG or use different approach
- Consider using `react-native-svg` for fallback SVG too

**Step 4: Add Error Handling**
- Add `onError` handler to Image components
- Add loading state indicator
- Log errors to help debug rendering failures

**Step 5: Verify Logo URL Construction**
- Ensure `config.apiBaseUrl` is correct
- Validate URL construction logic handles all cases
- Test with both absolute and relative URLs

**Step 6: Test Both Paths**
- Test when API returns logo URL (should show API logo)
- Test when API returns null (should show fallback logo)
- Verify on both iOS and Android platforms

### Code Locations

| File | Lines | Purpose | Change Needed |
|------|-------|---------|---------------|
| `rn-mip-app/components/HomeScreen.tsx` | 54-58 | Logo URL extraction | Add logging, verify null handling |
| `rn-mip-app/components/HomeScreen.tsx` | 61 | Fallback logo asset | Verify SVG works with require() |
| `rn-mip-app/components/HomeScreen.tsx` | 235-257 | Logo rendering logic | Add error handling, loading states |
| `rn-mip-app/components/HomeScreen.tsx` | 237-242 | SVG logo rendering | Add error callback, fallback |
| `rn-mip-app/components/HomeScreen.tsx` | 244-248 | Raster logo rendering | Add onError handler |
| `rn-mip-app/components/HomeScreen.tsx` | 251-256 | Fallback logo rendering | Verify SVG asset loads correctly |

### Files That DON'T Need Changes

| File | Reason |
|------|--------|
| `rn-mip-app/components/HomeScreen.tsx` (lines 18-36) | CustomHeader component - different logo (small header icon) |
| `rn-mip-app/lib/api.ts` | API interface - correctly typed, no changes needed |
| `rn-mip-app/lib/config.ts` | Configuration - no changes unless API base URL is wrong |
| `wsp-mobile/lib/site.php` | Backend API - correctly returns logo or null |
| `android-mip-app/.../HomeScreen.kt` | Android implementation - separate codebase |
| `ios-mip-app/` | iOS native app - separate codebase (if exists) |

### Variables/Data Reference

| Variable | Type | Purpose | Location |
|----------|------|---------|----------|
| `site_data.logo` | string \| null | Logo URL from API response | API interface (`lib/api.ts` line 39) |
| `logoUrl` | string \| null | Processed logo URL (with base URL prepended) | HomeScreen.tsx line 54 |
| `isSvgLogo` | boolean | Whether logo URL ends with `.svg` | HomeScreen.tsx line 181 |
| `fallbackLogoPath` | any | Bundled SVG asset reference | HomeScreen.tsx line 61 |
| `logoWidth` | number | Calculated responsive logo width | HomeScreen.tsx line 65 |
| `logoHeight` | number | Calculated responsive logo height | HomeScreen.tsx line 66 |
| `config.apiBaseUrl` | string | Base URL for API requests | From config.ts |

### Root Cause Hypotheses

1. **Most Likely:** Fallback SVG asset not loading correctly via `require()` - React Native may not support SVG files directly with `Image` component
2. **Possible:** API returning empty string `""` instead of `null`, causing logoUrl to be truthy but invalid
3. **Possible:** SVG rendering failing silently - `SvgUri` component might not handle errors gracefully
4. **Less Likely:** Logo section rendering but with zero dimensions due to styling issue

### Testing Strategy

**Manual Testing:**
1. Check browser/network tab to see if logo URL is being requested
2. Verify API response contains logo field
3. Test with API logo present (should show API logo)
4. Test with API logo null (should show fallback)
5. Check console for any rendering errors
6. Verify logo section background appears (confirms section renders)

**Debugging Steps:**
1. Add `console.log('logoUrl:', logoUrl)` after line 58
2. Add `console.log('site_data.logo:', site_data.logo)` after line 52
3. Add `onError` handlers to Image components to log failures
4. Verify `fallbackLogoPath` resolves correctly

### Estimated Complexity

**Medium Complexity**

**Reasoning:**
- Requires debugging to identify root cause
- May need to fix SVG asset handling (could require asset conversion)
- Error handling improvements needed
- Multiple potential failure points to investigate
- Testing required on both platforms

**Development Time:**
- Investigation/debugging: 30-45 minutes
- Code fixes: 15-30 minutes
- Testing on iOS/Android: 20-30 minutes
- Total: **1-2 hours**

**Risk Level:** Low-Medium
- Changes are isolated to logo rendering
- Fallback exists, so won't break app
- May require asset format changes if SVG issue confirmed
