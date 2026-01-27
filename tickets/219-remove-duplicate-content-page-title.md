---
status: backlog
area: ios-mip-app
phase: core
created: 2026-01-26
---

# Remove Duplicate Title on Content Pages

## Context

Content pages currently display the page title twice:
1. In the navigation bar (via `.navigationTitle()`)
2. As a large title in the content area (via `Text()` with `.font(.title)`)

This creates visual redundancy and wastes vertical screen space. The title should appear only once.

## Goals

1. Remove the duplicate title from the content area
2. Keep the title in the navigation bar (standard iOS pattern)
3. Improve screen space utilization

## Acceptance Criteria

- Page title appears only once (in the navigation bar)
- Large title text is removed from the content area (lines 48-52 in `TabPageView.swift`)
- Navigation bar title remains functional and visible
- Content area starts directly with HTML content or other page elements
- Visual spacing is adjusted appropriately after title removal

## Notes

- **Decision:** Keep navigation bar title, remove content area title
  - Navigation bar title is standard iOS pattern
  - Saves vertical screen space
  - Provides consistent navigation context
  - Title remains visible when scrolling content
  
- Current implementation in `ios-mip-app/FFCI/Views/TabPageView.swift`:
  - Lines 48-52: Large title in content (`Text(pageData.title)` with `.font(.title)`)
  - Lines 92-93: Navigation bar title (`.navigationTitle(pageData.title)`)

- After removal, content area should start with:
  - HTML content (if present)
  - Or other page elements (audio player, collection children, etc.)
  - Padding/spacing may need adjustment after removing title padding

## References

- Implementation: `ios-mip-app/FFCI/Views/TabPageView.swift` (lines 48-52, 92-93)

---

## Research Findings (Scouted)

### Cross-Platform Reference

**Android has the IDENTICAL issue!** 

Android `TabScreen.kt` (lines 192-197) also displays a duplicate title in the content area, even when a TopAppBar is present:

```kotlin
Text(
    text = pageData!!.title,
    style = MaterialTheme.typography.headlineMedium,
    fontWeight = FontWeight.Bold,
    modifier = Modifier.padding(start = 16.dp, end = 16.dp, top = 24.dp, bottom = 16.dp)
)
```

Android's TopAppBar (lines 132-153) shows the title when `canGoBack = true`, creating the same duplication.

**Key difference:** Android's title is always shown in content, regardless of back button state. iOS shows both at all times due to `.navigationTitle()`.

### Current Implementation Analysis

**iOS TabPageView.swift:**

Lines 48-52: Duplicate title in content area (NEEDS REMOVAL)
```swift
Text(pageData.title)
    .font(.title)
    .fontWeight(.bold)
    .padding(.horizontal, 16)
    .padding(.top, 24)
```

Line 92: Navigation title (CORRECT - KEEP THIS)
```swift
.navigationTitle(pageData.title)
```

Line 93: Title display mode set to `.inline` (compact header style)

**Content flow after title removal:**
- Line 46: VStack with `spacing: 16` and `alignment: .leading`
- Line 55: First element will become HTML content (if present)
- Line 64: HTML has `.padding(.horizontal, 0)` - uses full width
- Line 69: Audio player (if audio item) with `.padding(.horizontal, 16)`
- Line 81: Collection list (if collection type)

### Implementation Plan

**Step 1: Remove duplicate title block**
- Delete lines 48-52 in `TabPageView.swift`
- This includes the `Text(pageData.title)` and all its modifiers

**Step 2: Adjust spacing for first content element**
- Option A: Add top padding to the VStack (line 46)
- Option B: Add top padding to HTML content (line 56)
- Option C: Leave as-is and rely on VStack's existing spacing (16pt)

**Recommendation:** Add `.padding(.top, 16)` to the HtmlContentView (line 56-62) to maintain consistent spacing at the top of the content area.

**Step 3: Verify visual spacing**
- Test with pages that have HTML content
- Test with audio-only pages (no HTML)
- Test with collection pages

### Code Locations

| File | Lines | Purpose | Action |
|------|-------|---------|--------|
| `ios-mip-app/FFCI/Views/TabPageView.swift` | 48-52 | Duplicate title in content | **DELETE** |
| `ios-mip-app/FFCI/Views/TabPageView.swift` | 92 | Navigation title | **KEEP** |
| `ios-mip-app/FFCI/Views/TabPageView.swift` | 56-66 | HTML content view | **ADD** `.padding(.top, 16)` |
| `ios-mip-app/FFCI/Views/TabPageView.swift` | 46 | VStack container | No changes needed |
| `ios-mip-app/FFCI/Views/SearchView.swift` | 128 | Uses TabPageView as destination | No changes needed |
| `ios-mip-app/FFCI/Views/HtmlContentView.swift` | N/A | HTML renderer component | No changes needed |

### Other Views Analysis

**No other views affected:**
- `SearchView.swift`: Uses custom header, not `.navigationTitle()`
- `HomeView.swift`: Uses custom logo header
- `CollectionListView.swift`: Component only, not a screen
- Other views: Components or don't show page titles

**TabPageView is the ONLY view using `.navigationTitle()`** (confirmed via grep search).

### Test Impact

**Maestro tests reviewed:**
- `ticket-214-about-us-back-button-ios.yaml`: Tests back button visibility, not title
- `chaplain-resources-opens-ios.yaml`: Tests page content, not title specifically
- No tests currently verify title rendering behavior

**No test updates required** - existing tests focus on navigation and content, not title duplication.

### Variables/Data Reference

- `pageData: PageData?` - State variable containing page metadata
- `pageData.title: String` - Page title text
- `htmlContent: String?` - HTML content (optional)
- `isAudioItem: Bool` - Flag for audio content
- `effectivePageType: String` - Page type ("collection", "audio", etc.)

### Estimated Complexity

**LOW**

**Justification:**
- Single-line deletion (remove lines 48-52)
- Simple spacing adjustment (add one padding modifier)
- No state management changes
- No API changes
- No test updates required
- Pattern is clear from Android implementation

**Risk factors:**
- Spacing may need fine-tuning after visual inspection
- Audio-only pages may need different spacing than HTML pages
- Could be addressed with conditional padding if needed
