# Key Issues to Investigate for React Native Conversion

This document identifies key technical issues that should be proven out in the Astro prototype before converting to React Native. These are areas where the web-based Astro implementation differs significantly from native mobile patterns.

---

## ✅ Already Proven Out

These issues have been investigated and resolved in the Astro prototype:

| Issue | Status | Notes |
|-------|--------|-------|
| Internal link resolution | ✅ Solved | Server-side transform rewrites URLs to `/page/{uuid}` format |
| API integration | ✅ Working | KQL queries, bearer auth, caching implemented |
| Video playback (YouTube/Vimeo/direct) | ✅ Working | lite-youtube-embed, iframes, HTML5 video |
| Audio playback | ✅ Working | HTML5 audio player with metadata display |
| Content HTML rendering | ✅ Working | Styled HTML output with responsive CSS |
| Navigation from menu API | ✅ Working | Dynamic menu driven by API response |
| Analytics event structure | ✅ Working | Structured events ready for Firebase |
| Forms handling | ✅ Working | Iframe embed and link-out approaches |
| Error handling | ✅ Working | Graceful error UI with retry |

---

## 🔍 Key Issues to Investigate

### 1. Video Playback in React Native

**Problem**: The Astro prototype uses `lite-youtube-embed` (web component) and iframes for YouTube/Vimeo. These won't work in React Native.

**RN Approach**:
- YouTube: `react-native-youtube-iframe` or WebView
- Vimeo: WebView with Vimeo Player SDK
- Direct URLs: `react-native-video` or Expo AV

**What to Verify**:
- [ ] YouTube embed works in RN with proper video ID extraction
- [ ] Vimeo player renders correctly in WebView
- [ ] Direct video URLs play with native controls
- [ ] Fullscreen video works on iOS and Android
- [ ] Video analytics (play/complete events) can be captured

**Spec Reference**: Section "6. Collection Item (Video/Audio)"

---

### 2. Audio Playback and Background Audio

**Problem**: HTML5 `<audio>` element won't work in RN. Background audio (playing when app is backgrounded) requires native implementation.

**RN Approach**:
- Expo AV for basic playback
- `react-native-track-player` for background audio and lock screen controls

**What to Verify**:
- [ ] Audio plays with custom controls (play/pause, scrubber)
- [ ] Audio metadata (title, artwork, duration) displays correctly
- [ ] Audio continues when app is backgrounded (nice-to-have for v1)
- [ ] Lock screen controls work (nice-to-have for v1)
- [ ] Audio analytics events fire correctly

**Spec Reference**: Section "Out of Scope (v1)" - background playback is nice-to-have

---

### 3. WebView for Rich Text Content

**Problem**: Page content is HTML with formatting, images, lists, tables, etc. React Native needs WebView for rich text rendering.

**RN Approach**:
- `react-native-webview` for HTML content
- Custom CSS injected for mobile styling
- Communication bridge for link interception

**What to Verify**:
- [ ] HTML content renders correctly with styling
- [ ] Images in content scale properly
- [ ] Internal links are intercepted and routed to RN navigation
- [ ] External links open in system browser
- [ ] WebView performance is acceptable (not sluggish scrolling)
- [ ] Content height adjusts dynamically to content
- [ ] Touch targets meet 44pt minimum

**Spec Reference**: Section "4. Content Page" and "Content Rendering Strategy"

---

### 4. App Store Compliance (Guideline 4.2)

**Problem**: Apple rejects apps that are "repackaged websites." The app must feel native.

**What to Verify**:
- [ ] Navigation is native (tabs/drawer), not web-based
- [ ] Collection grids use native components, not WebView
- [ ] Video/audio players are native, not web embeds (for primary playback)
- [ ] Pull-to-refresh uses native gesture
- [ ] Only rich text content uses WebView
- [ ] The ratio of native UI to WebView is acceptable

**Spec Reference**: Section "Content Rendering Strategy & App Store Compliance"

---

### 5. Forms Handling in React Native

**Problem**: The Astro prototype uses iframe embedding for forms. Iframes don't exist in RN.

**RN Approach**:
- **Option A**: Full WebView for pages with forms (load actual website URL)
- **Option B**: Button linking out to Safari/Chrome

**What to Verify**:
- [ ] API returns `has_form` flag reliably
- [ ] WebView can load full page with Vue.js forms
- [ ] Form submission works within WebView
- [ ] Post-submission behavior is handled (success message, redirect)
- [ ] User can return to app after form completion

**Spec Reference**: Section "Forms Handling"

---

### 6. Image Handling and Caching

**Problem**: Cover images, logos, and content images need proper loading and caching.

**RN Approach**:
- `expo-image` or `react-native-fast-image` for optimized loading
- Placeholder/skeleton states during load
- Cache management for frequently accessed images

**What to Verify**:
- [ ] Cover images load with placeholder during fetch
- [ ] Logo displays correctly in header
- [ ] Content images (in WebView) scale correctly
- [ ] Images are cached to reduce data usage
- [ ] Missing images show graceful fallback

---

### 7. API Token Security

**Problem**: The API bearer token is currently in a config file. In RN, this needs secure storage.

**RN Approach**:
- Store token in app bundle (baked in at build time)
- Use Expo SecureStore for any runtime-stored credentials
- Obfuscate token in production builds

**What to Verify**:
- [ ] Token is not easily extractable from built app
- [ ] Token works correctly with API from device
- [ ] 401 handling prompts appropriate error (token expired/invalid)

**Spec Reference**: Section "Authentication" and "Token management"

---

### 8. Network Error Handling

