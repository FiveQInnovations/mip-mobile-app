---
status: backlog
area: ios-mip-app
phase: core
created: 2026-03-10
---

# Port Recent Android HtmlContent Fixes to iOS Swift

## Context

Between tickets 242–252, a significant batch of Android HTML rendering fixes landed in
`HtmlContent.kt`. Several of those fixes address problems that exist **identically** in the iOS
counterpart (`HtmlContentView.swift`) because both files share the same CSS/JS strategy for
rendering CMS-sourced HTML.

This ticket is a porting handoff. Each section below maps an Android fix to the iOS gap, with
precise file locations so a dev can work through them without re-doing the investigation.

---

## Research Findings (Scouted)

### Cross-Platform Reference
The Android implementation in `HtmlContent.kt` and `MipApiClient.kt` serves as the primary reference. Both platforms use a `WKWebView` / `WebView` to render CMS-sourced HTML and share the same CSS/JS injection strategy.

### Current Implementation Analysis
- **Issue 1 (Hero Contrast):** `HtmlContentView.swift` lacks the `::before` gradient on `._background` and the JS normalizer to handle different DOM orders of headings and backgrounds.
- **Issue 2 (Internal Links):** `HtmlContentView.swift` currently opens all non-UUID internal links in Safari. `MipApiClient.swift` lacks the `resolvePageUuidByUrl` method.
- **Issue 3 (Iframe CSS):** Missing `display: block` and `margin: 12px 0` in `HtmlContentView.swift`.
- **Issue 4 (Tailwind):** Missing Tailwind utility class stubs in `HtmlContentView.swift`.
- **Issue 5 (srcset):** `HtmlContentView.swift` uses a single-pass regex that applies the first found `srcset` URL to all images with `src=""`.

### Implementation Plan

#### 1. Hero Title Contrast (Issue 1)
- **File:** `ios-mip-app/FFCI/Views/HtmlContentView.swift`
- **CSS Change:** Add `._background::before` gradient and `._hero-heading` styles in `wrapHtml()`.
- **JS Change:** Add `forceHeroHeadingContrast`, `heroBackgroundFirst`, and `heroHeadingFirst` logic to `webView(_:didFinish:)`.

#### 2. Internal Non-UUID Links (Issue 2)
- **File:** `ios-mip-app/FFCI/API/MipApiClient.swift`
- **Action:** Implement `resolvePageUuidByUrl`, `normalizePath`, and `buildResolutionQueries` mirroring the Android logic.
- **File:** `ios-mip-app/FFCI/Views/HtmlContentView.swift`
- **Action:** In `decidePolicyFor`, if a link is internal but not a UUID, call `MipApiClient.shared.resolvePageUuidByUrl`. If resolved, call `onNavigate`.

#### 3. Iframe / Embed Responsive CSS (Issue 3)
- **File:** `ios-mip-app/FFCI/Views/HtmlContentView.swift`
- **Action:** Update `iframe, embed, object` CSS in `wrapHtml()` to include `display: block` and `margin: 12px 0`.

#### 4. Tailwind Utility Classes (Issue 4)
- **File:** `ios-mip-app/FFCI/Views/HtmlContentView.swift`
- **Action:** Add Tailwind stub classes (`.mb-2`, `.mb-4`, etc.) to the CSS block in `wrapHtml()`.

#### 5. Image srcset Fix (Issue 5)
- **File:** `ios-mip-app/FFCI/Views/HtmlContentView.swift`
- **Action:** Replace the single-pass regex in `wrapHtml()` with a loop that iterates over each `<img>` tag and patches it individually.

### Code Locations

| File | Purpose |
|------|---------|
| `ios-mip-app/FFCI/Views/HtmlContentView.swift` | Primary location for CSS, JS, and link handling changes. |
| `ios-mip-app/FFCI/API/MipApiClient.swift` | Add URL-to-UUID resolution logic. |

### Estimated Complexity
**Medium.** While the changes are mostly ports from Android, Issue 2 requires careful async handling in the `WKNavigationDelegate`, and Issue 5 requires a more robust regex/loop approach in Swift.

---

## Issue 1 — Hero Title Contrast (Priority: High)

**Source tickets:** 242, 244, 246

### What Android fixed

