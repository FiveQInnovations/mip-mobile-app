# Quick Fix: PWA Not Launching

## The Issue

You installed the PWA but clicking it in `chrome://apps` does nothing.

## Most Likely Causes

1. **App window opened but is hidden/minimized** (most common)
2. **JavaScript error preventing load**
3. **Service worker blocking the load**

## Quick Fixes (Try in Order)

### Fix 1: Check for Hidden Windows

1. Look at your **taskbar/dock** - is there a new window?
2. Press **Alt+Tab** (Windows) or **Cmd+Tab** (Mac) - do you see the app?
3. Check if the window opened on a different monitor/desktop

### Fix 2: Check Browser Console

1. Go to `chrome://apps`
2. **Right-click** your app icon
3. If you see **"Inspect"** - click it and check for errors
4. If no "Inspect" option, try:
   - Open DevTools (F12) in a regular Chrome tab
   - Go to **Application** → **Service Workers**
   - Check for errors

### Fix 3: Verify Server is Running

```bash
# In terminal, check if server is running
curl http://localhost:4321

# If it fails, start the server:
cd astro-prototype
npm run dev
```

### Fix 4: Clear and Reinstall

1. Go to `chrome://apps`
2. **Right-click** your app → **Remove from Chrome**
3. Make sure dev server is running: `npm run dev`
4. Go to `http://localhost:4321` in a regular Chrome tab
5. Look for the **install icon** in Chrome's address bar (usually a "+" or download icon)
6. Click it to install
7. Try launching again

### Fix 5: Check Service Worker

1. Open `http://localhost:4321` in Chrome
2. Press **F12** → **Application** tab
3. Click **Service Workers**
4. If you see errors, click **Unregister**
5. Refresh the page (service worker will re-register)
6. Try launching the app again

## Still Not Working?

1. **Check Chrome's Task Manager**
   - Press **Shift+Esc** in Chrome
   - Look for your app process
   - If you see it, the app is running but the window might be hidden

2. **Try a Different Browser**
   - Edge has excellent PWA support
   - Install there and see if it works

3. **Check for Errors**
   - Open `http://localhost:4321` in a regular tab
   - Press **F12** → **Console** tab
   - Look for red errors
   - Share any errors you see

## Expected Behavior

When it works correctly:
- Clicking the app in `chrome://apps` opens a **standalone window**
- The window has **no browser UI** (no address bar, bookmarks, etc.)
- Your app loads and displays normally
- The window title shows your app name

## Production Note

This is a development issue. In production with HTTPS:
- The service worker caches everything
- The app works offline
- No server needs to be running
