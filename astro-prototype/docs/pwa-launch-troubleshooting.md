# PWA Launch Troubleshooting

If you installed the PWA but clicking it does nothing, here's how to fix it:

## Problem

When you install a PWA, Chrome stores the URL it was installed from (`http://localhost:4321`). If the dev server isn't running when you click the app, nothing will happen.

## Solution

### Step 1: Start the Dev Server

```bash
cd astro-prototype
npm run dev
```

The server should start on `http://localhost:4321`

### Step 2: Try Launching Again

1. Go to `chrome://apps`
2. Click your app icon
3. It should now open in a standalone window

### Step 3: Verify It Works

When the app launches, you should see:
- A standalone window (no browser UI)
- Your app's homepage
- The app name in the window title

## Alternative: Check What's Happening

If it still doesn't work:

1. **Check Chrome's Error Console**
   - Right-click the app icon in `chrome://apps`
   - Select "Inspect" (if available)
   - Check for errors in the console

2. **Check if Server is Running**
   - Open a browser tab
   - Go to `http://localhost:4321`
   - If it loads, the server is running
   - If it doesn't, start the server first

3. **Reinstall the App**
   - Go to `chrome://apps`
   - Right-click your app → "Remove from Chrome"
   - Start the dev server: `npm run dev`
   - Go to `http://localhost:4321`
   - Install again using Chrome's install icon or the prompt

## Why This Happens

PWAs installed from `localhost` require the server to be running. This is normal for development. In production (with HTTPS), the app will work offline thanks to the service worker.

## Production Note

When deployed to production with HTTPS:
- The service worker will cache the app
- It will work offline
- You won't need the server running

## Quick Test

To verify everything works:

1. **Terminal 1**: Start dev server
   ```bash
   cd astro-prototype
   npm run dev
   ```

2. **Browser**: Go to `http://localhost:4321`

3. **Install**: Use Chrome's install icon or the prompt

4. **Launch**: Click the app in `chrome://apps`

5. **Verify**: App opens in standalone window

If it still doesn't work, check the browser console for errors.