Added three layers to `HtmlContent.kt`:

1. **CSS `._background::before` gradient overlay** (lines 409–420) — a `linear-gradient` pseudo-
   element that darkens hero images so white text is readable.
2. **CSS `._hero-heading` class** (lines 455–474) — strong dark plate + `text-shadow` for title
   readability.
3. **JS on `onPageFinished`** — `forceHeroHeadingContrast()` normalises two DOM orderings that
   the CMS produces:
   - `._background + ._heading` (most pages): heading is moved before the background div and
     given `._hero-heading`.
   - `._heading + ._background` (Connect, Media Ministry): heading kept in place, `._hero-heading`
     added in-situ.

### What iOS is missing

`HtmlContentView.swift` `wrapHtml()` CSS block (around line 404) has:

```css
._background { position: relative; width: 100%; min-height: 200px; … }
._background > *:not(picture) { position: relative; z-index: 1; }
```

It has **no** `::before` gradient, no `_hero-heading` class, and the `didFinish` JS block has no
hero-heading DOM manipulation at all.

### What to add to iOS

**In `wrapHtml()` CSS** — after the existing `._background` rules, add:

```css
._background::before {
    content: "";
    position: absolute;
    inset: 0;
    background: linear-gradient(180deg, rgba(15,23,42,0.28) 0%, rgba(15,23,42,0.42) 100%);
    z-index: 1;
    pointer-events: none;
}
._background h1, ._background h2, ._background h3,
._background h4, ._background h5, ._background h6,
._background p, ._background ._heading, ._background ._text {
    color: #ffffff !important;
    text-shadow: 0 2px 6px rgba(15,23,42,0.6);
}
._section ._background + ._heading h1,
._section ._background + ._heading h2,
._section ._background + ._heading h3,
._section ._background + ._heading h4 {
    color: #ffffff !important;
    text-shadow: 0 2px 6px rgba(15,23,42,0.7);
}
._section ._background + ._heading {
    margin-top: 0; margin-bottom: 10px;
    padding: 14px 14px 12px;
    background: rgba(15,23,42,0.72);
    border-radius: 8px; position: relative; z-index: 3;
}
._hero-heading {
    margin-top: 0; margin-bottom: 10px;
    padding: 14px 14px 12px;
    background: rgba(15,23,42,0.72);
    border-radius: 8px; position: relative; z-index: 3;
}
._hero-heading h1, ._hero-heading h2, ._hero-heading h3, ._hero-heading h4 {
    color: #ffffff !important;
    text-shadow: 0 2px 8px rgba(0,0,0,0.84);
}
._hero-heading * {
    color: #ffffff !important;
    text-shadow: 0 2px 8px rgba(0,0,0,0.84);
}
```

**In `Coordinator.webView(_:didFinish:)` JS** — inside the existing `evaluateJavaScript` block,
after the section-color loop, add the hero-heading normaliser. Copy the
`forceHeroHeadingContrast`, `heroBackgroundFirst`, and `heroHeadingFirst` blocks verbatim from
`HtmlContent.kt` lines 779–812 (they are plain JS, identical between platforms).

### Pages to verify

- What We Believe, Connect With Us, Chaplain Resources, FFC Chaplain Program, Chapter
  Resources, FAQ, Media Ministry — all expected to show low contrast on iOS today.

---

## Issue 2 — Internal Non-UUID Links Open in Browser (Priority: High)

**Source ticket:** 252 (in-progress on Android)

### What Android fixed

`shouldOverrideUrlLoading` in `HtmlContent.kt` (lines 968–991): when an internal link is *not*
already in `/page/{uuid}` format, Android now calls `MipApiClient.resolvePageUuidByUrl(fullUrl)`
— a search-backed resolver — to look up the UUID, then navigates in-app. Only if resolution
fails does it fall back to loading in the WebView.

### What iOS is missing

`Coordinator.webView(_:decidePolicyFor:)` line 734:

```swift
// Internal non-UUID links - open in browser
UIApplication.shared.open(url)
decisionHandler(.cancel)
```

iOS sends **all** unresolved internal links to the browser. Any CMS page whose HTML buttons still
carry a site path instead of `/page/{uuid}` (e.g. pages not yet updated on the backend, or edge
cases from wsp-mobile ticket 253) will bounce the user to Safari instead of staying in-app.

