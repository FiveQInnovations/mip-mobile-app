---
name: manager-ios-swift-manual
description: Orchestrate iOS Swift ticket work with subagents using manual verification only. Use when implementing iOS tickets while explicitly skipping Maestro and skipping visual-tester automation.
---

# iOS Swift Manual Manager Workflow

Orchestrate iOS Swift ticket implementation using specialized subagents, with manual verification instead of UI automation.

**Core principle:** The Manager coordinates and decides, but never writes code. Route iOS Swift code changes to `implement-ios-swift`.

## Workflow Steps

```
1. SCOUT → 2. IMPLEMENT (NO MAESTRO) → 3. BUILD/INSTALL CHECK → 4. MANUAL VERIFY → 5. DECIDE → 6. QA → 7. RETROSPECTIVE
```

### 1. Scout (Optional but Recommended)

**Agent:** `scout-ticket`

**When to use:**
- Ticket lacks "Research Findings (Scouted)" section
- Complex ticket touching multiple Swift files
- Unfamiliar iOS codebase area

**Skip if:** Ticket already has detailed scouted findings.

### 2. Implement (No Maestro)

**Route based on ticket `area` field:**

| Ticket Area | Agent | What it does |
|-------------|-------|--------------|
| `area: ios-mip-app` (or no area) | `implement-ios-swift` | Swift changes with simulator build/install checks, no Maestro |
| `area: wsp-mobile` | `implement-wsp-mobile` | PHP/API changes, deploys to server |
| `area: ws-ffci` | `implement-ws-ffci` | Kirby CMS content/config changes |

**For tickets touching MULTIPLE areas:** Run in this order:
1. `implement-wsp-mobile` (API must be deployed before app can use it)
2. `implement-ws-ffci` (CMS content changes)
3. `implement-ios-swift` (app consumes API/CMS data)

**Delegate (iOS) with explicit constraints:**
> "Implement ticket {number}: {brief description}. Skip Maestro tests. Do a clean xcodebuild Debug build, install, and launch on simulator UDID `D9DE6784-CB62-4AC3-A686-4D445A0E7B57`. Return manual click-test steps for user verification."

### 2b. Verify Deployment (After wsp-mobile)

**CRITICAL:** After `implement-wsp-mobile` completes, verify deployment happened:

1. **Check git was pushed** - Run `git status` in wsp-mobile repo. It should NOT say "ahead of origin"
2. **Check API response** - Curl the live endpoint and verify expected data:
   ```bash
   curl -s -H "X-API-Key: $MIP_API_KEY" -u "fiveq:demo" \
     "https://ffci.fiveq.dev/mobile-api/menu" | jq '.'
   ```
3. **If deployment failed** - Re-delegate to `implement-wsp-mobile` with explicit push/deploy instructions

### 3. Build/Install Check (No UI Automation)

For iOS tickets, confirm app build/install/launch works on simulator:

- Use `implement-ios-swift` output as primary evidence
- If simulator has infra issues, use `simulator-manager` and retry
- Require evidence of:
  - `xcodebuild ... -configuration Debug ... clean build` success
  - `xcrun simctl install` success
  - `xcrun simctl launch` success

**Do not run `verify-ticket-ios` for this workflow.**

### 4. Manual Verify (Required)

Manual verification is required and performed by the user.

Provide a concise click-path checklist tied to ticket acceptance criteria, then wait for user PASS/FAIL.

Example prompt to user:
> "Please verify ticket {number}: follow these tap steps and confirm PASS/FAIL, plus any screenshot if behavior is off."

### 5. Decide

Based on build/install evidence + user manual result:

| Build/Install | Manual Verify | Action |
|---------------|---------------|--------|
| PASS | PASS | → Move to QA |
| PASS | FAIL | → `implement-ios-swift` with user failure details |
| FAIL - code issue | — | → `implement-ios-swift` with failure details |
| FAIL - infrastructure | — | → `simulator-manager`, then retry build/install |

**After implementer fixes:** Return to step 3 and repeat.

**Max iterations:** 3-4 cycles. If still failing, document issues and move to QA with notes.

### 6. QA

```bash
# Update ticket status
# In the ticket file, change: status: in-progress → status: qa
```

**Commit message format:** `feat(ticket-XXX): {description}`

**Note:** Only move to QA. Never move tickets to done.

### 7. Retrospective

After completing a work session (one or more tickets), create:

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
| 250 | 08:25 | 08:34 | 1 | 0 | implement-ios-swift |
```

---

## Agent Selection Guide

| Task | Agent | Notes |
|------|-------|-------|
| Research ticket before coding | `scout-ticket` | Creates Research Findings section |
| iOS Swift app changes | `implement-ios-swift` | Implement changes and provide build/install evidence |
| API/PHP changes (wsp-mobile) | `implement-wsp-mobile` | Deploys to server, verifies endpoints |
| Kirby CMS changes (ws-ffci) | `implement-ws-ffci` | Tests via DDEV, deploys |
| Fix simulator/app launch issues | `simulator-manager` | Ensures simulator is running |

---

## iOS Build Commands Reference

```bash
# Standard simulator UDID
SIMULATOR_UDID="D9DE6784-CB62-4AC3-A686-4D445A0E7B57"

# Build iOS app (Debug)
cd ios-mip-app
xcodebuild -project FFCI.xcodeproj -scheme FFCI \
  -destination "id=$SIMULATOR_UDID" \
  -configuration Debug clean build

# Install and launch
xcrun simctl install $SIMULATOR_UDID /path/to/FFCI.app
xcrun simctl launch $SIMULATOR_UDID com.fiveq.ffci

# Optional screenshot evidence
xcrun simctl io $SIMULATOR_UDID screenshot /tmp/verify-screenshot.png
```

---

## Simulator Constraints

**IMPORTANT:** There is only ONE iOS simulator available. Simulator-dependent agents must run sequentially.

**Simulator-dependent agents (run one at a time):**
- `implement-ios-swift` (when building/testing on simulator)
- `simulator-manager` (boot/recovery tasks)

**Can run in parallel with simulator agents:**
- `scout-ticket`
- `implement-wsp-mobile`
- `implement-ws-ffci`

---

## DO NOT

- Do NOT write or modify Swift code yourself; always delegate to `implement-ios-swift`
- Do NOT run Maestro tests in this workflow
- Do NOT call `verify-ticket-ios` in this workflow
- Do NOT call `visual-tester` in this workflow
- Do NOT move tickets to done; only QA
- Do NOT use React Native build commands (`expo`, `npm run build:ios:release`)

## YOU CAN

- Delegate implementation and deployment work to specialized subagents
- Use `simulator-manager` when simulator infrastructure is unstable
- Ask user for manual verification before moving ticket to QA
- Update ticket files and create retrospectives in `temp/`
