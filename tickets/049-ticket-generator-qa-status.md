---
status: backlog
area: tickets
phase: tooling
created: 2026-01-03
---

# Ticket Generator Does Not Recognize "qa" Status

## Context
The ticket status workflow defined in `.cursor/rules/ticket-status-workflow.mdc` specifies:
- `backlog` → `in-progress` → `qa` → `done`

However, the pre-commit ticket README generator shows a warning when a ticket uses `qa` status:
```
Warning: Unknown status "qa" in 047-reliable-maestro-tests-ios.md
```

The commit succeeds, but `qa` tickets are not properly counted in the status breakdown.

## Tasks
- [ ] Find the ticket README generator script
- [ ] Add "qa" to the list of valid statuses
- [ ] Verify warning no longer appears for qa status tickets
- [ ] Verify qa tickets are counted in status breakdown

## Notes
- The workflow rule is correct; the generator script needs updating
- This is a tooling issue, not blocking any work
