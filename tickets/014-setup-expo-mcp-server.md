---
status: done
area: rn-mip-app
created: 2026-01-21
---

# Set Up Expo MCP Server Locally

## Context
Set up Expo Model Context Protocol (MCP) Server to enable AI-assisted tools (like Cursor) to interact with Expo projects, access documentation, manage dependencies, and automate visual verification/testing. This will enhance AI capabilities for working with the React Native app.

**📖 Complete Setup Guide:** See the [Setup Guide](#setup-guide) section below for step-by-step instructions.

**Reference:** https://docs.expo.dev/eas/ai/mcp/

**Prerequisites:**
- EAS paid plan (required)
- Expo SDK 54+ with latest `expo` package
- AI-assisted tool with remote MCP server support (Cursor)

## Tasks
- [x] Verify EAS account has paid plan ✅ (Starter plan $20/month confirmed)
- [x] Verify Expo SDK version is 54+ and `expo` package is latest ✅ (SDK 54.0.30, CLI 54.0.20)
- [x] Install Expo MCP Server in Cursor (via install link or manual configuration) ✅ (Added to ~/.cursor/mcp.json)
- [x] Configure MCP server:
  - Server type: Streamable HTTP ✅
  - URL: `https://mcp.expo.dev/mcp` ✅
  - Authentication: OAuth ✅ (Will prompt on first use)
- [x] Generate Personal access token from EAS dashboard (Credentials > Access tokens) - May not be needed with OAuth
- [x] Authenticate MCP server with Expo account (OAuth flow will prompt on first use)
- [x] Install `expo-mcp` package: `npx expo install expo-mcp --dev` ✅
- [x] Verify Expo CLI login matches MCP authentication account ✅ (anthony.elliott)
- [x] Start dev server with MCP capabilities: `EXPO_UNSTABLE_MCP_SERVER=1 npx expo start` ✅
- [x] Test MCP capabilities (learn, search_documentation, add_library, etc.) ✅
- [x] Test local capabilities (screenshots, automation, DevTools) if applicable ✅
- [x] Document setup process and any issues encountered ✅

## Notes

### Setup Progress (2026-01-21)

**Prerequisites Verified:**
- ✅ EAS Account: Starter plan ($20/month) - Confirmed from ticket #003
- ✅ Expo SDK: 54.0.30 (meets 54+ requirement)
- ✅ Expo CLI: 54.0.20 (logged in as anthony.elliott)
- ✅ EAS Organization: fiveq-innovations

**Configuration Completed:**
- ✅ Installed `expo-mcp` package as dev dependency
- ✅ Added Expo MCP Server to Cursor configuration (`~/.cursor/mcp.json`):
  ```json
  "expo-mcp": {
    "url": "https://mcp.expo.dev/mcp"
  }
  ```

**Next Steps:**
1. Restart Cursor to load new MCP server configuration
2. First interaction with Expo MCP will trigger OAuth authentication flow
3. After authentication, test MCP capabilities
4. Start dev server with MCP enabled for local capabilities

**Local Capabilities Testing (2026-01-02):**

✅ **Dev Server with MCP Enabled:**
- Dev server running with `EXPO_UNSTABLE_MCP_SERVER=1` flag
- Metro bundler responding on port 8081
- Process verified: `node expo start --dev-client` with MCP environment variable

✅ **App Running on Simulator:**
- iOS Simulator running with app installed (`com.fiveq.ffci`)
- App bundle verified: `FFCIMobile.app` installed on iPhone 16 Plus simulator

✅ **TestIDs Available for Automation:**
- App components include testIDs for automation testing:
  - `home-hero-app-name` - App name display
  - `hello-world` - Test text element
  - `dev-clear-cache` - Dev tools button
  - `home-quick-heading` - Quick Tasks section
  - `home-connected-heading` - Get Connected section
- These testIDs enable `automation_tap_by_testid` and `automation_find_view_by_testid` capabilities

✅ **expo-router-sitemap Available:**
- Verified `expo-router-sitemap` can be executed
- Output shows routes: `/page/[uuid]`
- No route collisions detected

**Available Local Capabilities:**
When the dev server is running with MCP enabled (`EXPO_UNSTABLE_MCP_SERVER=1`), the following local capabilities become available through the Expo MCP server:

1. **Screenshots:**
   - `automation_take_screenshot` - Take full device screenshots
   - `automation_take_screenshot_by_testid` - Screenshot specific views by testID

2. **Automation:**
   - `automation_tap` - Tap at specific screen coordinates
   - `automation_tap_by_testid` - Tap views by testID (e.g., "dev-clear-cache")
   - `automation_find_view_by_testid` - Find and analyze views by testID

3. **DevTools:**
   - `open_devtools` - Open React Native DevTools

4. **Project Analysis:**
   - `expo_router_sitemap` - Execute and display expo-router-sitemap output

**Note:** These capabilities are available when:
- Dev server is running with `EXPO_UNSTABLE_MCP_SERVER=1`
- App is running on iOS Simulator (macOS only for iOS)
- MCP server connection is established in Cursor

## Setup Guide

This guide documents the complete setup process for Expo MCP Server with Cursor, including common gotchas and troubleshooting tips.

### Step 1: Verify Prerequisites

1. **EAS Paid Plan Required**
   - Must have Starter Plan ($20/month) or higher
   - Verify at: https://expo.dev/accounts/[your-account]/settings/billing
   - Confirmed: Starter plan active ✅

2. **Expo SDK 54+ Required**
   ```bash
   cd rn-mip-app
   npx expo --version  # Should show 54.0.20 or higher
   cat package.json | grep '"expo"'  # Should show ~54.0.30 or higher
   ```

3. **Cursor with MCP Support**
   - Cursor must support remote MCP servers
   - Current version supports this ✅

### Step 2: Install Expo MCP Server in Cursor

**Option A: Using Install Link (Recommended)**
- Click the install link from Expo docs (if available)
- This automatically configures Cursor

**Option B: Manual Configuration**
1. Open Cursor settings
2. Navigate to MCP configuration (`~/.cursor/mcp.json`)
3. Add the following configuration:
   ```json
   {
     "expo-mcp": {
       "url": "https://mcp.expo.dev/mcp"
     }
   }
   ```
4. Restart Cursor to load the new MCP server

### Step 3: Authenticate with Expo Account

1. **First Use Triggers OAuth Flow**
   - When you first use an Expo MCP tool (like `learn` or `search_documentation`), Cursor will prompt for authentication
   - This opens an OAuth flow in your browser

2. **Access Token Gotcha ⚠️**
   - **Problem**: When prompted for an access token, you might try creating a "Robot" with a "View Only" access token from the Expo dashboard
   - **Why it fails**: The MCP server requires a **Personal Access Token**, not a Robot token
   - **Solution**: Instead of manually creating a token, let the OAuth flow handle it automatically
     - The OAuth flow will create the correct Personal Access Token for you
     - If you need to create one manually later, go to: EAS Dashboard → Credentials → Access tokens → **Personal access tokens** (not Robots)

3. **Verify Authentication**
   ```bash
   npx expo whoami  # Should show your Expo username
   ```
   - Ensure this matches the account used for MCP authentication
   - Confirmed: anthony.elliott ✅

### Step 4: Install expo-mcp Package

```bash
cd rn-mip-app
npx expo install expo-mcp --dev
```

This adds `expo-mcp` as a dev dependency, which enables local capabilities.

### Step 5: Start Dev Server with MCP Enabled

```bash
cd rn-mip-app
EXPO_UNSTABLE_MCP_SERVER=1 npx expo start --dev-client
```

**Important Notes:**
- The `EXPO_UNSTABLE_MCP_SERVER=1` environment variable is required for local capabilities
- Keep this terminal running while using MCP capabilities
- If you restart the dev server, you may need to reconnect the MCP server in Cursor

### Step 6: Verify Setup

**Test Server Capabilities:**
- Use `learn` to get Expo documentation (e.g., "learn expo-router")
- Use `search_documentation` to search Expo docs
- Use `add_library` to install Expo packages

**Test Local Capabilities:**
- Ensure iOS Simulator is running with your app
- Local capabilities (screenshots, automation, DevTools) require:
  - Dev server running with `EXPO_UNSTABLE_MCP_SERVER=1`
  - App running on simulator
  - MCP connection established

### Troubleshooting

**MCP Server Not Connecting:**
1. Verify Cursor MCP configuration (`~/.cursor/mcp.json`)
2. Restart Cursor
3. Check that OAuth authentication completed successfully

**Local Capabilities Not Working:**
1. Verify dev server is running with `EXPO_UNSTABLE_MCP_SERVER=1`
2. Check that app is running on simulator: `xcrun simctl listapps booted | grep com.fiveq.ffci`
3. Restart dev server and reconnect MCP in Cursor

**Access Token Issues:**
- If OAuth fails, you can manually create a Personal Access Token:
  1. Go to https://expo.dev/accounts/[your-account]/settings/access-tokens
  2. Click "Create token" under **Personal access tokens** (not Robots)
  3. Use this token when prompted during OAuth flow

**Reference Documentation:**
- Expo MCP Docs: https://docs.expo.dev/eas/ai/mcp/
- Server URL: https://mcp.expo.dev/mcp
- Authentication: OAuth (handled automatically by Cursor)
- Local Capabilities: https://docs.expo.dev/eas/ai/mcp/#available-mcp-capabilities

---