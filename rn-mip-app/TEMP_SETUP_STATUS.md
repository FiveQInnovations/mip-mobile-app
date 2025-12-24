# React Native App Setup - Status Summary

**Date:** December 24, 2024  
**Project:** FFCI Mobile App (rn-mip-app)  
**Location:** `/Users/anthony/.cursor/worktrees/mip-mobile-app/okj/rn-mip-app`

## What Was Accomplished

### 1. Project Setup ✅
- Created Expo project with TypeScript template
- Installed all required dependencies:
  - `expo-router` - Navigation
  - `expo-dev-client` - Required for Maestro testing
  - `expo-linking` - Required by expo-router
  - `react-native-safe-area-context`, `react-native-screens`, `react-native-webview`
  - `@tanstack/react-query`, `zustand` - State management
  - `nativewind`, `tailwindcss` - Styling

### 2. Configuration ✅
- Created `.mise.toml` with Node.js 20.18.0 and UTF-8 encoding
- Set up `lib/config.ts` with FFCI site configuration
- Created `lib/api.ts` with API client functions (`getSiteData()`, `getPage()`)
- Updated `app.json` with:
  - App name: "FFCI Mobile"
  - Bundle identifier: `com.fiveq.ffci`
  - SSL settings for development (allows self-signed certificates)

### 3. Components Created ✅
- `components/SplashScreen.tsx` - Loading screen component
- `components/HomeScreen.tsx` - Main homepage component with:
  - API data fetching
  - Loading states
  - Error handling with retry
  - Displays site logo, app name, menu items, homepage type

### 4. Expo Router Setup ✅
- Created `app/_layout.tsx` - Root layout with Stack navigator
- Created `app/index.tsx` - Homepage entry point
- Updated `package.json` to use `expo-router/entry` as main

### 5. Maestro Testing Setup ✅
- Created `maestro/flows/homepage-loads.yaml` test file
- Added npm scripts: `test:maestro` and `test:maestro:ios`
- Created `maestro/README.md` with testing documentation

### 6. iOS Build ✅
- Successfully built iOS app with `expo run:ios`
- Installed CocoaPods dependencies
- App installs and launches on iPhone 16 Plus simulator
- Metro bundler connects successfully

### 7. Bearer Token ✅
- Generated secure bearer token: `b92f8b5f3982b4778714ec76726e7b66d3f9c6574750d1617b5669322538c713`
- Updated `lib/config.ts` with bearer token
- Verified API works from host machine (returns "FFCI" app name)

### 8. DDEV Setup ✅
- Started DDEV project: `ws-ffci-copy`
- Site accessible at: `https://ws-ffci-copy.ddev.site`
- API endpoint working: `/mobile-api`

## ✅ RESOLVED: Network Issue Fixed!

### Solution: HTTP Proxy for iOS Simulator

The iOS simulator cannot reach `localhost` or `127.0.0.1` because it treats them as referring to itself, not the host machine. We solved this by:

1. **Created HTTP Proxy** (`scripts/ddev-proxy.js`): Forwards requests from Mac's IP (192.168.0.106:8888) to DDEV on localhost:55038
2. **Updated Config**: Changed `apiBaseUrl` to `http://192.168.0.106:8888`
3. **Added Exception Domain**: Added Mac's IP to Info.plist exception domains
4. **Restarted Metro**: Cleared cache and restarted Metro bundler to pick up config changes

**Result**: App now successfully loads homepage with menu items! ✅

---

## Previous Problem (RESOLVED)

### Issue: Network Request Failing in iOS Simulator

**Symptoms:**
- App launches successfully
- Metro bundler connects and loads JavaScript
- App attempts to fetch data from API
- Network request fails with: `TypeError: Network request failed`
- Error UI displays correctly with "Tap to retry" button

**What We've Tried:**
1. ✅ Verified API works from host machine (`curl` succeeds)
2. ✅ Generated and configured bearer token
3. ✅ Configured SSL settings in `app.json`:
   ```json
   "NSAppTransportSecurity": {
     "NSAllowsArbitraryLoads": true,
     "NSAllowsLocalNetworking": true,
     "NSExceptionDomains": {
       "localhost": {
         "NSExceptionAllowsInsecureHTTPLoads": true,
         "NSIncludesSubdomains": true
       },
       "127.0.0.1": {
         "NSExceptionAllowsInsecureHTTPLoads": true,
         "NSIncludesSubdomains": true
       }
     }
   }
   ```
4. ✅ Changed API URL from `https://ws-ffci-copy.ddev.site` to `http://localhost:55038`
5. ✅ Ran `expo prebuild --clean` to regenerate native code with exception domains
6. ✅ Rebuilt iOS app with updated network settings
7. ✅ Verified `Info.plist` contains exception domains for localhost and 127.0.0.1
8. ✅ Added console logging to API client to debug requests
9. ✅ Created helper script to detect DDEV port automatically (`scripts/get-ddev-port.js`)
10. ✅ Restarted app multiple times

**Solution Applied:**
- ✅ Created HTTP proxy script (`scripts/ddev-proxy.js`) to forward Mac IP → localhost
- ✅ Updated config to use `http://192.168.0.106:8888` (proxy port)
- ✅ Added Mac IP (192.168.0.106) to Info.plist exception domains
- ✅ Restarted Metro bundler with `--clear` flag
- ✅ App now successfully loads homepage with menu items!

**Current State:**
- ✅ App loads successfully in iOS simulator
- ✅ Network requests work via HTTP proxy
- ✅ Homepage displays: "Firefighters for Christ International", "FFCI", menu items
- ✅ Proxy logs show successful requests: `[PROXY] GET /mobile-api from 192.168.0.106`

