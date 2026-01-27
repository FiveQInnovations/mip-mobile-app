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

## Research Findings (Scouted) - INDEPENDENT INVESTIGATION

### Executive Summary

**Root Cause Identified:** The logo is configured correctly in the CMS and should be returned by the API. The primary issue is with **SVG rendering failing silently** in the `SvgUri` component, with **no error handling or fallback mechanism**. Secondary issue: the fallback logo rendering is fundamentally broken due to incompatibility with React Native's `Image` component.

**Critical Discovery:** The CMS has a logo configured at CDN URL `https://ffci-5q.b-cdn.net/image/logo-mobile.svg`, so the API *should* be returning a valid logo URL. The problem is in the frontend rendering logic.

### Current Implementation Analysis

**Logo Rendering Flow:**

```
1. API call to /mobile-api
2. Extract site_data.logo (should be CDN URL or null)
3. Process URL (prepend base URL if relative)
4. Detect if SVG (.svg extension)
5. Render:
   - If SVG → use SvgUri component (lines 237-242)
   - If raster → use Image component (lines 244-248)
   - If null → use fallback Image with require() (lines 251-256)
```

**File:** `rn-mip-app/components/HomeScreen.tsx`

| Lines | Purpose | Issue Status |
|-------|---------|-------------|
| 54-58 | Logo URL extraction from API | ✅ Logic correct |
| 61 | Fallback logo asset reference | ❌ **BROKEN** - see details below |
| 64-66 | Responsive logo size calculation | ✅ Working correctly |
| 181 | SVG detection logic | ✅ Correct (checks .svg extension) |
| 234-258 | Logo section rendering | ⚠️ Missing error handling |
| 237-242 | SVG logo rendering via SvgUri | ❌ **NO ERROR HANDLING** |
| 244-248 | Raster logo rendering via Image | ⚠️ No onError handler |
| 251-256 | Fallback logo rendering | ❌ **BROKEN** - incompatible approach |
| 406-411 | Logo section styling | ✅ Styles correct |

### Backend API Investigation

**File:** `wsp-mobile/lib/site.php`
- **Lines 11-20:** `get_site_logo()` method
- **Line 99:** Logo field included in API response

**API Behavior:**
1. Checks for `mobileLogo` field on site
2. If file exists, returns `$file->toCDNFile()->url()`
3. Returns `null` if no logo or file doesn't exist

**CMS Configuration (ws-ffci site):**
- **File:** `content/site.txt` line 136
- **Value:** `Mobilelogo: - file://xYEJWsj9KFipE9rA`
- **File exists:** `content/logo-mobile.svg` (19,251 bytes)
- **Metadata:** `content/logo-mobile.svg.txt`
- **CDN URL:** `https://ffci-5q.b-cdn.net/image/logo-mobile.svg`
- **Blueprint:** `wsp-mobile/blueprints/tabs/mobile.yml` lines 37-42

**Conclusion:** The API SHOULD be returning `https://ffci-5q.b-cdn.net/image/logo-mobile.svg` for the FFCI site.

### Critical Issue #1: SVG Rendering Has No Error Handling

**Lines 237-242:**
```tsx
<SvgUri
  uri={logoUrl}
  width={logoWidth}
  height={logoHeight}
  style={styles.logo}
/>
```

**Problem:**
- `SvgUri` can fail silently if:
  - Network request fails
  - SVG parsing fails
  - CORS issues
  - URL is invalid
  - CDN is unreachable
- **NO `onError` prop or error boundary**
- **NO fallback to raster format or placeholder**
- **NO loading state**

**Impact:** If the CDN SVG fails to load for any reason, the user sees a blank space where the logo should be.

### Critical Issue #2: Fallback Logo Rendering is Fundamentally Broken

**Lines 61 & 251-256:**
```tsx
// Line 61
const fallbackLogoPath = require('../assets/ffci-logo.svg');

// Lines 251-256
<Image
  source={fallbackLogoPath}
  style={[styles.logo, { width: logoWidth, height: logoHeight }]}
  resizeMode="contain"
  accessibilityLabel="Firefighters for Christ Logo"
/>
```

**Problem:**
- `metro.config.js` uses `react-native-svg-transformer` (line 8)
- SVG files are configured as **source files**, not **asset files** (line 14)
- `require('../assets/ffci-logo.svg')` returns a **React component**, not an image source
- React Native's `Image` component **cannot render React components**
- This will fail silently - no error, no logo

