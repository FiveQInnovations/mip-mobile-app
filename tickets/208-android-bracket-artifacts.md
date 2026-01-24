---
status: backlog
area: android-mip-app
phase: core
created: 2026-01-24
---

# Red Bracket Artifacts in Content

## Context

Red bracket characters (`{` or `}`) are appearing in rendered content on the Resources page and potentially other pages. These artifacts appear where content blocks should be, suggesting template syntax or JSON structure is leaking into the rendered HTML.

## Symptoms

- Small red bracket characters visible in content
- Brackets appear at positions where other content (buttons, cards) should render
- Creates visual clutter and indicates rendering failures

## Goals

1. Identify the source of bracket artifacts
2. Prevent brackets from appearing in rendered content
3. Ensure underlying content renders correctly

## Acceptance Criteria

- No bracket artifacts visible in any page content
- All content blocks render correctly
- Clean visual presentation without template syntax leakage

## Technical Investigation Needed

1. **Check API response** - Are brackets present in the JSON/HTML from the API?
2. **Check Kirby block conversion** - Is `toBlocks()->toHTML()` outputting brackets?
3. **Check wsp-mobile transformation** - Is content transformation adding brackets?
4. **Check WebView CSS** - Are brackets styled elements that should be hidden?

## Possible Causes

1. **JSON syntax leakage** - Block structure `{}` not fully converted to HTML
2. **Template syntax** - Kirby/PHP template markers not processed
3. **HTML entities** - Curly bracket entities rendering as text
4. **CSS pseudo-elements** - Styled elements using bracket content

## References

- Screenshot: Resources page showing bracket artifacts
- Related: ticket 207 (missing buttons - brackets appear where buttons should be)
- API plugin: `/Users/anthony/mip/fiveq-plugins/wsp-mobile/lib/pages.php`
