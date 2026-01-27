---
status: backlog
area: ios-mip-app
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

## Research Findings (Scouted) - iOS Swift Implementation

### Executive Summary

**Root Cause Identified:** The iOS app is **missing the dedicated logo section entirely**. The current implementation only displays the logo in the header (via `HomeHeaderView`), but the design requires a separate, prominent logo section below the header - matching the React Native and Android implementations.

**Critical Discovery:** This is a **missing feature**, not a broken feature. The logo section needs to be added to `HomeView.swift`.

### Architecture Comparison

**React Native Layout (rn-mip-app/components/HomeScreen.tsx):**
1. CustomHeader with small icon (lines 18-36) - NOT from API
2. **Logo Section (lines 234-258)** - Large API logo, light gray background
3. Featured section (line 261+)
4. Resources section (line 279+)

**Android Layout (android-mip-app/.../HomeScreen.kt):**
1. Small header icon (lines 80-112)
2. **Logo Section (lines 115-181)** - Large API logo, light gray background
3. Featured section (line 184+)
4. Resources section (line 234+)

**iOS Current Layout (ios-mip-app/FFCI/Views/HomeView.swift):**
1. HomeHeaderView with API logo (line 50)
2. Featured section (line 53+)
3. Resources section (line 58+)
4. **❌ MISSING: Dedicated logo section**

### Current Implementation Analysis

**File: `ios-mip-app/FFCI/Views/HomeView.swift`**

| Lines | Component | Status |
|-------|-----------|--------|
| 13-91 | `HomeView` main struct | ✅ Structure is correct |
| 50 | `HomeHeaderView` call | ✅ Header rendered |
| 53-55 | Featured section | ✅ Correct positioning |
| 58-64 | Resources section | ✅ Correct positioning |
| N/A | **Logo section** | ❌ **MISSING** - needs to be added after header |

**File: `ios-mip-app/FFCI/Views/HomeHeaderView.swift`**

| Lines | Purpose | Status |
|-------|---------|--------|
| 10-55 | Header view with logo and search | ⚠️ Currently shows API logo in header |
| 17-34 | Logo rendering logic | ⚠️ This should be in a separate logo section |
| 22-29 | AsyncImage for logo | ✅ Image loading logic is correct |
| 30-34 | Fallback to site title | ✅ Good fallback strategy |

**Note:** The header is currently displaying the main logo, but ticket 217 indicates the header should show a small Maltese cross icon instead.

**File: `ios-mip-app/FFCI/API/ApiModels.swift`**

| Lines | Purpose | Status |
|-------|---------|--------|
| 65-79 | `SiteMeta` model | ✅ Contains `logo: String?` field |
| 68 | Logo property | ✅ API model correct |

**File: `ios-mip-app/FFCI/API/MipApiClient.swift`**

| Lines | Purpose | Status |
|-------|---------|--------|
| 54-90 | `getSiteData()` method | ✅ API client working |
| 23-24 | Base URL and API key | ✅ Configured correctly |

### Android Reference Implementation

The Android app has the logo section correctly implemented at lines 115-181 of `HomeScreen.kt`:

```kotlin
// Logo section (iOS-style: light gray background, centered responsive logo)
item {
    val configuration = LocalConfiguration.current
    val screenWidthDp = configuration.screenWidthDp.dp
    
    // Responsive logo size: 60% of screen width, max 280dp, min 200dp
    val logoWidth = remember(screenWidthDp) {
        val calculatedWidth = screenWidthDp * 0.6f
        calculatedWidth.coerceIn(200.dp, 280.dp)
    }
    // Maintain 5:3 aspect ratio (like iOS)
    val logoHeight = logoWidth * 0.6f
    
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .background(Color(0xFFF8FAFC)) // Light gray background
            .padding(vertical = 20.dp, horizontal = 20.dp),
        contentAlignment = Alignment.Center
    ) {
        if (siteMeta.logo != null) {
            val logoUrl = if (siteMeta.logo.startsWith("http://") || siteMeta.logo.startsWith("https://")) {
                siteMeta.logo
            } else {
                "https://ffci.fiveq.dev${siteMeta.logo}"
            }
            
            SubcomposeAsyncImage(
                model = logoUrl,
                contentDescription = siteMeta.title,
                modifier = Modifier
                    .width(logoWidth)
                    .height(logoHeight),
                contentScale = ContentScale.Fit
            ) {
                when (painter.state) {
                    is AsyncImagePainter.State.Loading -> {
                        // Show nothing while loading
                    }
                    is AsyncImagePainter.State.Error -> {
                        // Fallback to site title if logo fails
                        Text(
                            text = siteMeta.title,
                            style = MaterialTheme.typography.headlineMedium,
                            fontWeight = FontWeight.Bold
                        )
                    }
                    else -> {
                        SubcomposeAsyncImageContent()
                    }
                }
            }
        } else {
            // No logo URL - show site title
            Text(
                text = siteMeta.title,
                style = MaterialTheme.typography.headlineMedium,
                fontWeight = FontWeight.Bold
            )
        }
    }
}
```