**Problem**: Mobile apps need graceful handling of network failures.

**What to Verify**:
- [ ] App shows meaningful error when API is unreachable
- [ ] Retry button works correctly
- [ ] Loading states don't hang indefinitely
- [ ] Network status is detectable (online/offline)

**Spec Reference**: Section "7. Error Screen" and "API Response Handling"

---

### 9. Navigation Patterns (Tabs vs Drawer)

**Problem**: The spec mentions "bottom tab bar or drawer menu." Need to prove navigation works with dynamic menu.

**RN Approach**:
- Expo Router with dynamic routes
- Tab or drawer navigation driven by API menu response
- Handle variable number of menu items

**What to Verify**:
- [ ] Bottom tabs work with 3-5 menu items
- [ ] Drawer works with larger menu lists
- [ ] Icons render correctly (from config or defaults)
- [ ] Current page indicator works
- [ ] Deep navigation (page → child page) maintains back stack

**Spec Reference**: Section "3. Navigation"

---

### 10. Analytics Integration with Firebase

**Problem**: The Astro prototype uses console.log analytics. RN needs native Firebase integration.

**RN Approach**:
- `@react-native-firebase/analytics`
- Configure Firebase project per site
- Map existing event structure to Firebase format

**What to Verify**:
- [ ] Firebase project setup documented
- [ ] All event types work: app_open, screen_view, content_view, video_play, video_complete, audio_play, external_link
- [ ] Events appear in Firebase console
- [ ] Custom event parameters are tracked correctly

**Spec Reference**: Section "Firebase Analytics"

---

### 11. Pull-to-Refresh on Collections

**Problem**: Web-based pull-to-refresh behavior differs from native.

**RN Approach**:
- Use `RefreshControl` on ScrollView/FlatList
- Trigger cache invalidation and refetch

**What to Verify**:
- [ ] Pull gesture is natural and responsive
- [ ] Loading indicator shows during refresh
- [ ] Data updates after refresh completes
- [ ] Works on both iOS and Android

**Spec Reference**: Section "5. Collection List"

---

### 12. Splash Screen and App Launch

**Problem**: Web splash screen implementation differs from native.

**RN Approach**:
- `expo-splash-screen` for native splash
- Transition from splash to home after data loads
- Handle slow network during startup

**What to Verify**:
- [ ] Splash screen displays immediately on launch
- [ ] Splash hides only after initial data loads
- [ ] Splash image/logo is customizable per site
- [ ] Timeout handling if initial load takes too long

**Spec Reference**: Section "1. Splash Screen"

---

### 13. Theming and Dynamic Colors

**Problem**: Theme colors come from config. Need to apply throughout native app.

**RN Approach**:
- Theme context/provider
- NativeWind or StyleSheet with theme variables
- Dark mode support (nice-to-have)

**What to Verify**:
- [ ] Primary/secondary colors apply to buttons, links, headers
- [ ] Theme can be changed via config without code changes
- [ ] Colors meet accessibility contrast requirements
- [ ] Header style (light/dark) works correctly

**Spec Reference**: Section "Design & Theming"

---

### 14. Collection Grid Performance

**Problem**: Large collections need virtualized lists for performance.

**RN Approach**:
- `FlatList` or `FlashList` for large collections
- Pagination support from API

**What to Verify**:
- [ ] Collection grid scrolls smoothly with many items
- [ ] Images lazy-load as items come into view
- [ ] Pagination works when API provides it
- [ ] Memory usage is acceptable

**Spec Reference**: Section "5. Collection List" and "Video collection with pagination" query

---

### 15. Accessibility (Basic)

**Problem**: Touch targets, screen reader support, contrast.

**What to Verify**:
- [ ] All interactive elements have 44pt minimum touch targets
- [ ] Buttons and links have accessible labels
- [ ] Color contrast meets AA standard
- [ ] Screen reader can navigate main content

**Spec Reference**: Section "Design Expectations" - "Accessible (minimum AA contrast, touch targets 44pt+)"

---

## Priority Order for Investigation

| Priority | Issue | Risk Level | Notes |
|----------|-------|------------|-------|
| 1 | WebView for rich text | High | Core to app functionality |
| 2 | Video playback in RN | High | Key content type |
| 3 | App Store compliance | High | Rejection risk |
| 4 | Navigation patterns | Medium | Architecture decision |
| 5 | Forms handling | Medium | Required for key user actions |
| 6 | Audio playback | Medium | Key content type for C4I |
| 7 | Firebase Analytics | Medium | Required per spec |
| 8 | Image caching | Medium | User experience |
| 9 | Network error handling | Low | Basic error handling required |
| 10 | Pull-to-refresh | Low | Standard pattern |
| 11 | Theming | Low | Config-driven |
| 12 | Token security | Low | Security consideration |
| 13 | Splash screen | Low | Standard Expo pattern |
| 14 | Collection performance | Low | Only matters at scale |
| 15 | Accessibility | Low | Basic compliance |

---

## Recommended Investigation Approach

For each high-priority issue:

1. **Create a minimal RN Expo project**
2. **Implement the specific feature in isolation**
3. **Test on both iOS and Android simulators/devices**
4. **Document findings, including:**
   - Which libraries to use
   - Any API changes needed
   - Performance considerations
   - Edge cases discovered
5. **Update this document with results**

---

## Related Documentation

- [Mobile App Specification](../../docs/mobile-app-specification.md) - Full requirements
- [Internal Link Resolution](./internal-link-resolution.md) - How internal links are transformed
- [Integration Tests](./integration-tests.md) - How features are tested with real API
