# iOS Simulator Network Setup Guide

## Problem

When running the React Native app in the iOS simulator, network requests to the DDEV backend fail with `TypeError: Network request failed`. This occurs even though:

- The API works perfectly from the host machine (`curl` succeeds)
- SSL/ATS settings are correctly configured in `Info.plist`
- The app launches and Metro bundler connects successfully

### Root Cause

**The iOS simulator cannot reach `localhost` or `127.0.0.1`** because it treats these addresses as referring to itself (the simulator), not the host machine where DDEV is running.

This is a fundamental limitation of iOS simulators - they share the host's network but interpret `localhost` differently than expected.

## Solution

We use an **HTTP proxy** that forwards requests from the Mac's IP address (which the simulator can reach) to DDEV running on localhost.

### Architecture

```
iOS Simulator → Mac IP (192.168.0.106:8888) → HTTP Proxy → localhost:55038 (DDEV)
```

The proxy (`scripts/ddev-proxy.js`) listens on all interfaces (`0.0.0.0:8888`) and forwards requests to DDEV on `127.0.0.1:55038`.

## Setup Steps

### 1. Start DDEV

```bash
cd sites/ws-ffci-copy
ddev start
```

Verify DDEV is running:
```bash
ddev describe
```

Note the HTTP port (usually `55038` for HTTP, `55039` for HTTPS).

### 2. Get Your Mac's IP Address

```bash
ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1
```

This will output something like `192.168.0.106`. **Update `lib/config.ts` if your IP changes.**

### 3. Start the HTTP Proxy

```bash
cd rn-mip-app
node scripts/ddev-proxy.js 55038 &
```

The proxy will:
- Listen on `0.0.0.0:8888` (accessible from simulator)
- Forward requests to `127.0.0.1:55038` (DDEV)
- Log all requests for debugging

**Keep this process running** while developing. You can run it in the background or in a separate terminal.

### 4. Verify Proxy Works

Test from command line:
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" http://192.168.0.106:8888/mobile-api
```

You should see JSON response with site data.

### 5. Update Config (if needed)

The config should already be set to use the proxy:
```typescript
// lib/config.ts
apiBaseUrl: 'http://192.168.0.106:8888'
```

**If your Mac's IP address changes**, update this value in `lib/config.ts`.

### 6. Start Metro Bundler

```bash
cd rn-mip-app
mise exec -- bash -c "export LANG=en_US.UTF-8 && npx expo start --ios --clear"
```

The `--clear` flag ensures Metro picks up any config changes.

### 7. Run the App

The app should auto-launch in the simulator, or press `i` in the Metro terminal.

You should see:
- ✅ Homepage loads successfully
- ✅ "Firefighters for Christ International" title
- ✅ "FFCI" app name
- ✅ Menu items displayed
- ✅ No network errors

## Troubleshooting

### App Still Shows "Network request failed"

1. **Check proxy is running:**
   ```bash
   ps aux | grep "ddev-proxy"
   ```

2. **Check proxy logs:**
   ```bash
   tail -f /tmp/ddev-proxy.log
   ```
   You should see `[PROXY] GET /mobile-api` when the app makes requests.

3. **Verify Mac IP hasn't changed:**
   ```bash
   ifconfig | grep "inet " | grep -v 127.0.0.1
   ```
   Update `lib/config.ts` if it changed.

4. **Restart Metro with cleared cache:**
   ```bash
   npx expo start --ios --clear
   ```

5. **Rebuild the app:**
   ```bash
   npx expo run:ios --device YOUR_DEVICE_ID
   ```

### Proxy Not Receiving Requests

- Check firewall settings (macOS may block incoming connections)
- Verify proxy is listening on all interfaces: `lsof -i :8888`
- Try accessing proxy from another device on the same network

### DDEV Port Changed

If DDEV restarts and gets a new port:

1. Check new port: `ddev describe`
2. Restart proxy with new port: `node scripts/ddev-proxy.js NEW_PORT`

Or use the helper script:
```bash
node scripts/get-ddev-port.js  # Outputs the port number
```

## Files Involved

- **`scripts/ddev-proxy.js`** - HTTP proxy server
- **`lib/config.ts`** - API base URL configuration
- **`app.json`** - Info.plist settings (exception domains)
- **`ios/FFCIMobile/Info.plist`** - Generated from app.json (includes Mac IP exception)

## Quick Start Checklist

- [ ] DDEV is running (`ddev start`)
- [ ] HTTP proxy is running (`node scripts/ddev-proxy.js 55038 &`)
- [ ] Config uses Mac IP (`lib/config.ts` → `http://192.168.0.106:8888`)
- [ ] Metro bundler started with `--clear` flag
- [ ] App launches and loads homepage successfully

## Notes

- The proxy must be running **before** starting the app
- If you change networks (Wi-Fi), your Mac's IP may change - update config accordingly
- The proxy adds CORS headers automatically for React Native compatibility
- All requests are logged to help with debugging

## Alternative Solutions (Not Used)

We tried several alternatives before settling on the proxy:

1. **Using localhost directly** - Doesn't work (simulator limitation)
2. **Using 127.0.0.1** - Same issue as localhost
3. **Configuring DDEV to listen on all interfaces** - Not supported by DDEV
4. **Using Mac IP directly** - DDEV only listens on localhost, so this doesn't work

The HTTP proxy is the most reliable solution that works consistently.

