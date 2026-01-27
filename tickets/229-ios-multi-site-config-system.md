---
status: backlog
area: ios-mip-app
phase: nice-to-have
created: 2026-01-26
---

# iOS Multi-Site Configuration System

## Context

Following the successful implementation of the Android multi-site configuration system (ticket 227), we need to implement the same pattern for iOS. The Android implementation proved the approach works well and enables easy multi-site deployment by swapping config files.

iOS presents some additional challenges compared to Android:
- Colors are typically defined in asset catalogs (`.colorset`) which are build-time resources
- Swift doesn't have Android's product flavor system
- Runtime color loading requires a different approach than Android's Compose theme system

However, SwiftUI's `@Environment` and `Color` extensions make runtime color loading feasible.

## Goals

1. Create a JSON-based configuration system matching the Android implementation
2. Extract all FFCI-specific hardcoded values into config
3. Load colors at runtime using SwiftUI environment
4. Prove the multi-site pattern works by testing with FFCI config

## Current Hardcoded Values (to extract)

**API & Authentication:**
- Base URL: `https://ffci.fiveq.dev` (MipApiClient.swift:23)
- API Key (MipApiClient.swift:24)
- Basic Auth credentials (MipApiClient.swift:25-26)

**Domain References:**
- `ffci.fiveq.dev` in HtmlContentView.swift (multiple lines: 51, 170, 177, 203, 208, 209, 213, 214, 420, 423, 460)
- `ffci.fiveq.dev` in HomeLogoView.swift (line 20)

**Branding/Colors:**
- Primary: `#D9232A` - Hardcoded in CSS (HtmlContentView.swift:228, 233, 238, 315, 322, 323, 327)
- Secondary: `#024D91` - Hardcoded in CSS (HtmlContentView.swift:228)
- Colors may also be in Assets.xcassets (PrimaryColor.colorset, SecondaryColor.colorset)

**App Identity:**
- Bundle identifier: `com.fiveq.ffci` (project.pbxproj)
- App name: "FFCI" (Info.plist or project settings)

## Implementation Approach

### Phase 1: Configuration Infrastructure
- Create `SiteConfig.swift` struct matching the Android config structure
- Add `config.json` to app bundle
- Create `AppConfig.swift` singleton to load and provide config
- Initialize config at app startup in `FFCIApp.swift`

### Phase 2: Extract Hardcoded Values
- Update `MipApiClient.swift` to use config for base URL, API key, credentials
- Update `HtmlContentView.swift` domain references and CSS colors
- Update `HomeLogoView.swift` domain reference
- Create SwiftUI color extensions that load from config at runtime
- Replace hardcoded CSS colors with CSS variables injected from config

### Phase 3: Runtime Color Loading
- Create `Color+Config.swift` extension for dynamic colors
- Use SwiftUI `@Environment` or `@AppStorage` for theme colors
- Update asset catalog colors to be overridden at runtime
- Ensure colors work in both SwiftUI views and WKWebView CSS

### Phase 4: Build Configuration (if needed)
- Consider using Xcode build configurations or schemes for different sites
- Each configuration could have its own `config.json` in bundle
- Bundle identifier per configuration via build settings

## Acceptance Criteria

- [ ] App loads configuration from JSON file at startup
- [ ] All FFCI-specific values come from config, not hardcoded
- [ ] Colors load dynamically from config at runtime
- [ ] App still works correctly with FFCI config
- [ ] HTML content (WKWebView) uses config colors via CSS variables
- [ ] Adding a new site requires only: new config.json + build configuration

## Success Metrics

- Configuration extraction doesn't break existing functionality
- Adding a hypothetical second site config takes < 30 minutes
- No hardcoded site-specific values remain in source code
- Colors update correctly when config changes (verified by testing)

## iOS-Specific Considerations

- **Asset Catalogs**: Colors in `.colorset` files are build-time. Need runtime override mechanism.
- **WKWebView CSS**: Must inject CSS variables similar to Android WebView approach
- **SwiftUI Colors**: Use `Color(hex:)` initializer or environment values
- **Bundle Resources**: Config file must be included in app bundle
- **Build Configurations**: Xcode schemes/configurations can provide site-specific configs

## References

- Android implementation: `tickets/227-android-multi-site-config-system.md`
- Android config: `android-mip-app/app/src/main/assets/config.json`
- Android config loader: `android-mip-app/app/src/main/java/com/fiveq/ffci/config/AppConfig.kt`
- RN config: `rn-mip-app/configs/ffci.json`
- iOS MipApiClient: `ios-mip-app/FFCI/API/MipApiClient.swift`
- iOS HtmlContentView: `ios-mip-app/FFCI/Views/HtmlContentView.swift`

## Notes

- Follow the Android implementation pattern as closely as possible
- Test color changes by modifying config.json and rebuilding
- Ensure WKWebView CSS variables work correctly (similar to Android WebView)
- Consider using Swift's `Codable` for JSON parsing (simpler than Android's Moshi)
- If runtime color loading proves too complex, build-time asset catalog approach is acceptable fallback
