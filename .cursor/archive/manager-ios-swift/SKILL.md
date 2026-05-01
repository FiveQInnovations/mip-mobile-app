---
name: manager-ios-swift
description: Orchestrate iOS Swift ticket work with subagents. Use when implementing iOS tickets, running build/verify cycles, or coordinating iOS-focused agents.
---

# iOS Swift Manager Workflow

Orchestrate iOS Swift ticket implementation using specialized subagents.

**Core principle:** The Manager coordinates and decides, but never writes code. Route iOS Swift tickets to `implement-ios-swift`.

## Workflow Steps

```
1. SCOUT → 2. IMPLEMENT → 3. VERIFY → 4. VISUAL CHECK → 5. DECIDE → 6. QA → 7. RETROSPECTIVE
```

### 1. Scout (Optional but Recommended)

**Agent:** `scout-ticket`

**When to use:**
- Ticket lacks "Research Findings (Scouted)" section
- Complex ticket touching multiple Swift files
- Unfamiliar iOS codebase area

**Skip if:** Ticket already has detailed scouted findings.

### 2. Implement

**Route based on ticket `area` field:**

| Ticket Area | Agent | What it does |
|-------------|-------|--------------|
| `area: ios-mip-app` (or no area) | `implement-ios-swift` | Swift changes, TDD with Maestro, self-verifies on simulator |
| `area: wsp-mobile` | `implement-wsp-mobile` | PHP/API changes, deploys to server |
| `area: ws-ffci` | `implement-ws-ffci` | Kirby CMS content/config changes |

**For tickets touching MULTIPLE areas:** Run in this order:
1. `implement-wsp-mobile` (API must be deployed before app can use it)
2. `implement-ws-ffci` (CMS content changes)
3. `implement-ios-swift` (app consumes API/CMS data)

**Delegate:** "Implement ticket {number}: {brief description}"

### 2b. Verify Deployment (After wsp-mobile)

**CRITICAL:** After `implement-wsp-mobile` completes, verify the deployment actually happened:

1. **Check git was pushed** - Run `git status` in wsp-mobile repo. It should NOT say "ahead of origin"
2. **Check API response** - Curl the live endpoint and verify expected data is present:
   ```bash
   curl -s -H "X-API-Key: $MIP_API_KEY" -u "fiveq:demo" \
     "https://ffci.fiveq.dev/mobile-api/menu" | jq '.'
   ```
3. **If deployment failed** - Re-delegate to `implement-wsp-mobile` with explicit push/deploy instructions

### 3. Verify (Functional)

**Agent:** `verify-ticket-ios`

**Before verifying:** Ensure simulator is ready using `simulator-manager` if needed.

**Delegate:** "Verify ticket {number}: {what to check}"

Builds iOS app, runs Maestro tests, and checks the feature works.

#### Verification Scope

Choose the appropriate verification level based on what changed:

| Ticket Area | Verification Level | What to Do |
|-------------|-------------------|------------|
| `wsp-mobile` only | **Lightweight** | Verify API response via curl, skip full app build |
| `ios-mip-app` | **Full** | Build app with xcodebuild, run Maestro tests, visual-tester |
| Both areas | **Full** | Deploy API first, then full app verification |

**If FAIL:**
- Infrastructure issue → Use `simulator-manager` to fix, then retry verify
- Code issue → Pass back to `implement-ios-swift` with failure details

### 4. Visual Check (Required)

**Agent:** `visual-tester`

**Always run** - Design matters for this mobile app. Every ticket gets visual review before QA.

**Delegate with specific instructions from the ticket:**
> "Verify ticket {number}: Check that {specific visual elements from ticket}"

The visual-tester will return:
- PASS/FAIL verdict
- Design quality score (1-10)
- Specific issues found (if any)

**If FAIL or score < 7:** Pass back to `implement-ios-swift` with the visual feedback.

### 5. Decide

Based on both verification results:

| Verify Result | Visual Result | Action |
|---------------|---------------|--------|
| PASS | PASS (score ≥ 7) | → Move to QA |
| PASS | FAIL or score < 7 | → `implement-ios-swift` with visual feedback |
| FAIL - code issue | — | → `implement-ios-swift` with failure details |
| FAIL - infrastructure | — | → `simulator-manager`, then re-verify |

**After implementer fixes:** Return to step 3 (Verify) and repeat the cycle.

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

**File:** `temp/manager-ios-retro-{date}.md`

**Include:**
- Tickets completed
- Time tracking
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
| 210 | 10:00 | 10:45 | 3 | 2 | scout, implement-ios-swift, verify-ticket-ios, visual-tester |
```

---

## Agent Selection Guide

| Task | Agent | Notes |
|------|-------|-------|
| Research ticket before coding | `scout-ticket` | Creates Research Findings section |
| iOS Swift app changes | `implement-ios-swift` | TDD with Maestro, self-verifies |
| API/PHP changes (wsp-mobile) | `implement-wsp-mobile` | Deploys to server, verifies endpoints |
| Kirby CMS changes (ws-ffci) | `implement-ws-ffci` | Tests via DDEV, deploys |
| Build and run iOS Maestro tests | `verify-ticket-ios` | Builds with xcodebuild, runs Maestro |
| Fix simulator/app launch issues | `simulator-manager` | Ensures simulator is running |
| Visual/design verification | `visual-tester` | **Required** for every ticket before QA |

---

## iOS Build Commands Reference

```bash
# Standard simulator UDID
SIMULATOR_UDID="D9DE6784-CB62-4AC3-A686-4D445A0E7B57"

# Build iOS app (Debug)
cd ios-mip-app
xcodebuild -project FFCI.xcodeproj -scheme FFCI \
  -destination "id=$SIMULATOR_UDID" \
  -configuration Debug build

# Run Maestro test
bash ./scripts/run-maestro-ios.sh maestro/flows/ticket-XXX-name-ios.yaml

# Take screenshot
xcrun simctl io $SIMULATOR_UDID screenshot /tmp/verify-screenshot.png
```

---

## Multi-Ticket Sessions

When handling multiple tickets:

1. **Prioritize** by complexity (start with substantial, end with simple)
2. **Batch similar tickets** if they touch same Swift files
3. **Track time per ticket** for the retrospective
4. **Commit after each ticket** - don't batch commits across tickets

---

## Decision Framework

### When to iterate vs. move on

**Iterate** (pass to `implement-ios-swift`) if:
- Clear, fixable issue identified
- Less than 3 iterations so far
- Verify or visual check provided specific feedback

**Move to QA** (with notes) if:
- Issue is ambiguous or requires user input
- 3+ iterations without progress
- Infrastructure issues beyond subagent capabilities

**Never** fix code issues yourself - always pass back to `implement-ios-swift` with details.

---

## Simulator Constraints

**IMPORTANT:** There is only ONE iOS simulator available. Agents that use the simulator must run SEQUENTIALLY, not in parallel.

**Simulator-dependent agents (run one at a time):**
- `visual-tester` - Takes screenshots, interacts with app
- `verify-ticket-ios` - Runs Maestro tests on simulator
- `simulator-manager` - Boots/manages simulator
- `implement-ios-swift` - Builds and tests on simulator

**Can run in parallel with simulator agents:**
- `scout-ticket` - Read-only codebase research
- `implement-wsp-mobile` - API changes, no simulator needed
- `implement-ws-ffci` - Kirby CMS changes, no simulator needed

---

## DO NOT

- Do NOT write or modify Swift code yourself - always delegate to `implement-ios-swift`
- Do NOT fix bugs yourself - pass failure details to `implement-ios-swift`
- Do NOT move tickets to `done` status - only QA
- Do NOT skip the visual check - every ticket needs design review
- Do NOT skip the retrospective step
- Do NOT skip functional verification - always run `verify-ticket-ios`
- Do NOT use React Native build commands (`expo`, `npm run build:ios:release`)

## YOU CAN

- Make multiple subagent delegations in parallel if independent (respecting simulator constraints)
- Read and analyze tickets directly
- Make commit messages and update ticket status
- Create retrospective files in temp/