**Key Features:**
- Light gray background: `Color(0xFFF8FAFC)` (corresponds to SwiftUI `Color(red: 0.973, green: 0.980, blue: 0.988)`)
- Responsive sizing: 60% of screen width, clamped between 200-280 points
- Aspect ratio: 5:3 (height = width × 0.6)
- Error handling: Falls back to site title text
- Loading state: Shows nothing while loading (no placeholder)

### Backend API Verification

**API Endpoint:** `https://ffci.fiveq.dev/mobile-api`
**Expected Response:** JSON with `site_data.logo` field

The backend is configured correctly:
- **File:** `wsp-mobile/lib/site.php` lines 11-20
- **Method:** `get_site_logo()` returns CDN URL or null
- **CMS:** Logo exists at `content/logo-mobile.svg` (19,251 bytes)
- **CDN URL:** `https://ffci-5q.b-cdn.net/image/logo-mobile.svg`

The API is working correctly - the issue is purely on the iOS frontend.

### Implementation Plan

**Step 1: Create New Logo Section View Component (Recommended)**
- **Action:** Create `HomeLogoView.swift` in `ios-mip-app/FFCI/Views/`
- **Purpose:** Dedicated component for logo section (matches Android's modular approach)
- **Content:** Logo rendering with responsive sizing, light gray background, error handling

**Step 2: Alternative - Add Logo Section Inline in HomeView**
- **Location:** `ios-mip-app/FFCI/Views/HomeView.swift` after line 50 (after HomeHeaderView)
- **Action:** Add logo section VStack/Box with styling
- **Simpler but less modular**

**Step 3: Implement Logo Rendering Logic**
- **URL Processing:** Check if logo starts with `http://` or `https://`, otherwise prepend base URL
- **Image Loading:** Use `AsyncImage` with placeholder and error handling
- **Responsive Sizing:** 
  - Width: `min(max(screenWidth * 0.6, 200), 280)`
  - Height: `logoWidth * 0.6`
- **Fallback:** Show site title as Text if logo is null or fails to load

**Step 4: Add Background Styling**
- **Background Color:** Light gray `#F8FAFC` (SwiftUI: `Color(red: 0.973, green: 0.980, blue: 0.988)`)
- **Padding:** Vertical 20pt, horizontal 20pt
- **Alignment:** Center

**Step 5: Update HomeView to Include Logo Section**
- **Location:** Between HomeHeaderView (line 50) and Featured section (line 53)
- **Action:** Add logo section component or inline VStack

**Step 6: Testing**
- Build and run on iOS simulator
- Verify logo appears in light gray section
- Test logo sizing on different screen sizes
- Test error case (disconnect network, verify site title appears)

### Code Locations - Changes Needed

| File | Lines | Change Needed |
|------|-------|---------------|
| **NEW FILE** `ios-mip-app/FFCI/Views/HomeLogoView.swift` | N/A | ✅ **CREATE** - New component for logo section |
| `ios-mip-app/FFCI/Views/HomeView.swift` | After line 50 | ✅ **ADD** - Call to HomeLogoView after HomeHeaderView |
| `ios-mip-app/FFCI/Views/HomeView.swift` | 13 | ⚠️ **UPDATE** - Pass siteMeta to component (already passed) |

### Files That DON'T Need Changes

| File | Reason |
|------|--------|
| `ios-mip-app/FFCI/API/ApiModels.swift` | API models already correct; `SiteMeta.logo` exists |
| `ios-mip-app/FFCI/API/MipApiClient.swift` | API client working correctly |
| `ios-mip-app/FFCI/ContentView.swift` | App initialization correct |
| `ios-mip-app/FFCI/Views/HomeHeaderView.swift` | No changes needed for THIS ticket (ticket 217 will update header) |
| `ios-mip-app/FFCI/Views/FeaturedSectionView.swift` | Featured section correct |
| `ios-mip-app/FFCI/Views/ResourcesScrollView.swift` | Resources section correct |

### Implementation Details - Swift Code Structure

**Recommended Approach: Create `HomeLogoView.swift`**

```swift
import SwiftUI

struct HomeLogoView: View {
    let siteMeta: SiteMeta
    
    var body: some View {
        GeometryReader { geometry in
            // Responsive logo sizing
            let screenWidth = geometry.size.width
            let logoWidth = min(max(screenWidth * 0.6, 200), 280)
            let logoHeight = logoWidth * 0.6
            
            VStack {
                if let logo = siteMeta.logo {
                    let logoUrl = logo.starts(with: "http://") || logo.starts(with: "https://")
                        ? logo
                        : "https://ffci.fiveq.dev\(logo)"
                    
                    AsyncImage(url: URL(string: logoUrl)) { phase in
                        switch phase {
                        case .empty:
                            // Loading state - show nothing
                            Color.clear
                                .frame(width: logoWidth, height: logoHeight)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: logoWidth, height: logoHeight)
                        case .failure:
                            // Error state - show site title
                            Text(siteMeta.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 0.059, green: 0.090, blue: 0.164))
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    // No logo - show site title
                    Text(siteMeta.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.059, green: 0.090, blue: 0.164))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 20)
            .background(Color(red: 0.973, green: 0.980, blue: 0.988))
        }
        .frame(height: 200) // Approximate height for layout
    }
}
```

**Update HomeView.swift (after line 50):**

```swift
ScrollView {
    VStack(spacing: 0) {
        
        // Header with logo and search button
        HomeHeaderView(siteMeta: siteMeta, onSearchTap: { showSearch = true })
        
        // ADD THIS: Logo section
        HomeLogoView(siteMeta: siteMeta)
        
        // Featured section
        if let featured = siteMeta.homepageFeatured, !featured.isEmpty {
            FeaturedSectionView(featured: featured, onFeaturedClick: onFeaturedClick)
        }
        
        // ... rest of code
    }
}
```

### Variables/Data Reference

| Variable | Type | Location | Purpose |
|----------|------|----------|---------|
| `siteMeta` | `SiteMeta` | Passed to HomeView | Contains logo URL and site metadata |
| `siteMeta.logo` | `String?` | API response | Logo URL from CMS (CDN URL or relative path) |
| `logoUrl` | `String` | Computed | Absolute URL (with base URL prepended if needed) |
| `logoWidth` | `CGFloat` | Computed | Responsive width: 60% of screen, 200-280pt |
| `logoHeight` | `CGFloat` | Computed | Height = width × 0.6 (5:3 aspect ratio) |
| `siteMeta.title` | `String` | API response | Site title for fallback display |

### Testing Strategy

**1. Build and Run iOS App:**
```bash
cd ios-mip-app
xcodebuild -scheme FFCI -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

**2. Visual Verification:**
- Launch app on simulator
- Verify logo section appears below header
- Check light gray background is visible
- Verify logo is centered and properly sized
- Test on different screen sizes (iPhone SE, iPhone 15 Pro Max)

**3. Network Error Testing:**
- Run app
- Disconnect network or use invalid logo URL
- Verify site title appears as fallback (not blank space)

**4. API Response Verification:**
```bash
curl -u "fiveq:demo" -H "X-API-Key: 777359235aecc10fdfb144041dfdacfc80ca0751c7bed7b14c96f935456fc4ce" \
  https://ffci.fiveq.dev/mobile-api | jq '.site_data.logo'

# Expected: "https://ffci-5q.b-cdn.net/image/logo-mobile.svg"
```

**5. Maestro Test (Optional):**
Create test to verify logo section exists and is visible.

### Estimated Complexity

**MEDIUM Complexity**

**Reasoning:**
- Straightforward feature addition (not a complex bug fix)
- Well-defined requirements from Android/RN reference implementations
- AsyncImage is a standard SwiftUI component (no third-party dependencies)
- Responsive sizing logic is simple arithmetic
- Error handling is built into AsyncImage's phase-based rendering

**Estimated Effort:**
- Create HomeLogoView component: 30-45 min
- Integrate into HomeView: 15 min
- Test on simulator: 15-30 min
- Visual QA and adjustments: 15-30 min
- **Total: 1.25-2 hours**

**Risk Level:** Low
- Pure additive change (not modifying existing code)
- Well-isolated component
- Error handling built-in
- No backend changes required
- Easy to test and verify visually

### Recommendations

1. **Recommended Approach:** Create separate `HomeLogoView.swift` component (cleaner, more maintainable)
2. **Alternative:** Add inline to HomeView (faster but less modular)
3. **Color Consistency:** Use same light gray as Android (#F8FAFC)
4. **Error Handling:** Use AsyncImage's phase handling for loading/error states
5. **Fallback:** Show site title text if logo fails (matches Android behavior)
6. **Testing:** Verify on multiple screen sizes and with network errors