## Technical Details

### API Configuration
- **URL:** `http://192.168.0.106:8888` (HTTP proxy forwarding to DDEV)
- **Proxy:** `scripts/ddev-proxy.js` forwards Mac IP:8888 → localhost:55038
- **DDEV Port:** 55038 (HTTP port mapped by DDEV)
- **Endpoint:** `/mobile-api`
- **Bearer Token:** `b92f8b5f3982b4778714ec76726e7b66d3f9c6574750d1617b5669322538c713`
- **Config File:** `lib/config.ts`
- **Note:** 
  - Start proxy with: `node scripts/ddev-proxy.js 55038`
  - Mac IP may change - update config.ts if needed
  - Check DDEV port with: `ddev describe` or `node scripts/get-ddev-port.js`

### API Client
- **File:** `lib/api.ts`
- **Functions:**
  - `getSiteData()` - Fetches menu and site metadata
  - `getPage(uuid)` - Fetches individual page content
- **Error Handling:** Custom `ApiError` class with status codes

### Device Info
- **Simulator:** iPhone 16 Plus (CE4ECBCC-F738-4276-B1FE-563C5CCE7DF3)
- **iOS Version:** 18.6
- **Bundle ID:** `com.fiveq.ffci`

## Possible Solutions to Investigate

### 1. Full Clean Rebuild
```bash
cd /Users/anthony/.cursor/worktrees/mip-mobile-app/okj/rn-mip-app
rm -rf ios/build
cd ios && pod install && cd ..
mise exec -- bash -c "export LANG=en_US.UTF-8 && npx expo run:ios --device CE4ECBCC-F738-4276-B1FE-563C5CCE7DF3"
```

### 2. Check Metro Bundler Logs
- Look for detailed error messages in Metro output
- Check if there are SSL certificate validation errors
- Verify network requests are being made

### 3. Test with Mac's IP Address
- Get Mac's local IP: `ifconfig | grep "inet " | grep -v 127.0.0.1`
- Update `lib/config.ts` to use IP instead of domain
- May need to configure DDEV to accept connections from IP

### 4. Verify React Native Fetch Configuration
- React Native's fetch might need additional SSL configuration
- Check if we need to use a library like `react-native-ssl-pinning` for development
- Or configure fetch to ignore SSL errors in development mode

### 5. Check Simulator Network Settings
- Verify simulator can reach host machine
- Test with `ping` from simulator (if possible)
- Check if DDEV router is accessible from simulator network

### 6. Alternative: Use HTTP Instead of HTTPS
- DDEV might support HTTP on a different port
- Check `ddev describe` for HTTP URLs
- Update config to use HTTP for development (less secure but might work)

## Files Modified

### Created Files
- `rn-mip-app/` - Entire React Native project
- `lib/config.ts` - Site configuration
- `lib/api.ts` - API client
- `components/HomeScreen.tsx` - Homepage component
- `components/SplashScreen.tsx` - Splash screen
- `app/_layout.tsx` - Root layout
- `app/index.tsx` - Homepage entry
- `maestro/flows/homepage-loads.yaml` - Maestro test
- `.mise.toml` - Node version management

### Modified Files
- `app.json` - Added SSL settings, expo-dev-client plugin
- `package.json` - Updated scripts, added dependencies
- `.gitignore` - Updated to keep ios/android but ignore build artifacts

## Next Steps for Developer

1. **Investigate Network Issue**
   - Check Metro bundler logs for detailed error messages
   - Verify simulator network connectivity
   - Test API connectivity from simulator perspective

2. **Try Alternative Approaches**
   - Test with Mac's IP address instead of domain
   - Try HTTP instead of HTTPS
   - Check if DDEV needs additional configuration for simulator access

3. **Once Network Works**
   - Verify homepage loads and displays data
   - Run Maestro test: `npm run test:maestro:ios`
   - Verify all homepage elements are visible

4. **Future Enhancements**
   - Add navigation to menu items
   - Implement content page rendering
   - Add WebView for rich text content
   - Implement video/audio playback

## Useful Commands

```bash
# Start DDEV
cd ~/mip-mobile-app/sites/ws-ffci-copy && ddev start

# Start DDEV proxy (required for iOS simulator)
cd rn-mip-app && node scripts/ddev-proxy.js 55038 &

# Start Metro bundler
cd rn-mip-app && mise exec -- bash -c "export LANG=en_US.UTF-8 && npx expo start --ios --clear"

# Rebuild iOS app
cd rn-mip-app && mise exec -- bash -c "export LANG=en_US.UTF-8 && npx expo run:ios --device CE4ECBCC-F738-4276-B1FE-563C5CCE7DF3"

# Run Maestro test
cd rn-mip-app && npm run test:maestro:ios

# Test API from host (via proxy)
curl -H "Authorization: Bearer b92f8b5f3982b4778714ec76726e7b66d3f9c6574750d1617b5669322538c713" http://192.168.0.106:8888/mobile-api

# Test API directly (DDEV)
curl -H "Authorization: Bearer b92f8b5f3982b4778714ec76726e7b66d3f9c6574750d1617b5669322538c713" http://localhost:55038/mobile-api
```

## Environment

- **Node.js:** 20.18.0 (via mise)
- **Expo SDK:** 54.0.30
- **React Native:** 0.81.5
- **React:** 19.1.0
- **Platform:** macOS (Darwin 24.6.0)
- **Simulator:** iPhone 16 Plus, iOS 18.6

## Notes

- The app structure is correct and follows best practices
- Error handling is working properly
- The issue is specifically network connectivity from simulator to DDEV
- All code is committed to git repository
- Bearer token is configured and working from host machine

