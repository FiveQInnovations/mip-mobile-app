---
status: backlog
area: android-mip-app
phase: core
created: 2026-01-24
---

# Android Prayer Request Form

## Context

The FFCI app needs a prayer request form that allows users to submit prayer requests. In the RN app, this was handled by opening a web form in the browser. For Android, we need to decide on the implementation approach.

## Goals

1. Allow users to submit prayer requests
2. Provide a good user experience (in-app vs browser)

## Acceptance Criteria

- Prayer request option is accessible from the app
- Users can successfully submit a prayer request
- Confirmation feedback after submission
- Form validation for required fields

## Implementation Options

### Option A: Open in Browser (Simple)
- Tap "Prayer Request" opens the web form in external browser
- Pros: Simple, uses existing web form
- Cons: Leaves app context

### Option B: WebView (Middle Ground)
- Open web form in an in-app WebView
- Pros: Stays in app, uses existing form
- Cons: WebView management, back navigation

### Option C: Native Form (Best UX)
- Build native Compose form that submits to API
- Pros: Best UX, native feel
- Cons: Requires API endpoint, more development

## Notes

- RN implementation opened form in browser (ticket 086)
- `wsp-forms` plugin handles form submissions on the Kirby side
- Consider what API endpoint would be needed for native form

## References

- Previous tickets: 017, 086
- `wsp-forms` plugin for backend form handling

---

## Research Findings (Scouted)

### React Native Reference

The RN app implements prayer request submission by opening the web form in an external browser (Safari/Chrome). This approach was chosen because the form requires JavaScript/Vue.js for rendering.

**RN Implementation:**
- Location: `rn-mip-app/components/HTMLContentRenderer.tsx`
- Lines 85-94: `isFormPage()` function checks if URL matches form paths including `/prayer-request`
- Lines 116-122: When link is detected as a form page, uses `Linking.openURL()` to open in external browser
- The app goes to background when browser opens (tested in Maestro)

**Key RN Pattern:**
```typescript
const isFormPage = (url: string): boolean => {
  const formPaths = ['/prayer-request', '/chaplain-request', '/forms/'];
  return formPaths.some(path => url.includes(path));
};

// In link handler:
if (isFormPage(href)) {
  Linking.openURL(href); // Opens in Safari/Chrome
  return;
}
```

**Android Equivalent:**
- `Linking.openURL()` → `Intent(Intent.ACTION_VIEW, Uri.parse(url))` with `context.startActivity()`

### Current Android Implementation Analysis

**WebView Link Handling:**
- File: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`
- Lines 195-211: `shouldOverrideUrlLoading()` handles link clicks in WebView
- Lines 202-207: Internal `/page/uuid` links are handled in-app
- **Line 209-210: External links are currently BLOCKED** with comment: "For now, block external links (could open in browser in future)"

**Current Logic:**
```kotlin
override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
    val url = request?.url?.toString() ?: return false
    
    // Check for internal page links
    val pageMatch = Regex("/page/([a-f0-9-]+)").find(url)
    if (pageMatch != null) {
        val uuid = pageMatch.groupValues[1]
        onNavigate?.invoke(uuid)
        return true
    }
    
    // For now, block external links (could open in browser in future)
    return true // ← BLOCKS all non-internal links
}
```

**TabScreen.kt:**
- File: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/screens/TabScreen.kt`
- Line 214: Passes `onNavigate` callback to `HtmlContent` for internal navigation
- No current handling for external URLs or form pages

### Backend Form Details

**Prayer Request Form Location:**
- URL: `https://ffci.fiveq.dev/prayer-request`
- Form UUID: `iTQ9ZV8UId5Chxew`
- Form definition: `ws-ffci/content/forms/2_prayer-request/form.txt`

**Form Fields (8 fields total):**
1. First Name (text, required)
2. Last Name (text, required)
3. USA State (text, optional)
4. Country (text, optional)
5. Email Address (email, required)
6. Your Prayer Request (textarea, required)
7. Would you like this prayer request sent out to our International prayer team? (select: Yes/No, required)
8. May we include your name in the Prayer request? (select: Yes/No, required)

**Form Submission Process:**
- Handler: `wsp-forms/snippets/form_handler.php`
- Method: POST
- Security: CSRF token, honeypot field, validation (same first/last name check)
- On success: Redirects to `return_url` with `?success=true&fid=prayer-request#response`
- Data saved: Creates entry in `forms/prayer-request/entry-XXXXX/` structure
- Email: Sends notification emails if configured

**API Considerations:**
- No JSON API endpoint exists for form submission
- Forms require web session for CSRF tokens
- Forms use Vue.js/JavaScript for conditional field rendering
- Building native form would require creating new API endpoint

### Implementation Plan

#### Option A: Open in Browser (Recommended - Matches RN)

**Rationale:** Simplest, matches RN behavior, uses existing web form, no backend changes needed.

