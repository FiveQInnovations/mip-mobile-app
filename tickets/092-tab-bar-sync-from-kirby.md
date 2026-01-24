---
status: maybe
area: wsp-mobile
phase: core
created: 2026-01-02
---

# Ticket 092: Tab Bar Not Syncing New Tabs from Kirby

## Problem

When adding new pages to the mobile tab bar via the Kirby Panel (Mobile settings), the new tabs do not appear in the mobile app. The app continues to show the old tab configuration regardless of:
- Adding new pages to the tab bar
- Drag-and-drop reordering tabs in the Panel
- Restarting the app

## Workaround Found

The only way to get a different page to show was to:
1. Keep an existing tab's label (e.g., "Connect")
2. Remove the original page linked to that tab
3. Replace it with the desired page (e.g., Media Resources)
4. The tab still displays the old label but loads the new page content

## Expected Behavior

- Adding a new page to the mobile tab bar in Kirby should make it appear in the app
- Reordering tabs should be reflected in the app
- Removing tabs should remove them from the app

## Reproduction Steps

1. Open Kirby Panel → Site settings → Mobile tab
2. Add "Media Resources" page to the tab bar
3. Save changes
4. Open the mobile app (or restart it)
5. Observe: Media Resources tab does not appear

## Investigation Areas

- Check `/mobile-api/menu` endpoint - is it returning the new tab configuration?
- Check how the RN app caches/fetches the menu data
- Check if there's a mismatch between Kirby field names and API expectations
- Verify the `wsp-mobile` plugin is reading the tab configuration correctly

## API Endpoint to Check

```bash
curl -s -H "X-API-Key: $MIP_API_KEY" -u "fiveq:demo" \
  "https://ffci.fiveq.dev/mobile-api/menu" | jq '.'
```

## Related

- Ticket 073: Reduce tab bar to 4 tabs
- wsp-mobile plugin handles tab configuration
