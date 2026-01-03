---
status: backlog
area: wsp-mobile
phase: nice-to-have
created: 2026-01-02
---

# Form Detection API Flag

## Context
The mobile API should include a flag indicating whether a page contains a form. This allows the app to automatically switch to WebView rendering or prompt for external browser when a form is present.

Per the spec: "If Option A [WebView], the KQL query should include a flag indicating form presence."

## Tasks
- [ ] Add `has_form` field to page API response in wsp-mobile plugin
- [ ] Detect form presence by checking for form blocks in page content
- [ ] Update PageData interface in RN app to expect `has_form` field
- [ ] Test flag is correctly set for pages with and without forms

## Notes
- The `PageData` interface already has `has_form?: boolean` defined but it may not be populated by the API
- Forms on MIP sites are built with Vue.js and require JavaScript to function
