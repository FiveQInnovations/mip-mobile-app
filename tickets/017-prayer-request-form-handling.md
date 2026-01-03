---
status: in-progress
area: rn-mip-app
phase: core
created: 2026-01-02
---

# Prayer Request Form Handling

## Context
The Prayer Request quick task on the home screen currently does nothing when tapped. The button calls `handleNavigate('Prayer Request')` but there's no matching menu item, and even if there were, forms built with Vue.js require JavaScript to render and submit.

Per the spec, forms can be handled via:
- **Option A**: Full page WebView — load the actual website URL instead of just HTML content
- **Option B**: Link out — prompt user to open form in Safari/Chrome

## Tasks
- [ ] Determine which form handling approach to use (WebView vs link out)
- [ ] Identify the Prayer Request form URL on the FFCI website
- [ ] Implement navigation to open the form (WebView or external browser)
- [ ] Test form submission works correctly
- [ ] Add appropriate loading states

## Notes
- Related to ticket 018 (Chaplain Request)
- Related to ticket 019 (Form detection flag)
- Related to ticket 020 (WebView fallback for forms)
- **Before implementing:** Review the Kirby site code and the wsp-forms plugin to understand how forms are structured and handled