**Correct Approach with SVG Transformer:**
```tsx
// Import SVG as component
import FallbackLogo from '../assets/ffci-logo.svg';

// Render as component
<FallbackLogo width={logoWidth} height={logoHeight} />
```

**However:** The code needs dynamic switching between API logo and fallback, so imports need to be conditional or always available.

### Metro Configuration Analysis

**File:** `rn-mip-app/metro.config.js`
```js
config.transformer = {
  babelTransformerPath: require.resolve('react-native-svg-transformer'),
};

config.resolver = {
  assetExts: config.resolver.assetExts.filter((ext) => ext !== 'svg'),
  sourceExts: [...config.resolver.sourceExts, 'svg'],
};
```

**Implication:** All SVG files are transformed into React components at build time. The `Image` component approach for SVG is incompatible.

### Root Cause Analysis

**Most Likely Scenario:**

1. ✅ API returns logo URL: `https://ffci-5q.b-cdn.net/image/logo-mobile.svg`
2. ✅ HomeScreen correctly extracts URL into `logoUrl`
3. ✅ Detects `.svg` extension → `isSvgLogo = true`
4. ❌ `SvgUri` attempts to fetch SVG from CDN
5. ❌ **SVG fetch/render fails** (network issue, CORS, CDN problem, parsing error)
6. ❌ **No error handling** → renders nothing
7. ❌ No fallback mechanism → user sees blank space

**Alternative Scenario (if API returns null):**

1. ⚠️ API returns `null` for logo (file missing or deleted)
2. ✅ `logoUrl` becomes `null`
3. ✅ Fallback path triggers (line 251)
4. ❌ `require()` returns React component, not image source
5. ❌ `Image` component cannot render component → **fails silently**
6. ❌ User sees blank space

**Conclusion:** Either way, the user sees nothing. The code has no error handling in the success path and a broken fallback path.

### Android Reference Implementation

**File:** `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/screens/HomeScreen.kt`
**Lines:** 115-181

**Key Differences:**
- Uses `SubcomposeAsyncImage` with explicit loading/error/success states
- Shows site title text as fallback if image fails
- Has proper error handling throughout
- Network failures don't result in blank space

**Lesson:** Need explicit error handling and text fallback.

### Implementation Plan

**Step 1: Add Error Handling to SvgUri (Priority: HIGH)**
- **Location:** Lines 237-242
- **Action:** Wrap `SvgUri` in error boundary or add state-based error handling
- **Fallback:** Switch to text-based logo (site title) or PNG fallback

**Step 2: Fix Fallback Logo Rendering (Priority: HIGH)**
- **Location:** Lines 61 & 251-256
- **Option A:** Import SVG as component at top of file:
  ```tsx
  import FallbackLogo from '../assets/ffci-logo.svg';
  ```
  Then render conditionally as component instead of via Image
- **Option B:** Convert `assets/ffci-logo.svg` to PNG format
- **Option C:** Use `SvgUri` with local file path (if supported)
- **Recommendation:** Option A (cleanest, maintains vector quality)

**Step 3: Add Debugging Logs (Priority: MEDIUM)**
- **Location:** After lines 52, 58, 181
- **Action:** Log values to verify data flow:
  ```tsx
  console.log('[Logo] site_data.logo:', site_data.logo);
  console.log('[Logo] logoUrl:', logoUrl);
  console.log('[Logo] isSvgLogo:', isSvgLogo);
  ```

**Step 4: Add Loading State (Priority: LOW)**
- Show placeholder or skeleton while logo loads
- Improves perceived performance

**Step 5: Add Network Error Fallback (Priority: MEDIUM)**
- If SvgUri fails, show site title text instead
- Ensures users always see *something* branded

**Step 6: Verify API Response (Priority: HIGH - FIRST STEP)**
- Check actual API response in dev environment
- Confirm logo URL is being returned
- Verify URL is reachable from device/emulator

### Code Locations

| File | Lines | Purpose | Change Needed? |
|------|-------|---------|----------------|
| `rn-mip-app/components/HomeScreen.tsx` | 1 | Add SVG component import | ✅ YES - import fallback SVG as component |
| `rn-mip-app/components/HomeScreen.tsx` | 54-58 | Logo URL extraction | ⚠️ Add debug logging |
| `rn-mip-app/components/HomeScreen.tsx` | 61 | Fallback logo reference | ❌ REMOVE - incompatible with transformer |
| `rn-mip-app/components/HomeScreen.tsx` | 181 | SVG detection | ✅ NO CHANGE - logic correct |
| `rn-mip-app/components/HomeScreen.tsx` | 237-242 | SVG logo rendering | ✅ YES - add error handling + fallback |
| `rn-mip-app/components/HomeScreen.tsx` | 244-248 | Raster logo rendering | ⚠️ Add onError handler (lower priority) |
| `rn-mip-app/components/HomeScreen.tsx` | 251-256 | Fallback rendering | ✅ YES - rewrite to use component instead of Image |

