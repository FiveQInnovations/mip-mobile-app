---
status: done
area: android-mip-app
phase: core
created: 2026-01-28
---

# Android: Cover/Hero Images Missing (e.g. Resources tab)

## Context

On the **Resources** tab, iOS shows a hero image but Android does not (see screenshot).

This is blocking visual parity and makes key pages feel incomplete on Android.

## Goals

1. Ensure Android reliably displays the same cover/hero image content as iOS on tab pages (starting with Resources).
2. Ensure the solution works for both:
   - cover images provided via `PageData.cover`
   - images embedded in `PageData.htmlContent` (including `srcset`-only images)

## Acceptance Criteria

- On Android, the **Resources** tab displays the same hero/cover image seen on iOS.
- Hero/cover images render on any page that has them (tab root + drilled-in pages).
- Images load successfully when the site requires **Basic Auth** (no broken-image placeholders).
- No regressions: HTML content still renders and navigation links still work.

## Notes

- iOS renders page content in a `WKWebView` (`FFCI/Views/HtmlContentView.swift`) and rewrites URLs to a custom scheme so resources load with Basic Auth headers.
- Android renders HTML in a `WebView` (`android-mip-app/.../ui/components/HtmlContent.kt`) and intercepts requests to add Basic Auth headers.
- Android also has access to `PageData.cover`, but rendering cover images outside the WebView may require adding Basic Auth headers for image requests (e.g. Coil/OkHttp configuration).

### Investigation so far

- Verified `PageData` includes `cover` on Android (`android-mip-app/.../data/api/ApiModels.kt`).
- Tried rendering `pageData.cover` directly in `TabScreen` using Coil `AsyncImage` — did not show (likely auth and/or URL issues).
- Tried improving Android `WebView` HTML image handling:
  - base URL handling for relative paths
  - per-`img` `srcset` → `src` fix-ups
  - still did not show the hero image

### Likely root causes to confirm

- **Auth**: cover/hero image URLs require Basic Auth; WebView intercept handles this, but Coil image loading does not.
- **Source of truth mismatch**: iOS hero image may come from HTML content while Android is relying on `cover` (or vice versa).
- **Relative URL resolution**: HTML may contain relative `src` / `srcset` / `<picture>` sources that resolve differently on Android.

## Test Plan

- Compare the `PageData` payload for the Resources tab on both platforms:
  - Is `cover` present and identical?
  - Does `htmlContent` contain a hero `<img>` / `<picture>` block?
- On Android:
  - Confirm whether the image request is made and whether it’s failing auth (401/403) or URL resolution.
  - If rendering `cover` via Coil: configure image fetching to include Basic Auth headers (OkHttp/Coil ImageLoader).
  - If rendering via HTML: ensure WebView base URL and `src/srcset` rewriting produces valid absolute URLs.

## References

- Screenshot: `/Users/anthony/.cursor/projects/Users-anthony-mip-mobile-app/assets/Screenshot_2026-01-28_at_11.43.18_PM-e2fb2c23-b27d-4687-85c4-6a2d81899413.png`
- Android: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/screens/TabScreen.kt`
- Android: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`
- iOS: `ios-mip-app/FFCI/Views/TabPageView.swift`
- iOS: `ios-mip-app/FFCI/Views/HtmlContentView.swift`
