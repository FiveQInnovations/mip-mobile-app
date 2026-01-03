---
status: backlog
area: rn-mip-app
phase: nice-to-have
created: 2026-01-02
---

# WebView Full-Page Fallback for Form Pages

## Context
Pages containing dynamic Vue.js forms cannot be rendered as static HTML — they require the full website experience with JavaScript execution. When the API indicates a page has a form (`has_form: true`), the app should render the full website URL in a WebView instead of just the HTML content.

## Tasks
- [ ] Create WebViewPage component that loads full website URL
- [ ] Modify TabScreen/PageScreen to check `has_form` flag
- [ ] When `has_form` is true, render WebViewPage instead of HTMLContentRenderer
- [ ] Handle navigation, loading states, and errors in WebView
- [ ] Test form pages render and submit correctly
- [ ] Ensure authentication/cookies work if needed

## Notes
- Depends on ticket 019 (Form detection API flag)
- Per spec: "Forms work seamlessly, but those pages feel more 'webby'"
- Alternative approach is link-out (ticket 017), but WebView keeps user in app
