# Action Hub Homepage Decision

**Date:** December 24, 2024  
**Status:** Active

## Decision

The FFCI mobile app will use an **Action Hub** homepage layout instead of allowing CMS-controlled homepage types (Content, Collection, Button List). The Action Hub provides a curated, action-oriented interface with Quick Tasks, Get Connected, and Featured sections.

## Rationale

- The Action Hub layout provides better UX for FFCI's use case with prominent action buttons
- Quick Tasks section makes key actions (Prayer Request, Chaplain Request, Resources, Donate) immediately accessible
- Get Connected section highlights Chapters and Events prominently
- Featured section provides a spotlight for important content
- This approach is more intentional and user-focused than generic CMS-driven layouts

## Implementation

- FFCI sites are automatically detected and forced to use `action-hub` homepage type
- CMS settings for `mobileHomepageType`, `mobileHomepageContent`, and `mobileHomepageCollection` are disabled/grayed out in the Kirby Panel
- The Action Hub layout is hardcoded in the Astro prototype for FFCI sites

## Components

The Action Hub consists of three main sections:

1. **Quick Tasks** (`QuickTasks.astro`)
   - 2x2 grid of action cards
   - Prayer Request, Chaplain Request, Resources, Donate

2. **Get Connected** (`GetConnected.astro`)
   - Vertical list of connection cards
   - Find a Chapter, Upcoming Events

3. **Featured** (`Featured.astro`)
   - Single featured card
   - Highlights Resources or other important content

## Reference

See `ffci-homepage-action-hub.png` for visual reference of the desired layout.

