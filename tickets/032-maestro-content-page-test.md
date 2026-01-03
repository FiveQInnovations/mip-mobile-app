---
status: backlog
area: rn-mip-app
phase: testing
created: 2026-01-02
---

# Maestro Test: Content Page Rendering

## Context
The spec requires Maestro test coverage for content pages. Need to verify that page loads and HTML content renders correctly in the app.

## Tasks
- [ ] Create `content-page.yaml` Maestro flow
- [ ] Navigate to a content page (e.g., Resources)
- [ ] Assert page title is visible
- [ ] Assert HTML content renders (look for specific text)
- [ ] Verify images load if present
- [ ] Take screenshot for documentation

## Notes
- Per spec: "Content Page - Page loads, HTML content renders in WebView"
- Existing tests cover navigation but not content rendering validation
- Should work on both iOS and Android
