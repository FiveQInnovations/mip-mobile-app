---
status: backlog
area: ios-mip-app
phase: core
created: 2026-01-24
---

# iOS Resources Page Opens Browser Instead of Rendering HTML

## Context

When navigating to the Resources tab/page in the iOS app, instead of displaying the rendered HTML content within the app, it opens the web browser. The HTML content should be rendered in-app using the `HtmlContentView` component with `WKWebView`.

## Problem

The Resources page (and potentially other pages with HTML content) is triggering browser navigation instead of rendering the HTML content inline within the app's `TabPageView`.

## Goals

1. Resources page should display rendered HTML content within the app
2. HTML content should be styled and formatted correctly
3. Links within HTML should navigate appropriately (internal links in-app, external links in browser)
4. No browser should open when viewing Resources page content

## Acceptance Criteria

- Tapping Resources tab shows HTML content rendered in-app
- HTML is properly styled with CSS
- Images load correctly within the HTML content
- Internal page links navigate within the app
- External links open in browser (as expected)
- Form pages open in browser (as expected)
- No browser opens when initially loading Resources page

## Technical Notes

- Issue likely in `HtmlContentView.swift` navigation delegate
- May be incorrectly handling initial page load or base URL navigation
- Check `WKNavigationDelegate.decidePolicyFor` implementation
- Verify `baseURL` handling in `loadHTMLString`
- May need to allow initial navigation but intercept subsequent navigations

## Related Files

- `ios-mip-app/FFCI/Views/HtmlContentView.swift`
- `ios-mip-app/FFCI/Views/TabPageView.swift`

---

## Research Findings (Scouted)

### Root Cause Analysis

**Problem:** The iOS `HtmlContentView` opens the browser when initially loading HTML content because the `WKNavigationDelegate.decidePolicyFor` method treats the initial page load the same as a user clicking a link.

**Location:** `ios-mip-app/FFCI/Views/HtmlContentView.swift` lines 84-126

**Specific Issue:**
1. When `loadHTMLString` is called (line 27, 34), it triggers a navigation action
2. The navigation delegate `decidePolicyFor` is called for ALL navigations (line 84)
3. The fallback case (lines 124-125) opens EVERYTHING in the browser:
   ```swift
   // Internal non-UUID links - open in browser
   UIApplication.shared.open(url)
   decisionHandler(.cancel)
   ```
4. The initial HTML load from `loadHTMLString` falls through to this case and opens browser

### Cross-Platform Reference

#### Android Implementation (CORRECT PATTERN)

File: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`

**Key differences:**
- Uses `shouldOverrideUrlLoading()` (line 273) which is ONLY called for user-initiated navigation
- NOT called for initial `loadDataWithBaseURL()` (line 362)
- Returns `true` when handling navigation (opening browser/in-app nav)
- Returns `false` to let WebView handle it normally

**Android navigation handling logic (lines 273-359):**
1. Extract `/page/{uuid}` links → navigate in-app
2. Form pages (`/prayer-request`, etc.) → open browser
3. External links (different domain) → open browser
4. Other internal links → open browser
5. **Initial page load is NEVER intercepted**

#### React Native Implementation (DIFFERENT APPROACH)

File: `rn-mip-app/components/HTMLContentRenderer.tsx`

**Key differences:**
- Uses `react-native-render-html` library (NOT WebView)
- Renders HTML as native React components
- Link handling via custom `a` tag renderer (line 173)
- No initial load issue since it's not using WebView navigation

### iOS Fix Strategy

The iOS `WKNavigationDelegate.decidePolicyFor` is called for ALL navigation types. We need to check `navigationAction.navigationType` to differentiate:

**Navigation Types:**
- `.other` → Initial page load (should ALLOW)
- `.linkActivated` → User clicked a link (should INTERCEPT and handle)
- `.formSubmitted`, `.backForward`, etc. → Other types

**Required Change:** Add check at the start of the delegate method:

```swift
func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    // Allow initial page load and non-link navigations
    if navigationAction.navigationType != .linkActivated {
        decisionHandler(.allow)
        return
    }
    
    // Rest of existing link handling logic...
}
```

### Implementation Plan

#### Step 1: Fix HtmlContentView.swift navigation delegate
**File:** `ios-mip-app/FFCI/Views/HtmlContentView.swift`  
**Line:** 84 (start of `decidePolicyFor` method)

Add navigation type check before existing logic:
- Allow `.other` (initial load) and non-link navigation types
- Only process link handling for `.linkActivated` type
- Keep all existing link handling logic (UUID extraction, forms, external links)

#### Step 2: Test Resources page
- Navigate to Resources tab
- Verify HTML content renders in-app
- Verify links within HTML work correctly:
  - Internal `/page/{uuid}` links → navigate in-app
  - Form links → open browser
  - External links → open browser

#### Step 3: Verify other HTML pages
- Check other pages with HTML content (Home, About, etc.)
- Ensure no regressions in existing functionality

### Code Locations

| File | Lines | Purpose | Change Needed |
|------|-------|---------|---------------|
| `ios-mip-app/FFCI/Views/HtmlContentView.swift` | 84-86 | Start of navigation delegate | Add navigation type check |
| `ios-mip-app/FFCI/Views/HtmlContentView.swift` | 27, 34 | loadHTMLString calls | No change - these trigger the navigation |
| `ios-mip-app/FFCI/Views/HtmlContentView.swift` | 94-126 | Link handling logic | No change - keep existing logic |
| `ios-mip-app/FFCI/Views/TabPageView.swift` | 49-53 | HtmlContentView usage | No change - works correctly |

### Reference Implementation

**Android equivalent (working correctly):**
```kotlin
// android-mip-app/.../HtmlContent.kt:273-359
override fun shouldOverrideUrlLoading(
    view: WebView?,
    request: WebResourceRequest?
): Boolean {
    // This method is ONLY called for user clicks, not initial load
    // Return true to handle navigation, false to let WebView handle it
}
```

**iOS fix pattern:**
```swift
// ios-mip-app/FFCI/Views/HtmlContentView.swift:84
func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    // NEW: Filter out initial page load
    if navigationAction.navigationType != .linkActivated {
        decisionHandler(.allow)
        return
    }
    
    // EXISTING: Handle user-clicked links (no changes needed)
    guard let url = navigationAction.request.url else {
        decisionHandler(.allow)
        return
    }
    // ... rest of existing logic
}
```

### Estimated Complexity

**Low** - Simple fix, well-understood problem

**Reasoning:**
- Root cause is clearly identified (line 84-126)
- Fix is a single conditional check (3 lines of code)
- Android app demonstrates correct pattern
- No changes needed to calling code
- Existing link handling logic is correct
- Testing is straightforward (navigate to Resources tab)

### Testing Checklist

- [ ] Resources tab displays HTML content in-app (not browser)
- [ ] HTML styling renders correctly
- [ ] Images load within HTML content
- [ ] Internal `/page/{uuid}` links navigate in-app
- [ ] Form links open in browser
- [ ] External links open in browser
- [ ] No regressions on other HTML pages (Home, About, etc.)
