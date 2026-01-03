---
status: done
area: rn-mip-app
phase: core
created: 2026-01-19
---

# Homepage Featured Section Content

## Problem

After ticket 055 moves Resources to Quick Tasks, the Featured section will point to Resources—creating redundancy. The Featured section needs new content.

## Solution

Replace the single Featured card with two featured items:

1. **Chaplain Resources** (in-app)
   - Title: "Chaplain Resources"
   - Description: "Downloadable tools and resources for chaplains"
   - Navigation: In-app to UUID `PCLlwORLKbMnLPtN`
   - Practical, utility-driven content with PDF downloads

2. **Know God** (browser)
   - Title: "Do You Know God?"
   - Description: "You were created to know God personally"
   - Navigation: Browser to harvest.org (or similar gospel link)
   - Core mission of FFCI, always relevant

## Tasks

- [x] Update Featured section in `HomeScreen.tsx` to show two cards
- [x] Implement Chaplain Resources card with hardcoded UUID navigation
- [x] Implement Know God card with browser link
- [x] Test both cards navigate correctly
- [x] Update Maestro tests for new Featured content

## Related

- **Ticket 055**: Quick Tasks In-App Alternatives (do this first)
- `rn-mip-app/components/HomeScreen.tsx` - Featured section implementation

---

## Reference: Implementation Details

### Chaplain Resources

- **UUID**: `PCLlwORLKbMnLPtN`
- **URL**: `https://ffci.fiveq.dev/get-involved/ffc-chaplain-program/chaplain-resources`
- **Note**: Not in `Mobilemainmenu`, so use direct UUID navigation instead of `handleNavigate()` label matching

### Know God

- **External link**: `https://www.harvest.org/know-god` (verify correct URL)
- Opens in browser via `Linking.openURL()`
