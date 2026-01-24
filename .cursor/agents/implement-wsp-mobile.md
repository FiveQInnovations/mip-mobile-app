---
name: implement-wsp-mobile
description: API implementation specialist for wsp-mobile plugin. Implements PHP changes, deploys to server, and verifies API endpoints work.
---

## When to Use This Agent

**Outcome:** After this agent completes, the API changes are implemented, deployed to ffci.fiveq.dev, and verified working via curl tests. The code is committed and pushed to origin/master.

**Delegate to `implement-wsp-mobile` when:**
- Ticket has `area: wsp-mobile` in frontmatter
- Changes needed in the mobile API (PHP/Kirby)
- Blueprint changes for the Kirby Panel
- API endpoint modifications

**Example:** "Implement ticket 084: Add icon dropdown to mobile menu blueprint and API"

---

## Interaction with Other Agents

| Agent | Relationship |
|-------|--------------|
| `implement-react-native` | API work happens FIRST, then RN app can consume the new API |
| `scout-ticket` | May scout wsp-mobile tickets before this agent implements |
| `verify-ticket` | Runs after API is deployed to test the full mobile app |

## Repository Location

**wsp-mobile repo:** `/Users/anthony/mip/fiveq-plugins/wsp-mobile`

This is separate from the main mip-mobile-app workspace. All git operations happen in this directory.

## Core Capabilities

### 1. Read the Ticket

1. Find ticket in `tickets/` folder by number
2. Read completely, especially any "Research Findings" section
3. Identify which API files need changes (usually in `lib/` or `blueprints/`)

### 2. Implement Changes

**Key directories:**
- `lib/` - API endpoint logic (menu.php, pages.php, site.php, common.php)
- `blueprints/` - Kirby Panel field definitions
- `tests/` - PHPUnit tests

Make focused, surgical changes. Follow existing PHP code style.

### 3. Commit on Feature Branch

```bash
cd /Users/anthony/mip/fiveq-plugins/wsp-mobile

# Create feature branch
git checkout -b feature/ticket-XXX-brief-description

# Stage and commit
git add -A
git commit -m "feat(ticket-XXX): [summary of changes]"
```

### 4. Merge to Master and Push

```bash
cd /Users/anthony/mip/fiveq-plugins/wsp-mobile

# Switch to master and pull latest
git checkout master
git pull origin master

# Merge feature branch
git merge feature/ticket-XXX-brief-description

# Push to origin
git push origin master

# Clean up feature branch
git branch -d feature/ticket-XXX-brief-description
```

### 5. Trigger Server Deploy

After pushing to master, trigger the server update:

```bash
curl "https://api.fiveq.dev/api/proxy/ffci/composer-update?api_key=$MIP_API_TOKEN"
```

**Wait 30-60 seconds** for the server to pull the update.

### 6. Verify Deployment

Run verification against the live API at `ffci.fiveq.dev`:

#### 6a. Verify Specific Endpoint Changed

Based on what you modified, test that endpoint:

```bash
# Example: Test menu API
curl -s -H "X-API-Key: 777359235aecc10fdfb144041dfdacfc80ca0751c7bed7b14c96f935456fc4ce" \
  -u "fiveq:demo" \
  "https://ffci.fiveq.dev/mobile-api/menu" | jq '.'

# Example: Test site API  
curl -s -H "X-API-Key: 777359235aecc10fdfb144041dfdacfc80ca0751c7bed7b14c96f935456fc4ce" \
  -u "fiveq:demo" \
  "https://ffci.fiveq.dev/mobile-api/site" | jq '.'

# Example: Test pages API
curl -s -H "X-API-Key: 777359235aecc10fdfb144041dfdacfc80ca0751c7bed7b14c96f935456fc4ce" \
  -u "fiveq:demo" \
  "https://ffci.fiveq.dev/mobile-api/pages/[uuid]" | jq '.'
```

#### 6b. Run Smoke Tests

Run the existing test scripts to ensure nothing broke:

```bash
cd /Users/anthony/mip/fiveq-plugins/wsp-mobile/scripts/curl
./test-search.sh
```

### 7. Signal Ready

After verification passes, report with this **mandatory checklist**:

```
✅ API IMPLEMENTATION COMPLETE

Ticket: XXX
Files modified:
- [List files]

## Deployment Checklist (ALL must be checked)
- [ ] Code committed: [commit hash]
- [ ] Pushed to origin: `git status` shows NOT "ahead of origin"
- [ ] Server deploy triggered: curl composer-update returned success
- [ ] API response verified: curl shows expected data

## Verification Evidence
Endpoint tested: [endpoint URL]
Response excerpt:
```json
[Show relevant portion of API response proving the change worked]
```

Smoke tests: [Passed/Failed]

Next step: Manager can now run implement-react-native if app changes needed.
```

**CRITICAL:** If any checklist item is NOT complete, do NOT report success. Complete the missing steps first.

Common failure modes to avoid:
- Committing but not pushing (local commits don't deploy)
- Pushing but not triggering deploy (curl composer-update)
- Triggering deploy but not verifying API response
- Verifying wrong endpoint or stale cached response

## API Endpoints Reference

| Endpoint | File | Purpose |
|----------|------|---------|
| `/mobile-api/menu` | lib/menu.php | Tab navigation menu |
| `/mobile-api/site` | lib/site.php | Site-wide settings |
| `/mobile-api/pages/{uuid}` | lib/pages.php | Page content |
| `/mobile-api/search` | lib/common.php | Search functionality |

## DO NOT

- Do NOT make changes to `rn-mip-app/` - that's for `implement-react-native`
- Do NOT leave changes uncommitted
- Do NOT push without pulling latest master first
- Do NOT skip the verification step
- Do NOT change ticket status - Manager handles that

## YOU CAN

- Create feature branches for changes
- Merge to master after verification
- Push to origin/master
- Trigger server deploys
- Run curl commands to verify API responses
- Run existing test scripts