### Files That DON'T Need Changes

| File | Reason |
|------|--------|
| `rn-mip-app/lib/api.ts` | TypeScript interface correct; API client working |
| `rn-mip-app/lib/config.ts` | Config structure fine; no changes needed |
| `rn-mip-app/metro.config.js` | SVG transformer correctly configured |
| `wsp-mobile/lib/site.php` | Backend logic correct; returns CDN URL properly |
| `content/site.txt` | Logo reference exists and is valid |
| `content/logo-mobile.svg` | Logo file exists and is valid SVG |
| `rn-mip-app/components/HomeScreen.tsx` lines 18-36 | CustomHeader uses different logo (header icon) |
| `rn-mip-app/components/HomeScreen.tsx` lines 406-411 | Logo section styles are correct |

### Variables/Data Reference

| Variable | Type | Source | Purpose |
|----------|------|--------|---------|
| `site_data.logo` | `string \| null` | API response | Logo URL from CMS/API (line 39 in api.ts) |
| `logoUrl` | `string \| null` | Computed (line 54) | Processed logo URL (absolute or with base prepended) |
| `isSvgLogo` | `boolean` | Computed (line 181) | True if logoUrl ends with `.svg` |
| `fallbackLogoPath` | `any` | require() (line 61) | **BROKEN** - Returns React component, not image |
| `logoWidth` | `number` | Computed (line 65) | Responsive width: 60% of screen, 200-280px |
| `logoHeight` | `number` | Computed (line 66) | Height = width * 0.6 (5:3 aspect ratio) |
| `config.apiBaseUrl` | `string` | config.ts | Base URL for API (e.g., `https://ffci.fiveq.dev`) |

### Testing Strategy

**1. Verify API Response (FIRST):**
```bash
# Test from command line
curl -H "X-API-Key: <key>" https://ffci.fiveq.dev/mobile-api | jq '.site_data.logo'

# Expected: "https://ffci-5q.b-cdn.net/image/logo-mobile.svg"
```

**2. Test CDN Accessibility:**
```bash
# Verify CDN URL is reachable
curl -I https://ffci-5q.b-cdn.net/image/logo-mobile.svg

# Expected: HTTP 200 with Content-Type: image/svg+xml
```

**3. Add Debug Logging:**
- Check metro bundler logs for logo URL value
- Verify SvgUri is receiving correct URL
- Check for network errors or SVG parsing errors

**4. Test Error Paths:**
- Disconnect network → verify fallback appears
- Temporarily break CDN URL → verify fallback works
- Set API logo to null in CMS → verify fallback shows

**5. Visual Verification:**
- Logo appears in light gray section on homescreen
- Logo is properly sized (60% width, 200-280px)
- Logo maintains aspect ratio

### Estimated Complexity

**HIGH Complexity** (revised from Medium)

**Reasoning:**
- Two critical bugs identified (SVG error handling + fallback broken)
- Requires understanding React Native SVG transformer behavior
- Need to refactor fallback rendering approach
- Must add comprehensive error handling
- Testing requires API access and network simulation
- May need to handle edge cases (CDN down, CORS issues, etc.)

**Estimated Effort:**
- API verification & debugging: 30-45 min
- Refactor fallback logo rendering: 30-45 min
- Add error handling to SvgUri: 30-45 min
- Add logging & debug support: 15-30 min
- Testing on both platforms: 30-45 min
- **Total: 2.5-3.5 hours**

**Risk Level:** Medium
- Changes are localized to logo rendering
- Error handling additions are low-risk
- Fallback refactor needs careful testing
- No backend changes required
- Won't break existing functionality (already broken)

### Recommendations

1. **Immediate Action:** Add debug logging to verify what API is returning
2. **Primary Fix:** Add error handling to SvgUri with text fallback
3. **Secondary Fix:** Refactor fallback logo to use SVG component import
4. **Nice-to-have:** Add loading state for better UX
5. **Long-term:** Consider using same image loading library as Android (Coil equivalent)
