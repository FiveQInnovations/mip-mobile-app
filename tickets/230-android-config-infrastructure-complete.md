---
status: done
area: android-mip-app
phase: nice-to-have
created: 2026-01-28
---

# Android Configuration Infrastructure (Complete)

## Context

Part of the Android Multi-Site Configuration System implementation. This ticket covers Phase 1 & 2: creating the configuration infrastructure and extracting all hardcoded FFCI-specific values into a JSON config file.

## Goals

1. Create a JSON-based configuration system similar to the React Native app
2. Extract all FFCI-specific hardcoded values into config
3. Prove the multi-site pattern works by testing with FFCI config

## Implementation (2026-01-26)

### Phase 1 & 2 Complete

**New Files Created:**
- `app/src/main/java/com/fiveq/ffci/config/AppConfig.kt` - SiteConfig data class and AppConfig singleton
- `app/src/main/assets/config.json` - FFCI site configuration

**Files Modified:**
- `MipApplication.kt` - Initialize config at startup, use config for Coil auth
- `MipApiClient.kt` - Use config for BASE_URL, API_KEY, credentials (lazy init)
- `HtmlContent.kt` - Use config for domain references and auth credentials
- `HomeScreen.kt` - Use config for logo URL domain
- `Theme.kt` - Load colors from config at runtime with parseColor()

**Config Structure:**
```json
{
  "siteId": "ffci",
  "apiBaseUrl": "https://ffci.fiveq.dev",
  "apiKey": "...",
  "username": "fiveq",
  "password": "demo",
  "appName": "Firefighters for Christ International",
  "primaryColor": "#D9232A",
  "secondaryColor": "#024D91",
  "textColor": "#0F172A",
  "backgroundColor": "#F8FAFC"
}
```

### Verified Working
- App launches and loads config successfully
- Home screen displays with correct colors and logo
- Resources page loads with proper API authentication
- WebView images load with auth headers
- All navigation works correctly

## Findings (2026-01-26)

### Initial Implementation Issues
After Phase 1 & 2, testing revealed several hardcoded colors that weren't using the config system:

1. **Navigation Tabs** (`MipApp.kt`):
   - Selected tab colors hardcoded to `#D9232A` (red)
   - Underline color hardcoded to `#0F172A` (dark gray)
   - **Fix**: Changed to use `MaterialTheme.colorScheme.primary` and `MaterialTheme.colorScheme.onSurfaceVariant`

2. **FEATURED Badges** (`HomeScreen.kt`):
   - Badge background hardcoded to `#2563EB` (blue)
   - **Fix**: Changed to use `MaterialTheme.colorScheme.secondary`

3. **HTML Content Buttons** (`HtmlContent.kt`):
   - Button colors hardcoded to `#D9232A` (red) in CSS
   - Link colors hardcoded to `#D9232A`
   - Blockquote borders hardcoded to `#D9232A`
   - **Fix**: Added CSS variable `--primary-color` injected from config, replaced all hardcoded red values

4. **H3 Heading Borders** (`HtmlContent.kt`):
   - Left border hardcoded to `#D9232A` (red)
   - **Fix**: Changed to use CSS variable `--primary-color`

### Verification Process
To prove the configuration system works:
1. Changed `config.json` colors to test values:
   - Primary: `#9333EA` (purple)
   - Secondary: `#16A34A` (green)
   - Background: `#FEF3C7` (amber)
2. Rebuilt and verified changes appeared throughout app:
   - Navigation tabs turned purple
   - FEATURED badges turned green
   - Page backgrounds turned amber
   - HTML buttons turned purple
   - H3 borders turned purple
3. Restored original FFCI colors - all reverted correctly

### Final Status
✅ **All hardcoded colors now use config values**
✅ **Configuration system fully functional**
✅ **Verified working across all screens (Home, Resources, Media, Connect)**
✅ **Ready for multi-site deployment**

### Files Modified (Color Fixes)
- `MipApp.kt` - Navigation tab colors
- `HomeScreen.kt` - FEATURED badge colors
- `HtmlContent.kt` - HTML button/link/border colors via CSS variables

## Acceptance Criteria

- [x] App loads configuration from JSON file at startup
- [x] All FFCI-specific values come from config, not hardcoded
- [x] App still works correctly with FFCI config
- [x] All hardcoded colors extracted to config system

## Success Metrics

- ✅ Configuration extraction doesn't break existing functionality
- ✅ No hardcoded site-specific values remain in source code

## References

- RN config: `rn-mip-app/configs/ffci.json`
- RN config loader: `rn-mip-app/lib/config.ts`
- Android MipApiClient: `android-mip-app/app/src/main/java/com/fiveq/ffci/api/MipApiClient.kt`
- Android Theme: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/theme/Theme.kt`
