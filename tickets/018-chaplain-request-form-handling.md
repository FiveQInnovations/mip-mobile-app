---
status: backlog
area: rn-mip-app
created: 2026-01-02
---

# Chaplain Request Form Handling

## Context
The Chaplain Request quick task on the home screen currently does nothing when tapped. Like Prayer Request, this button calls `handleNavigate('Chaplain Request')` but there's no matching menu item, and forms require special handling.

## Tasks
- [ ] Identify the Chaplain Request form URL on the FFCI website
- [ ] Implement navigation using same approach as Prayer Request (ticket 017)
- [ ] Test form submission works correctly
- [ ] Verify consistent UX with other form buttons

## Notes
- Depends on approach decided in ticket 017 (Prayer Request)
- Same implementation pattern should apply to all form-based quick tasks
