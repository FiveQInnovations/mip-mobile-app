---
status: backlog
area: android-mip-app
phase: core
created: 2026-01-24
---

# Android Prayer Request Form

## Context

The FFCI app needs a prayer request form that allows users to submit prayer requests. In the RN app, this was handled by opening a web form in the browser. For Android, we need to decide on the implementation approach.

## Goals

1. Allow users to submit prayer requests
2. Provide a good user experience (in-app vs browser)

## Acceptance Criteria

- Prayer request option is accessible from the app
- Users can successfully submit a prayer request
- Confirmation feedback after submission
- Form validation for required fields

## Implementation Options

### Option A: Open in Browser (Simple)
- Tap "Prayer Request" opens the web form in external browser
- Pros: Simple, uses existing web form
- Cons: Leaves app context

### Option B: WebView (Middle Ground)
- Open web form in an in-app WebView
- Pros: Stays in app, uses existing form
- Cons: WebView management, back navigation

### Option C: Native Form (Best UX)
- Build native Compose form that submits to API
- Pros: Best UX, native feel
- Cons: Requires API endpoint, more development

## Notes

- RN implementation opened form in browser (ticket 086)
- `wsp-forms` plugin handles form submissions on the Kirby side
- Consider what API endpoint would be needed for native form

## References

- Previous tickets: 017, 086
- `wsp-forms` plugin for backend form handling
