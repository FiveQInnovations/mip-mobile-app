---
name: manager
description: Orchestrate ticket work with subagents. Use when implementing multiple tickets, running build/verify cycles, or coordinating specialized agents.
---

# Manager Workflow

Orchestrate ticket implementation using specialized subagents.

**Core principle:** The Manager coordinates and decides, but never writes code. Any code change goes through `implement-ticket`.

## Workflow Steps

```
1. SCOUT → 2. IMPLEMENT → 3. VERIFY → 4. VISUAL CHECK → 5. DECIDE → 6. QA → 7. RETROSPECTIVE
```

### 1. Scout (Optional but Recommended)

**Agent:** `scout-ticket`

**When to use:**
- Ticket lacks "Research Findings (Scouted)" section
- Complex ticket touching multiple files
- Unfamiliar codebase area

**Skip if:** Ticket already has detailed scouted findings.

### 2. Implement

**Agent:** `implement-ticket`

**Delegate:** "Implement ticket {number}: {brief description}"

The implementer writes code changes and commits. It does NOT build or verify.

### 3. Verify (Functional)

**Agent:** `verify-ticket`

**Before verifying:** Ensure app is ready using `simulator-manager` if needed.

**Delegate:** "Verify ticket {number}: {what to check}"

Runs Maestro tests and checks the feature works.

**If FAIL:**
- Infrastructure issue → Use `simulator-manager` to fix, then retry verify
- Code issue → Pass back to `implement-ticket` with the failure details

### 4. Visual Check (Required)

**Agent:** `visual-tester`

**Always run** - Design matters for this mobile app. Every ticket gets visual review before QA.

**Delegate with specific instructions from the ticket:**
> "Verify ticket {number}: Check that {specific visual elements from ticket}"

**Example:** "Verify ticket 074: Check scroll arrows appear, left arrow hidden at start, arrows centered vertically on cards"

The visual-tester will return:
- PASS/FAIL verdict
- Design quality score (1-10)
- Specific issues found (if any)

**If FAIL or score < 7:** Pass back to `implement-ticket` with the visual feedback:
> "Fix ticket {number}: Visual tester found: {specific issues from report}"

### 5. Decide

Based on both verification results:

| Verify Result | Visual Result | Action |
|---------------|---------------|--------|
| PASS | PASS (score ≥ 7) | → Move to QA |
| PASS | FAIL or score < 7 | → `implement-ticket` with visual feedback |
| FAIL - code issue | — | → `implement-ticket` with failure details |
| FAIL - infrastructure | — | → `simulator-manager`, then re-verify |

**After implement-ticket fixes:** Return to step 3 (Verify) and repeat the cycle.

**Max iterations:** 3-4 cycles. If still failing, document issues and move to QA with notes.

### 6. QA

```bash
# Update ticket status
# In the ticket file, change: status: in-progress → status: qa
```

**Commit message format:** `feat(ticket-XXX): {description}`

**Note:** Only move to QA. Never move to done - that's the user's job.

### 7. Retrospective

After completing a work session (one or more tickets), create a retrospective:

**File:** `temp/manager-retro-{date}.md`

**Include:**
- Tickets completed
- Time tracking (see below)
- What worked well
- What did NOT work well
- Subagent performance (which succeeded, which failed)
- Recommendations for improvement
- Any new issues discovered

---

## Time Tracking

Track these metrics for each ticket:

```markdown
| Ticket | Start Time | QA Time | Build Cycles | Manual Fixes | Subagents Used |
|--------|------------|---------|--------------|--------------|----------------|
| 074 | 10:00 | 10:45 | 5 | 3 | scout, implement, verify, visual-tester |
```

**Log timestamps** when:
1. Starting work on a ticket
2. Each subagent delegation
3. Each iteration cycle
4. Moving ticket to QA

---

## Agent Selection Guide

| Task | Agent | Notes |
|------|-------|-------|
| Research ticket before coding | `scout-ticket` | Creates Research Findings section |
| Write code changes | `implement-ticket` | Commits changes |
| Build and run tests | `verify-ticket` | Runs Maestro, reports pass/fail |
| Fix simulator/app launch issues | `simulator-manager` | Ensures app is running |
| Visual/design verification | `visual-tester` | **Required** for every ticket before QA |

---

## Multi-Ticket Sessions

When handling multiple tickets:

1. **Prioritize** by complexity (start with substantial, end with simple)
2. **Batch similar tickets** if they touch same files
3. **Track time per ticket** for the retrospective
4. **Commit after each ticket** - don't batch commits across tickets

---

## Decision Framework

### When to iterate vs. move on

**Iterate** (pass to `implement-ticket`) if:
- Clear, fixable issue identified
- Less than 3 iterations so far
- Verify or visual check provided specific feedback

**Move to QA** (with notes) if:
- Issue is ambiguous or requires user input
- 3+ iterations without progress
- Infrastructure issues beyond subagent capabilities

**Never** fix code issues yourself - always pass back to `implement-ticket` with details.

### Visual-tester instructions

**Always use** for every ticket before QA. Provide specific instructions based on the ticket:

> "Verify ticket {number}: Check that {visual elements from ticket acceptance criteria}"

**Score threshold:** If design score < 7, return to implement with feedback.

---

## DO NOT

- Do NOT write or modify code yourself - always delegate to `implement-ticket`
- Do NOT fix bugs yourself - pass failure details to `implement-ticket`
- Do NOT move tickets to `done` status - only QA
- Do NOT skip the visual check - every ticket needs design review
- Do NOT skip the retrospective step
- Do NOT skip functional verification - always run `verify-ticket`

## YOU CAN

- Make multiple subagent delegations in parallel if independent
- Read and analyze tickets directly
- Make commit messages and update ticket status
- Create retrospective files in temp/

---

## Simulator Constraints

**IMPORTANT:** There is only ONE iOS simulator available. Agents that use the simulator must run SEQUENTIALLY, not in parallel.

**Simulator-dependent agents (run one at a time):**
- `visual-tester` - Takes screenshots, interacts with app
- `verify-ticket` - Runs Maestro tests on simulator
- `simulator-manager` - Boots/manages simulator

**Can run in parallel with simulator agents:**
- `scout-ticket` - Read-only codebase research
- `implement-ticket` - Code changes only (no simulator)

**Example:** When verifying multiple tickets, run visual-tester for ticket A, wait for completion, THEN run visual-tester for ticket B.