**Steps:**
1. Modify `HtmlContent.kt` `shouldOverrideUrlLoading()`:
   - Add form path detection (similar to RN's `isFormPage()`)
   - Create Intent with `ACTION_VIEW` for form URLs
   - Keep internal page navigation as-is
   
2. Add helper function to detect form pages:
   - Check if URL contains `/prayer-request`, `/chaplain-request`, or `/forms/`
   - Could be a top-level function or companion object function

**Code Changes Required:**

| File | Lines | Changes |
|------|-------|---------|
| `HtmlContent.kt` | 195-211 | Replace blocking logic with form detection + browser intent |
| `HtmlContent.kt` | 15-20 (top) | Add `isFormPage()` helper function |
| `HtmlContent.kt` | 3-9 (imports) | Add `android.content.Intent`, `android.net.Uri` |

**Pseudocode:**
```kotlin
// At top level
private fun isFormPage(url: String): Boolean {
    val formPaths = listOf("/prayer-request", "/chaplain-request", "/forms/")
    return formPaths.any { url.contains(it) }
}

// In shouldOverrideUrlLoading:
override fun shouldOverrideUrlLoading(...): Boolean {
    val url = request?.url?.toString() ?: return false
    
    // Internal pages
    val pageMatch = Regex("/page/([a-f0-9-]+)").find(url)
    if (pageMatch != null) {
        val uuid = pageMatch.groupValues[1]
        onNavigate?.invoke(uuid)
        return true
    }
    
    // Form pages - open in browser
    if (isFormPage(url)) {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
        view?.context?.startActivity(intent)
        return true
    }
    
    // Other external links - still block for now
    return true
}
```

#### Option B: WebView (Middle Ground)

**Pros:** Stays in-app, uses existing form  
**Cons:** 
- Requires new screen/composable for WebView
- Need to handle navigation back to app
- JavaScript must be enabled (security consideration)
- CSRF/session management more complex

**Changes:**
- New `FormWebViewScreen.kt` composable
- Navigation changes to support form screen route
- Enable JavaScript in dedicated WebView
- Handle successful submission detection

#### Option C: Native Form (Most Complex)

**Pros:** Best UX, native Android feel  
**Cons:**
- Requires new API endpoint in `wsp-forms` plugin
- Must implement all 8 form fields
- Must replicate validation logic
- Must handle CSRF token generation/validation
- Significant backend work required

**Changes:**
- New API endpoint: `POST /api/forms/prayer-request/submit`
- New `PrayerRequestScreen.kt` with form UI
- Form validation logic
- Loading/success/error states
- Backend changes to `wsp-forms` plugin

### Code Locations

| File | Purpose | Changes Needed? |
|------|---------|-----------------|
| `HtmlContent.kt:195-211` | WebView link handler | ✅ YES - Add form detection and browser intent |
| `HtmlContent.kt:1-14` | Imports | ✅ YES - Add Intent and Uri imports |
| `TabScreen.kt:212-216` | HtmlContent usage | ❌ NO - Already passes onNavigate callback |
| `ws-ffci/content/prayer-request/default.txt` | Prayer request page | ❌ NO - Already exists |
| `wsp-forms/snippets/form_handler.php` | Backend form handler | ❌ NO - Already works for web |

### Variables/Data Reference

**Key Constants:**
- Prayer request URL: `https://ffci.fiveq.dev/prayer-request`
- Form paths to detect: `["/prayer-request", "/chaplain-request", "/forms/"]`
- Base URL: `https://ffci.fiveq.dev` (already defined in HtmlContent.kt line 215)

**Android APIs:**
- `Intent.ACTION_VIEW` - Opens URL in default browser
- `Uri.parse(url)` - Converts string URL to Uri
- `context.startActivity(intent)` - Launches browser activity

### Testing Strategy

**Manual Testing:**
1. Navigate to Connect tab in app
2. Scroll to find "Prayer Request" button
3. Tap button
4. Verify browser opens (Chrome/default browser)
5. Verify URL is correct prayer request form
6. Verify app goes to background (optional - Android may handle differently than iOS)

**Maestro Test (Port from RN):**
- Reference: `rn-mip-app/maestro/flows/unstable/prayer-request-opens-browser-ios.yaml`
- Can create Android equivalent with similar flow

### Estimated Complexity

**Option A (Browser):** **LOW** - 1-2 hour implementation
- Simple code change to existing WebView handler
- No new screens or navigation
- No backend changes
- Direct 1:1 port from RN pattern

**Option B (WebView):** **MEDIUM** - 4-6 hours
- New screen composable
- Navigation integration
- Session/auth handling

**Option C (Native):** **HIGH** - 16-20 hours
- New API endpoint (backend)
- Full form UI (8 fields)
- Validation logic
- Error handling
- Testing

**Recommendation:** Implement Option A (Browser) to match RN behavior and achieve feature parity quickly. Can revisit Options B or C later if user feedback indicates need for in-app forms.
