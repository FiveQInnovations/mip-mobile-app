# PWA Verification Guide

This guide explains how to verify PWA features as an end user.

## Prerequisites

1. Start the development server:
   ```bash
   cd astro-prototype
   npm run dev
   ```

2. Open your browser to `http://localhost:4321`

---

## 1. Verify Service Worker Registration

### Chrome/Edge (Desktop)

1. Open **DevTools** (F12 or Right-click → Inspect)
2. Go to **Application** tab
3. Click **Service Workers** in the left sidebar
4. You should see:
   - Status: **activated and is running**
   - Scope: `http://localhost:4321/`
   - Source: `sw.js`

### Firefox

1. Open **DevTools** (F12)
2. Go to **Application** tab
3. Click **Service Workers** in the left sidebar
4. Verify the service worker is registered

### Safari (Desktop)

1. Enable **Develop** menu: Preferences → Advanced → "Show Develop menu"
2. Open **Develop** → **Show Web Inspector**
3. Go to **Storage** tab → **Service Workers**
4. Verify registration

### Mobile (Chrome on Android)

1. Open Chrome
2. Navigate to `http://localhost:4321` (use your computer's IP address)
3. Tap **Menu** (3 dots) → **Settings** → **Site settings** → **Service workers**
4. Find your site and verify it's registered

---

## 2. Verify Web App Manifest

### Chrome/Edge

1. Open **DevTools** → **Application** tab
2. Click **Manifest** in the left sidebar
3. You should see:
   - **Name**: Mobile Template (or your app name)
   - **Display**: standalone
   - **Theme color**: #2563eb (or your primary color)
   - **Icons**: 192x192 and 512x512 icons listed

### Direct URL Check

Navigate to: `http://localhost:4321/manifest.json`

You should see a JSON file with app configuration.

---

## 3. Test Offline Functionality

### Method 1: Chrome DevTools

1. Open **DevTools** → **Network** tab
2. Check **Offline** checkbox (top toolbar)
3. Refresh the page or navigate to a new page
4. You should see:
   - Cached pages load from service worker
   - `/offline` page shows if no cache available
   - "You're Offline" message with retry button

### Method 2: Disconnect Network

1. Disconnect your Wi-Fi/Ethernet
2. Navigate to `http://localhost:4321`
3. Previously visited pages should load from cache
4. New pages should show the offline page

### Method 3: Service Worker Cache Inspection

1. **DevTools** → **Application** → **Cache Storage**
2. You should see caches:
   - `mip-static-v1` - Static assets
   - `mip-api-v1` - API responses
3. Click on a cache to see cached files

---

## 4. Install the App (Add to Home Screen)

### Desktop (Chrome/Edge)

1. Look for the **install icon** in the address bar (usually a "+" or download icon)
2. Click it, or:
   - Click the **three-dot menu** → **Install [App Name]**
3. A prompt will appear - click **Install**
4. The app opens in a standalone window (no browser UI)
5. Verify:
   - Window title shows app name
   - No browser address bar
   - App icon in taskbar/dock

### Mobile (Android - Chrome)

1. Navigate to `http://localhost:4321`
2. Tap **Menu** (3 dots) → **Add to Home screen** or **Install app**
3. Tap **Add** or **Install** in the prompt
4. App icon appears on home screen
5. Tap icon to launch in standalone mode

### Mobile (iOS - Safari)

1. Navigate to `http://localhost:4321` in Safari
2. Tap **Share** button (square with arrow)
3. Scroll down and tap **Add to Home Screen**
4. Edit name if desired, tap **Add**
5. App icon appears on home screen
6. Tap icon to launch (opens in Safari but fullscreen)

**Note**: iOS doesn't support true standalone mode like Android, but the app will open fullscreen.

---

## 5. Verify Install Prompt Component

The install prompt should appear automatically when:

1. Browser supports PWA installation
2. App meets PWA criteria (HTTPS, manifest, service worker)
3. User hasn't dismissed it in the last 7 days

**To test the prompt:**

1. Clear localStorage: **DevTools** → **Application** → **Local Storage** → Clear `pwa-install-dismissed`
2. Refresh the page
3. After 3 seconds, a prompt should appear at the bottom
4. Test buttons:
   - **Install** - Triggers browser install prompt
   - **Not Now** - Dismisses for 7 days
   - **Close (X)** - Dismisses for 7 days

---

## 6. Verify Caching Behavior

### Check Cache Storage

1. **DevTools** → **Application** → **Cache Storage**
2. You should see:
   - `mip-static-v1` - Contains HTML, CSS, JS, images
   - `mip-api-v1` - Contains API responses

### Test Cache Updates

1. Make a change to a file (e.g., update a component)
2. Rebuild: `npm run build`
3. Refresh page
4. **DevTools** → **Application** → **Service Workers**
5. Click **Update** button
6. New service worker should activate

---

## 7. Verify Theme Colors

### Check Meta Tags

1. **DevTools** → **Elements** tab
2. Find `<head>` section
3. Verify:
   - `<meta name="theme-color" content="#2563eb">`
   - `<meta name="apple-mobile-web-app-capable" content="yes">`
   - `<link rel="manifest" href="/manifest.json">`

### Visual Check

1. Install the app (see section 4)
2. On Android, the status bar should match your theme color
3. On iOS, the status bar styling should match your header style

---

## 8. Test on Real Device (Mobile)

### Setup

1. Find your computer's IP address:
   - **Mac/Linux**: `ifconfig | grep "inet "`
   - **Windows**: `ipconfig`
   - Look for something like `192.168.1.xxx`

2. Make sure your phone is on the same Wi-Fi network

3. Update Astro config to allow external connections:
   ```bash
   npm run dev -- --host
   ```

4. On your phone, navigate to: `http://YOUR_IP:4321`

### Verify on Mobile

- Service worker registers
- App can be installed
- Offline mode works
- Icons display correctly
- Theme colors apply

---

## Quick Verification Checklist

- [ ] Service worker registered (DevTools → Application → Service Workers)
- [ ] Manifest accessible (`/manifest.json` shows valid JSON)
- [ ] Icons visible (192x192 and 512x512 in manifest)
- [ ] Offline page works (enable offline mode, navigate)
- [ ] Install prompt appears (after clearing dismissal)
- [ ] App installs successfully (desktop/mobile)
- [ ] App runs in standalone mode (no browser UI)
- [ ] Cache storage populated (DevTools → Cache Storage)
- [ ] Theme colors applied (status bar matches primary color)

---

## Troubleshooting

### Service Worker Not Registering

- Check browser console for errors
- Verify `sw.js` is accessible at `/sw.js`
- Check HTTPS requirement (localhost is OK, but production needs HTTPS)

### Install Prompt Not Showing

- Verify manifest is valid (check `/manifest.json`)
- Ensure service worker is registered
- Clear localStorage dismissal flags
- Check browser support (Chrome/Edge best support)

### Offline Not Working

- Verify service worker is active
- Check Cache Storage has entries
- Ensure you've visited pages while online first
- Check Network tab for failed requests

### Icons Not Showing

- Verify PNG files exist in `/public/icons/`
- Check manifest references correct paths
- Clear browser cache and reload

---

## Production Checklist

Before deploying to production:

- [ ] Use HTTPS (required for PWA)
- [ ] Replace placeholder icons with branded icons
- [ ] Update manifest with production URLs
- [ ] Test on real devices
- [ ] Verify service worker updates work
- [ ] Test offline functionality thoroughly
- [ ] Check install prompt on various browsers
