# FFCI Homepage Guardrails (v1 scaffolding)

This document is the developer guide for scaffolding the **FFCI v1 homepage** in the Astro prototype.

- **Decision record**: `docs/decisions/ffci-homepage-action-hub.md`
- **Homepage ideas + evaluation**: `docs/notes/ffci-homepage-ideas-v1.md`
- **Kirby styleguide (source-of-truth for brand UI)**: `../sites/ws-ffci-copy/docs/styleguide.md`

## Non-negotiables (v1)

- **Homepage pattern**: **Action Hub + Quick Tasks** (see below).
- **No offline mode**: do not add/download/cache UX to v1.
- **English-only**.
- **No “phase 2” features** on the homepage: Bible integration, in-app notes, full media-first experiences.

## What “Action Hub” means (v1)

### Layout overview

Home is a **utility dashboard**, not a mirrored website page.

Order of sections (top → bottom):
1. **Quick Tasks** (2x2 grid)
2. **Get Connected** (2 small cards / list items)
3. **Featured** (single highlight module)

### 1) Quick Tasks (primary)

Large tappable cards (thumb-friendly):
- **Prayer Request** (in-app form)
- **Chaplain Request** (in-app form)
- **Resources** (in-app list of PDFs/links)
- **Donate/Give** (opens external browser)

Guardrails:
- **Hit area**: minimum 44×44px; preferably larger.
- **Card content**: icon + label + one-line helper text.
- **Do not** place these behind a hamburger menu; they must be visible on initial load.

### 2) Get Connected (secondary)

Two compact items:
- **Find a Chapter** (chapters directory/search)
- **Upcoming Events** (next 1–3; list is fine in v1)

Guardrails:
- **Events** can start simple (link to Events page + show a few items if available).
- Prefer clarity over density.

### 3) Featured (tertiary)

Single rotating “highlight” module (pick ONE source at a time):
- Featured Resource (PDF/link)
- Featured Chapter
- Featured Event

Guardrails:
- This is a lightweight way to make the home feel “alive” without requiring a full feed.
- Keep it short: title + 1–2 lines + CTA.

## Data + routing guardrails

### Source of truth

The homepage should be built to work with the existing Astro data flow:
- Site data: `getSiteData()` (see `src/pages/index.astro`)
- Page data: `getPage(uuid)` (see `src/lib/api.ts`)

### Mapping the “Quick Tasks” buttons

**Do not hardcode environment-specific URLs**. Use one of these patterns:
- **Preferred**: map tasks to known page UUIDs via config (e.g. `configs/ffci.json`) or via `site_data` fields (if/when the API provides them).
- **Fallback**: map by menu label match (“Prayer Request”, “Chaplain Request”, “Resources”) only if UUIDs are unavailable.

Donate:
- Treat as **external** (open system browser/tab). Keep copy explicit: “Opens in browser”.

### Don’t break existing navigation

The homepage must remain compatible with:
- Header shell (`src/layouts/MobileLayout.astro`)
- Bottom nav (`src/components/Navigation.astro`)

Keep “Home” reachable from the logo and/or nav.

## Styleguide guardrails (FFCI brand)

### Brand colors (Kirby)

Use these as the primary brand references (from `../sites/ws-ffci-copy/docs/styleguide.md`):
- **FFCI Red**: `#D9232A`
- **FFCI Blue**: `#024D91`
- **Light Gray**: `#D9D9D9`

Practical application on the homepage:
- Use **neutral surfaces** for most cards.
- Use **Red/Blue** as accents (icons, borders, CTA chips), not as full-page backgrounds.
- Reserve stronger fills for primary CTAs only (avoid visual fatigue).

### Typography

Keep it app-like:
- Page title: bold, short (1 line).
- Card labels: medium/semibold.
- Helper text: smaller and muted.

### Components (Kirby primitives to emulate)

Kirby’s site uses button variants that communicate hierarchy:
- `._button` (default)
- `._button-priority` (primary)

In Astro we won’t reuse those classes directly, but **we should emulate the hierarchy**:
- Default action: neutral card/button
- Primary action: stronger visual emphasis (border + icon + CTA), not a huge banner

### Current Astro theme config note

`configs/ffci.json` currently uses teal values (`primaryColor`, `secondaryColor`).  
If the goal is to match FFCI brand, adjust theme variables to align with:
- `#D9232A` (primary) and `#024D91` (secondary)

Do this carefully so it doesn’t unintentionally affect other screens.

## UX requirements (app-like, Apple-friendly)

- **Immediate utility**: Quick Tasks must be “front and center”.
- **Fast perceived load**: show skeletons/placeholders if data is delayed.
- **No web-page fatigue**: avoid long blocks of HTML content on home.
- **Accessibility**: tappable controls need labels, focus states, and sufficient contrast.

## Testing/QA guardrails

Maintain or add stable selectors:
- Use `data-testid` for Quick Task cards and sections.
- Keep existing homepage tests in mind (`cypress/e2e/navigation.cy.ts`, `app-launch.cy.ts`).

Minimum manual QA checklist:
- Home loads with no API (graceful empty states)
- Home loads with API (all cards render)
- External donate link opens correctly
- Back button behavior remains correct

