---
status: backlog
area: android-mip-app
phase: core
created: 2026-03-06
---

# Fix Non-Responsive CTA Buttons on Content Pages (Android)

## Context

During manual QA of content pages opened via in-app Search, CTA buttons rendered inside page content appeared visually correct but did not navigate when tapped.

Example: on `FAQ`, tapping `Become a Member` did not navigate to another screen or open any in-app error state.

## Goals

1. Ensure CTA links rendered in WebView content are actually tappable
2. Restore expected navigation behavior for internal page links
3. Confirm button/link interactions still respect in-app vs external handling rules

## Acceptance Criteria

- [ ] Tapping CTA buttons in content pages triggers navigation as expected
- [ ] Internal links open within app page flow
- [ ] External links continue to use intended external-link handling
- [ ] Behavior verified on at least `FAQ` and one additional content page

## Notes

- Reproduction example:
  1. Open app
  2. Use Home search for `faq`
  3. Open `FAQ`
  4. Tap `Become a Member`
  5. Observe: no navigation / no visible action
- Related context:
  - `Become a Member` endpoint currently has a separate API 500 issue in ticket `243`
  - Even with that backend issue, the tap should still trigger navigation and then show error state if fetch fails

## References

- Android HTML renderer and link handling: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`
- Related API issue: `tickets/243-become-a-member-page-api-500.md`
