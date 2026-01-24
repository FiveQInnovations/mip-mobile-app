---
name: create-ticket
description: Create tickets in the mip-mobile-app ticket system. Use when the user asks to create a ticket, add a task, or track work items for this project.
---

# Create Ticket

Create tickets in the project's markdown-based ticket tracking system.

## Workflow

1. **Determine the next ticket number** - Check `tickets/TICKETS.md` for the highest existing ticket number
2. **Create the ticket file** - Write to `tickets/NNN-slug-name.md` with YAML frontmatter
3. **Regenerate TICKETS.md** - Run `node tickets/generate-readme.js`

## Ticket File Format

```markdown
---
status: backlog
area: rn-mip-app
phase: core
created: YYYY-MM-DD
---

# Ticket Title

## Context

Why this ticket exists and any relevant background.

## Goals

1. Primary goal
2. Secondary goal

## Acceptance Criteria

- Specific, testable criteria
- What "done" looks like

## Notes

- Additional context
- Related information

## References

- Links to related files, tickets, or external resources
```

## Valid Frontmatter Values

### status (required)
| Value | Meaning |
|-------|---------|
| `backlog` | Not started yet |
| `in-progress` | Currently working on |
| `qa` | Ready for review |
| `blocked` | Waiting on something else |
| `maybe` | Low priority, revisit later |
| `done` | Completed (move to `done/` folder) |

### area (required)
| Value | Meaning |
|-------|---------|
| `android-mip-app` | Native Android Jetpack Compose app |
| `rn-mip-app` | React Native mobile app (legacy) |
| `wsp-mobile` | Kirby plugin for mobile API |
| `ws-ffci-copy` | Kirby site configuration |
| `astro-prototype` | Astro PWA prototype |
| `general` | Cross-cutting or repo-level tasks |

### phase (required)
| Value | Meaning |
|-------|---------|
| `core` | Core functionality, fix first |
| `nice-to-have` | Polish, not blocking launch |
| `c4i` | C4I-specific, after FFCI launch |
| `production` | Final tasks before App Store submission |
| `testing` | Ongoing test coverage |

### created (required)
Use format `YYYY-MM-DD` (e.g., `2026-01-16`)

## File Naming Convention

`tickets/NNN-descriptive-slug.md`

- `NNN` = Zero-padded 3-digit number (e.g., `069`)
- `descriptive-slug` = Lowercase, hyphen-separated summary

## Regenerate TICKETS.md

After creating or modifying tickets, always run:

```bash
node tickets/generate-readme.js
```

This updates `tickets/TICKETS.md` with the current ticket list.

## Example

Creating ticket #070 for a new feature:

**File:** `tickets/070-add-push-notifications.md`

```markdown
---
status: backlog
area: rn-mip-app
phase: nice-to-have
created: 2026-01-16
---

# Add Push Notifications

## Context

Users want to receive notifications when new content is published.

## Goals

1. Implement push notification infrastructure
2. Allow users to opt-in/out of notifications

## Acceptance Criteria

- Users can enable/disable notifications in settings
- Notifications appear when new content is published
- Deep links from notifications open the correct content

## Notes

- Consider using Expo Push Notifications for cross-platform support
- May require backend changes to trigger notifications
```
