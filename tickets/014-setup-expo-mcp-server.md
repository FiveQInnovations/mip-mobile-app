---
status: backlog
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
- [ ] Verify EAS account has paid plan
- [ ] Verify Expo SDK version is 54+ and `expo` package is latest
- [ ] Install Expo MCP Server in Cursor (via install link or manual configuration)
- [ ] Configure MCP server:
  - Server type: Streamable HTTP
  - URL: `https://mcp.expo.dev/mcp`
  - Authentication: OAuth
- [ ] Generate Personal access token from EAS dashboard (Credentials > Access tokens)
- [ ] Authenticate MCP server with Expo account
- [ ] Install `expo-mcp` package: `npx expo install expo-mcp --dev`
- [ ] Verify Expo CLI login matches MCP authentication account
- [ ] Start dev server with MCP capabilities: `EXPO_UNSTABLE_MCP_SERVER=1 npx expo start`
- [ ] Test MCP capabilities (learn, search_documentation, add_library, etc.)
- [ ] Test local capabilities (screenshots, automation, DevTools) if applicable
- [ ] Document setup process and any issues encountered

## Notes

