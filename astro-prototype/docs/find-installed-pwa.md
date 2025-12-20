# Finding Your Installed PWA

After clicking "Install" in the prompt, Chrome may close the browser tab. Here's how to find your installed app:

## Windows

1. **Start Menu**
   - Press `Windows key` or click Start
   - Look for "Mobile Template" (or your app name) in the app list
   - It should have an icon and appear like a regular app

2. **Taskbar**
   - If it was running, check the taskbar for the app icon
   - Right-click the icon → Pin to taskbar

3. **Chrome Apps List**
   - Open Chrome
   - Go to `chrome://apps` in the address bar
   - You should see your installed PWA with its icon
   - Right-click → "Create shortcuts" to add to desktop/start menu

## Mac

1. **Applications Folder**
   - Open Finder
   - Go to Applications folder
   - Look for "Mobile Template" (or your app name)
   - Double-click to launch

2. **Launchpad**
   - Press F4 or pinch with thumb and three fingers
   - Look for your app icon

3. **Chrome Apps List**
   - Open Chrome
   - Go to `chrome://apps` in the address bar
   - Find your installed PWA
   - Right-click → "Create shortcuts" to add to Applications

## Verify Installation

### Method 1: Check Chrome Apps Page
1. Open Chrome
2. Navigate to: `chrome://apps`
3. You should see your app listed with its icon

### Method 2: Check if Already Installed
1. Open Chrome
2. Go to `http://localhost:4321`
3. Open DevTools (F12)
4. Go to **Application** tab → **Manifest**
5. If installed, you'll see "Add to Home Screen" is disabled/grayed out

### Method 3: Launch from Chrome Apps
1. Go to `chrome://apps`
2. Click your app icon
3. It should open in a standalone window (no browser UI)

## If You Don't See It

The installation might have failed. Try:

1. **Check Console for Errors**
   - Open DevTools → Console
   - Look for any error messages when clicking Install

2. **Reinstall**
   - Go to `chrome://apps`
   - If you see it, uninstall it first
   - Then go back to `http://localhost:4321`
   - Click the install icon in the address bar (or use the prompt)

3. **Use Chrome's Native Install**
   - Look for the install icon in Chrome's address bar (usually a "+" or download icon)
   - Click it instead of using our custom prompt
   - This uses Chrome's built-in install flow

## Troubleshooting

### "Install" Button Does Nothing
- The `beforeinstallprompt` event might not have fired
- Try refreshing the page
- Check browser console for errors
- Make sure you're using Chrome/Edge (best PWA support)

### App Installs But Won't Launch
- Check `chrome://apps` - right-click → "Create shortcuts"
- Try launching from the shortcuts

### Can't Find the App
- Check `chrome://apps` - it should definitely be there if installed
- On Windows: Check Start Menu → All Apps
- On Mac: Check Applications folder