### What to add to iOS

1. Add a `resolvePageUuidByUrl(_ url: URL) async -> String?` method to iOS `MipApiClient.swift`
   that mirrors the Android implementation (search-based, path-normalised, cached). The Android
   source is in `MipApiClient.kt` lines 118–187.
2. In the `decidePolicyFor` delegate, replace the final `UIApplication.shared.open(url)` fallback
   with an async resolution attempt, calling `onNavigate` on success and only opening in browser
   on failure.

---

## Issue 3 — Iframe / Embed Responsive CSS (Priority: Medium)

**Source ticket:** 248

### What Android fixed

Added `display: block`, `width: 100% !important`, `max-width: 100% !important`,
`border: 0`, `margin: 12px 0`, and `box-sizing: border-box` to `iframe, embed, object`.

Also enabled `domStorageEnabled = true`, `MIXED_CONTENT_COMPATIBILITY_MODE`, and third-party
cookies on the Android WebView — things WKWebView handles differently and may not need.

### What iOS currently has

```css
iframe, embed, object {
    max-width: 100%;
    width: 100%;
    border: none;
    box-sizing: border-box;
}
```

Missing `display: block` and `margin: 12px 0`. Without `display: block` an iframe defaults to
`inline` which can cause extra baseline spacing.

### What to add to iOS

Update the `iframe, embed, object` rule in `wrapHtml()` to match Android's final ruleset.

The `Media Ministry` embed (`firefighters.org/motm`) may still not render correctly because
iOS's `AuthURLSchemeHandler` only handles `ffci.fiveq.dev` URLs. The iframe itself is a
third-party URL so it should load normally — but worth a quick verification that it actually
renders, not just displays a blank block.

---

## Issue 4 — Tailwind Utility Classes Undefined (Priority: Low)

**Source ticket:** 226 (secondary issue noted in research findings)

### What Android added

```css
.mb-2 { margin-bottom: 8px !important; }
.mb-4 { margin-bottom: 16px !important; }
.mb-8 { margin-bottom: 32px !important; }
.mb-12 { margin-bottom: 48px !important; }
.mt-8 { margin-top: 32px !important; }
.py-24 { padding-top: 96px !important; padding-bottom: 96px !important; }
.text-center { text-align: center; }
.text-left { text-align: left; }
```

The CMS HTML uses Tailwind classes directly. Without these definitions, section spacing on iOS
may differ from the web version.

### What to add to iOS

Add the same Tailwind stub block to `wrapHtml()`.

---

## Issue 5 — Image srcset Fix Handles Only First Image (Priority: Low)

### Observation

iOS `wrapHtml()` (lines 186–191) fixes `src=""` by extracting the first URL found in *any*
srcset on the page, then replaces **all** `src=""` occurrences with that single URL. This
misattributes the srcset URL from one image to all blank-src images on a multi-image page.

Android loops through each `<img>` tag individually and patches each one with its own srcset URL.

### What to fix in iOS

Replace the single-pass approach with a per-`<img>` loop using regex (or a simple HTML scan)
that matches each `<img>` tag and extracts its own srcset, analogous to Android's `imgPattern`
loop at lines 78–89 of `HtmlContent.kt`.

---

## Acceptance Criteria

- [ ] Hero titles are clearly readable on iOS for all pages listed in Issue 1
- [ ] Internal content-page buttons (non-form) navigate in-app on iOS, not to Safari
- [ ] Media Ministry iframe renders on iOS (currently shows blank block or nothing)
- [ ] No regressions to existing iOS HTML rendering, buttons, or section background colors
- [ ] Tailwind spacing classes produce correct spacing (spot-check `More Resources` section)

---

## References

- Android implementation file: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`
- iOS implementation file: `ios-mip-app/FFCI/Views/HtmlContentView.swift`
- Android API client: `android-mip-app/app/src/main/java/com/fiveq/ffci/data/api/MipApiClient.kt`
- iOS API client: `ios-mip-app/FFCI/API/MipApiClient.swift`
- Android source tickets: 242, 244, 246 (hero contrast), 248 (iframe), 226 (spacing/Tailwind), 252 (link resolution)
