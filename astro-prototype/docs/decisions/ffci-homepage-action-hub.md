# Decision: FFCI v1 homepage = Action Hub

- **Date**: 2025-12-20
- **Decision**: Use **Action Hub + Quick Tasks** as the FFCI mobile app homepage for v1.
- **Context**: Text-first site; minimal media; **no offline** in v1; tight timeline; homepage should be **resource-focused** (per meeting).

## Why we chose this

- **Highest user value with lowest complexity**: puts the most-used tasks (forms + resources) one tap away.
- **Strong app-like feel**: the home screen is a “utility dashboard” rather than a mirrored web page.
- **Reusable across future client apps**: the same pattern works for most ministry/nonprofit sites (forms + resources + events + locations).
- **Apple review posture**: a task hub demonstrates app-specific utility and structure (not a thin wrapper).
- **Fits current FFCI content reality**: resources are mostly PDFs/links; chapters are numerous; events exist but are not deeply structured yet.

## Homepage structure (v1)

### Primary section: Quick Tasks (top of home)

Large tappable cards (2x2 grid on mobile):
- **Prayer Request** (in-app form)
- **Chaplain Request** (in-app form)
- **Resources** (in-app list of PDFs/links)
- **Donate/Give** (opens external link)

Design intent:
- Big touch targets (thumb-friendly)
- Clear icon + label + 1-line description
- Use brand colors sparingly (don’t overwhelm)

### Secondary section: Get Connected

Compact cards or list items:
- **Find a Chapter** (chapters directory / search)
- **Upcoming Events** (next 1–3 items; simple list acceptable in v1)

### Tertiary section: Featured / Highlight

One rotating highlight to keep the homepage feeling “alive” without requiring a full feed:
- **Featured Resource** (PDF/link) *or*
- **Featured Chapter** *or*
- **Featured Event**

## Explicit v1 constraints

- **No offline mode** (do not build around caching/downloading in v1)
- **English-only**
- **Keep “extras” out of scope**: Bible integration, in-app notes, full media features (these are phase 2 items)

## Success criteria (v1)

- A first-time user can complete these in **≤2 taps**:
  - Submit a prayer request
  - Request a chaplain
  - Find resources
  - Find a chapter
- Homepage loads fast and feels native (no “webpage scroll fatigue”).
- Pattern can be reused for the next client with minimal changes (swap labels/links/config).





