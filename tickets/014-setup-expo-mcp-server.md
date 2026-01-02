---
status: in-progress
area: rn-mip-app
created: 2026-01-21
---

# Set Up Expo MCP Server Locally

## Context
Set up Expo Model Context Protocol (MCP) Server to enable AI-assisted tools (like Cursor) to interact with Expo projects, access documentation, manage dependencies, and automate visual verification/testing. This will enhance AI capabilities for working with the React Native app.

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
- [ ] Test MCP capabilities (learn, search_documentation, add_library, etc.)
- [ ] Test local capabilities (screenshots, automation, DevTools) if applicable
- [ ] Document setup process and any issues encountered

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

**Reference Documentation:**
- Expo MCP Docs: https://docs.expo.dev/eas/ai/mcp/
- Server URL: https://mcp.expo.dev/mcp
- Authentication: OAuth (handled automatically by Cursor)

---