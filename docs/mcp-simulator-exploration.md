# Using MCP Tools to Explore iOS Simulator

This guide covers how to use Maestro MCP tools to interact with and explore the iOS simulator for testing and debugging.

## Prerequisites

- iOS Simulator running with app installed
- Maestro MCP server enabled in Cursor

## Basic Workflow

### 1. List Available Devices

First, check which devices are available and their connection status:

```
mcp_maestro_list_devices
```

Look for devices with `"connected": true` and note the `device_id`.

### 2. Take Screenshots

Capture the current state of the simulator:

```
mcp_maestro_take_screenshot(device_id: "YOUR_DEVICE_ID")
```

Screenshots are returned as image descriptions, useful for understanding the current UI state.

### 3. Inspect View Hierarchy

Get the complete view hierarchy to find elements by text, ID, or accessibility labels:

```
mcp_maestro_inspect_view_hierarchy(device_id: "YOUR_DEVICE_ID")
```

Returns CSV format with:
- `element_num`: Unique identifier
- `bounds`: Coordinates `[x,y][width,height]`
- `attributes`: Accessibility text, resource IDs, enabled state
- `parent_num`: Parent element reference

**Example:** Search for "Resources tab" in the output to find its element number and bounds.

### 4. Tap on Elements

Tap elements by text, ID, or other attributes:

```
mcp_maestro_tap_on(
  device_id: "YOUR_DEVICE_ID",
  text: "Resources tab"
)
```

**Alternative selectors:**
- `id`: Element resource ID
- `index`: 0-based index if multiple matches
- `enabled`: Filter by enabled state
- `checked`: Filter by checked state

### 5. Scroll

Scroll the current view:

```
mcp_maestro_run_flow(
  device_id: "YOUR_DEVICE_ID",
  flow_yaml: |
    appId: com.fiveq.ffci
    ---
    - scroll
    - waitForAnimationToEnd
)
```

### 6. Run Custom Flows

Execute sequences of Maestro commands:

```
mcp_maestro_run_flow(
  device_id: "YOUR_DEVICE_ID",
  flow_yaml: |
    appId: com.fiveq.ffci
    ---
    - tapOn:
        text: "Resources tab"
    - waitForAnimationToEnd
    - scroll
    - takeScreenshot: /tmp/screenshot.png
)
```

## Common Patterns

### Finding Elements

1. **Take screenshot** to see visual state
2. **Inspect hierarchy** to find element attributes
3. **Search CSV output** for text, accessibility labels, or resource IDs
4. **Use found attributes** to interact with elements

### Verifying Content

1. Navigate to target screen
2. Inspect hierarchy for expected elements
3. Look for accessibility text matching content (e.g., "black and white image of firemen")
4. Verify images by checking for Image components in hierarchy

### Debugging

- Use screenshots to see what's actually displayed
- Use hierarchy inspection to understand element structure
- Check accessibility labels to verify content rendering
- Scroll through long content to verify all elements

## Example: Testing Image Rendering

```typescript
// 1. List devices
const devices = await mcp_maestro_list_devices();
const deviceId = devices.devices.find(d => d.connected && d.platform === "ios")?.device_id;

// 2. Navigate to Resources page
await mcp_maestro_tap_on(deviceId, { text: "Resources tab" });

// 3. Wait for navigation
await mcp_maestro_run_flow(deviceId, `
  appId: com.fiveq.ffci
  ---
  - waitForAnimationToEnd
`);

// 4. Inspect hierarchy to verify images
const hierarchy = await mcp_maestro_inspect_view_hierarchy(deviceId);
// Look for accessibilityText containing image descriptions

// 5. Take screenshot for documentation
await mcp_maestro_take_screenshot(deviceId);
```

## Tips

- **Device IDs**: Use the full UUID from `list_devices` output
- **App IDs**: Required in flow YAML - check `app.json` for `bundleIdentifier`
- **Wait for animations**: Use `waitForAnimationToEnd` after navigation/scroll
- **Screenshots**: Save to project directory for documentation (e.g., `rn-mip-app/screenshot.png`)
- **View hierarchy**: CSV format is searchable - use grep or text search to find elements

## Related Files

- `rn-mip-app/app.json` - App bundle identifier
- `rn-mip-app/maestro/flows/` - Example Maestro test flows
- Maestro docs: https://maestro.mobile.dev/
