---
status: backlog
area: android-mip-app
phase: core
created: 2026-01-24
---

# Android Internal Page Navigation

## Context

Internal pages may contain buttons or links that should navigate to other internal pages within the app. Currently, tapping these elements may not work or may open external browser instead of in-app navigation.

## Goals

1. Buttons on internal pages should navigate to other internal pages
2. Internal links should use in-app navigation, not external browser
3. External links should still open in browser appropriately

## Acceptance Criteria

- Tapping a button/link to an internal page navigates within the app
- URL-to-route mapping works correctly (e.g., `/about` → About page)
- External links (https://external-site.com) open in browser
- Deep linking support (if applicable)

## Notes

- Requires URL parsing to determine internal vs external
- May need UUID-to-URL mapping from API
- RN implementation had similar challenges (ticket 052)

## References

- Previous tickets: 051 (external links), 052 (internal link mapping), 076 (subpage links)
- `wsp-mobile` API provides page UUID and URL information

---

## Research Findings (Scouted)

### React Native Reference

The RN app implements internal page navigation in `HTMLContentRenderer.tsx` (lines 98-154):

**Key patterns used:**
1. **UUID extraction from URLs**: Regex pattern `/\/page\/([a-zA-Z0-9-]+)/` extracts UUID from `/page/{uuid}` URLs
2. **Internal vs External link detection**: Checks if URL is same domain or relative path
3. **Form page detection**: Special handling for form pages (prayer-request, chaplain-request, /forms/) to always open in browser
4. **Navigation callback**: Uses `onNavigate` callback passed to component, or `router.push()` for internal navigation
5. **External link handling**: Uses `Linking.openURL()` to open external links in browser

**Data flow:**
- Server-side transformation: `wsp-mobile` API already transforms internal links to `/page/{uuid}` format (see `wsp-mobile/lib/pages.php:99-218`)
- Client receives HTML with `/page/{uuid}` links already converted
- Client detects link type and routes accordingly

**Android equivalents:**
- `Linking.openURL()` → `Intent(Intent.ACTION_VIEW, Uri.parse(url))`
- `router.push()` → `onNavigate?.invoke(uuid)` (already exists!)
- Custom anchor renderer with Pressable → Custom WebViewClient (already exists!)

### Current Implementation Analysis

**Files that need changes:**

| File | Current State | Changes Needed |
|------|--------------|----------------|
| `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt` | Lines 195-211 handle links, but blocks ALL external links | Add Intent to open external URLs in browser |
| `android-mip-app/app/build.gradle.kts` | May need permissions | Verify INTERNET permission exists (likely already present) |

**Files that DON'T need changes:**

| File | Why No Changes Needed |
|------|---------------------|
| `TabScreen.kt` | Already passes `onNavigate` callback to HtmlContent (line 214) |
| `NavGraph.kt` | Navigation already configured for `/page/{uuid}` routes (lines 64-71) |
| `ApiModels.kt` | API already provides transformed HTML with `/page/{uuid}` links |
| Backend (`wsp-mobile/lib/pages.php`) | Server already transforms links to `/page/{uuid}` format (lines 99-218) |

### Implementation Plan

#### 1. Add Android Intent imports to HtmlContent.kt
**Location:** `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt` (top of file)

Add:
```kotlin
import android.content.Intent
import android.net.Uri
```

#### 2. Update shouldOverrideUrlLoading in HtmlContent.kt
**Location:** Lines 195-211

Current logic:
- ✅ Detects `/page/{uuid}` links and calls `onNavigate`
- ❌ Blocks ALL other links (return true at line 210)

Need to add before line 210:
```kotlin
// Check for form pages that need browser rendering
val formPaths = listOf("/prayer-request", "/chaplain-request", "/forms/")
if (formPaths.any { url.contains(it) }) {
    try {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
        view?.context?.startActivity(intent)
    } catch (e: Exception) {
        // Handle error
    }
    return true
}

// Check if internal link (same domain or relative)
val baseHost = "ffci.fiveq.dev" // Could be extracted from config
val isInternal = try {
    val uri = Uri.parse(url)
    uri.host == null || uri.host == baseHost || url.startsWith("/")
} catch (e: Exception) {
    false
}

if (!isInternal) {
    // External link - open in browser
    try {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
        view?.context?.startActivity(intent)
    } catch (e: Exception) {
        // Handle error
    }
    return true
}

// Internal non-UUID link - log and block for now
Log.w("HtmlContent", "Internal link not in /page/{uuid} format: $url")
return true
```

#### 3. Add configuration for base URL
**Location:** Could be added to existing config system or hardcoded initially

The app likely already has a config system (used in MipApiClient.kt). Should use the same base URL.

### Variables/Data Reference

**Key variables in HtmlContent.kt:**
- `html: String` - HTML content with links already transformed by server
- `onNavigate: ((String) -> Unit)?` - Callback to navigate to internal pages (already connected!)
- WebViewClient's `shouldOverrideUrlLoading()` - Intercepts all link clicks

**URL patterns to handle:**
- `/page/[uuid]` - Internal page navigation (already works)
- `https://ffci.fiveq.dev/about` - Same domain links (need to detect and transform)
- `https://external-site.com` - External links (need to open in browser)
- `/prayer-request`, `/chaplain-request`, `/forms/*` - Form pages (need to open in browser even if same domain)

### Estimated Complexity

**Medium** - The infrastructure is mostly in place. Need to:
1. Add browser Intent handling (straightforward Android pattern)
2. Add internal vs external link detection logic (port from RN implementation)
3. Handle form page special case (simple string check)
4. Test various link types

Most complex part: Ensuring proper URL parsing and domain detection. However, the server already does most of the heavy lifting by transforming internal links to `/page/{uuid}` format.
