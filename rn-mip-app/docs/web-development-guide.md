# Web Development Guide

Complete guide for running the React Native Expo app in a web browser with local DDEV server.

## Overview

The FFCI Mobile App can run in a web browser for development, allowing you to test and debug without needing iOS Simulator or Android Emulator. The app automatically connects to a local DDEV instance to avoid CORS issues and certificate errors.

## Prerequisites

- Node.js 20.18.0 (managed via `mise`)
- DDEV installed and configured
- FFCI Kirby site available at `/Users/anthony/mip/sites/ws-ffci`
- Dependencies installed: `npm install`

## Step-by-Step Setup

### 1. Start DDEV Server

The app requires a local DDEV instance running the FFCI Kirby site with CORS headers configured.

```bash
cd /Users/anthony/mip/sites/ws-ffci
ddev start
```

**Verify DDEV is running:**
```bash
ddev describe
```

You should see:
- Project URL: `https://ws-ffci.ddev.site` (HTTPS)
- Project URL: `http://ws-ffci.ddev.site` (HTTP)

**Important:** The app uses **HTTP** (not HTTPS) to avoid browser certificate warnings. See [Certificate Errors](#certificate-errors) below.

### 2. Verify CORS Configuration

The DDEV nginx configuration includes CORS headers for `/mobile-api` routes. Verify the config exists:

```bash
cat /Users/anthony/mip/sites/ws-ffci/.ddev/nginx/cors.conf
```

You should see CORS headers configured for `http://localhost:8081` and `http://localhost:19006`.

**Test CORS headers:**
```bash
curl -I -X OPTIONS \
  -H "Origin: http://localhost:8081" \
  -H "Access-Control-Request-Method: GET" \
  http://ws-ffci.ddev.site/mobile-api
```

Expected headers:
- `Access-Control-Allow-Origin: http://localhost:8081`
- `Access-Control-Allow-Credentials: true`
- `Access-Control-Allow-Methods: GET, POST, OPTIONS`
- `Access-Control-Allow-Headers: Authorization, Content-Type, X-API-Key, X-Language`

### 3. Start Web App

From the React Native app directory:

```bash
cd /Users/anthony/mip-mobile-app/rn-mip-app
npm run web
```

Or use Expo CLI directly:
```bash
npx expo start --web
```

The app will:
1. Start Metro bundler
2. Open automatically in your default browser at `http://localhost:8081`
3. Connect to local DDEV API at `http://ws-ffci.ddev.site`

## How It Works

### Platform Detection

The app automatically detects when running on web platform and switches to local API:

**File:** `lib/config.ts`
```typescript
// Use local DDEV API for web development
const baseConfig = Platform.OS === 'web' ? ffciLocalConfig : ffciConfig;
```

**Config Files:**
- **Web:** `configs/ffci-local.json` → `http://ws-ffci.ddev.site`
- **Native:** `configs/ffci.json` → `https://ffci.fiveq.dev`

### CORS Headers

CORS headers are added in two places:

1. **Nginx** (`sites/ws-ffci/.ddev/nginx/cors.conf`):
   - Handles preflight OPTIONS requests
   - Adds CORS headers to all `/mobile-api` routes

2. **PHP** (`fiveq-plugins/wsp-mobile/index.php`):
   - Adds CORS headers in `cors_headers()` function
   - Ensures headers are present even when nginx passes to PHP

## Certificate Errors

### Why HTTP Instead of HTTPS?

DDEV uses self-signed certificates (`mkcert`) for local HTTPS. Browsers will show certificate warnings and may block requests, especially with CORS credentials.

**Solution:** Use HTTP (`http://ws-ffci.ddev.site`) instead of HTTPS for local development.

The app is configured to use HTTP in `configs/ffci-local.json`:
```json
{
  "apiBaseUrl": "http://ws-ffci.ddev.site",
  ...
}
```

### If You See Certificate Errors

If you accidentally navigate to `https://ws-ffci.ddev.site` in the browser:

1. **Option 1:** Trust the certificate (development only)
   - Click "Trust Certificate" in the browser warning
   - Certificate is valid for local development

2. **Option 2:** Use HTTP instead
   - Navigate to `http://ws-ffci.ddev.site` (no 's')
   - No certificate warnings

3. **Option 3:** Install mkcert certificates (if needed)
   ```bash
   brew install mkcert
   mkcert -install
   ```

## Troubleshooting

### App Shows "Unable to Load" or "Retry" Button

**Cause:** CORS error or API connection failure

**Solutions:**
1. Verify DDEV is running: `ddev status`
2. Check CORS headers: `curl -I http://ws-ffci.ddev.site/mobile-api`
3. Check browser console for specific error messages
4. Verify `configs/ffci-local.json` uses HTTP (not HTTPS)

### CORS Error: "Access-Control-Allow-Credentials header is ''"

**Cause:** Missing credentials header in PHP response

**Solution:** Verify `wsp-mobile/index.php` includes:
```php
header('Access-Control-Allow-Credentials: true');
```

Then restart DDEV: `ddev restart`

### API Returns 401 Unauthorized

**Cause:** Missing or incorrect API key

**Solution:** Verify API key in `configs/ffci-local.json` matches:
- `sites/ws-ffci/site/config/config.php` → `wsp.mobile.api_secret`

### Metro Bundler Won't Start

**Cause:** Port 8081 already in use

**Solutions:**
1. Kill existing process: `lsof -ti:8081 | xargs kill`
2. Use different port: `npx expo start --web --port 8082`

### DDEV Won't Start

**Cause:** Port conflicts or Docker issues

**Solutions:**
1. Check Docker is running: `docker ps`
2. Check for port conflicts: `ddev describe`
3. Restart DDEV: `ddev restart`
4. Check DDEV logs: `ddev logs`

## Development Workflow

### Typical Development Session

1. **Start DDEV:**
   ```bash
   cd /Users/anthony/mip/sites/ws-ffci
   ddev start
   ```

2. **Start Web App:**
   ```bash
   cd /Users/anthony/mip-mobile-app/rn-mip-app
   npm run web
   ```

3. **Make Changes:**
   - Edit React Native code
   - Changes hot-reload automatically
   - Check browser console for errors

4. **Test API Changes:**
   - Edit Kirby site content
   - Refresh browser to see changes
   - API responses update immediately

### Hot Reload

The web app supports Fast Refresh:
- Component changes reload instantly
- State is preserved when possible
- Check browser console for reload status

### Debugging

**Browser DevTools:**
- Open DevTools: `Cmd+Option+I` (Mac) or `F12` (Windows/Linux)
- Check Console tab for API logs and errors
- Check Network tab for API requests
- Use React DevTools extension for component inspection

**API Logging:**
The app logs all API requests to console:
- `[API] Fetching site data from: ...`
- `[API] Response status: 200 for site data`
- `[API] Total request duration: 196ms`

## Differences from Native Development

### Platform-Specific Behavior

- **Web:** Uses HTTP, browser DevTools, no native modules
- **iOS/Android:** Uses HTTPS, native modules, device features

### API Configuration

- **Web:** `configs/ffci-local.json` → `http://ws-ffci.ddev.site`
- **Native:** `configs/ffci.json` → `https://ffci.fiveq.dev`

### Limitations

Some features may not work in web:
- Native modules (camera, location, etc.)
- Push notifications
- Deep linking (browser-based)
- File system access

## Related Documentation

- **[README.md](../README.md)** - Main project documentation
- **[iOS Simulator Network Setup](./ios-simulator-network-setup.md)** - Native development setup
- **[EAS Webhook Setup](./eas-webhook-setup.md)** - Deployment configuration

## Quick Reference

**Start Everything:**
```bash
# Terminal 1: DDEV
cd /Users/anthony/mip/sites/ws-ffci && ddev start

# Terminal 2: Web App
cd /Users/anthony/mip-mobile-app/rn-mip-app && npm run web
```

**Verify Setup:**
```bash
# Check DDEV
ddev status

# Test API
curl http://ws-ffci.ddev.site/mobile-api \
  -H "X-API-Key: 777359235aecc10fdfb144041dfdacfc80ca0751c7bed7b14c96f935456fc4ce" \
  -H "Authorization: Basic $(echo -n 'fiveq:demo' | base64)"

# Check browser
open http://localhost:8081
```

**Stop Everything:**
```bash
# Stop Metro (Ctrl+C in terminal)
# Stop DDEV
cd /Users/anthony/mip/sites/ws-ffci && ddev stop
```
