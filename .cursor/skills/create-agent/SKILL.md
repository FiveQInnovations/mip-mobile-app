---
name: create-agent
description: Create subagents for this project with draft review process. Use when creating a new agent, adding a specialized assistant, or setting up task-specific automation.
---

# Create Agent

Create subagents for this project using a draft-then-approve workflow.

## Workflow

1. **Draft** → Create in `temp/draft-{name}-agent.md`
2. **Review** → Stop and wait for user approval
3. **Promote** → Copy to `.cursor/agents/{name}.md`
4. **Cleanup** → Delete draft file

**IMPORTANT:** Always stop after creating the draft and explicitly ask for user approval before promoting.

## Required Sections

Every agent must include these sections:

### 1. Frontmatter

```yaml
---
name: agent-name
description: One-line description of when to delegate to this agent.
model: fast  # or omit for default model
---
```

### 2. When to Use This Agent

Include an **Outcome** statement - what the Manager can trust after this agent completes.

```markdown
## When to Use This Agent

**Outcome:** After this agent completes, [specific guarantee about state/result].

**Delegate to `agent-name` when:**
- Scenario 1 → What it does
- Scenario 2 → What it does

**Example:** [Concrete usage example]
```

### 3. Interaction with Other Agents

Document how this agent relates to existing agents:

```markdown
## Interaction with Other Agents

| Agent | Relationship |
|-------|--------------|
| `implement-ticket` | This agent does X, implement-ticket does Y |
| `verify-ticket` | Often used before/after this agent |
```

### 4. Skills and References

Point to existing skills and docs the agent should use:

```markdown
## Skills to Use

- `.cursor/skills/skill-name/SKILL.md` - What it provides
- `docs/guide-name.md` - Reference for troubleshooting
```

### 5. Core Capabilities

The actual instructions for what the agent does.

### 6. DO NOT / YOU CAN

Clear boundaries on scope.

## Existing Agents (Reference)

Check `.cursor/agents/` for current agents before creating:

| Agent | Purpose | Outcome |
|-------|---------|---------|
| `scout-ticket` | Research tickets before implementation | Ticket has detailed Research Findings section |
| `implement-ticket` | Write code changes for tickets | Code is implemented and committed |
| `verify-ticket` | Build and test the app | Verification report with pass/fail |
| `simulator-manager` | Ensure simulator infrastructure ready | App is installed and running on simulator |

## Existing Skills (Reference)

Check `.cursor/skills/` for skills agents can leverage:

- `ios-simulator` - Simulator UDID, boot/shutdown commands
- `ios-release-build` - Build and install commands
- `rn-test-runner` - Jest and Maestro test commands
- `create-ticket` - Ticket creation format

## Draft File Template

```markdown
---
name: {agent-name}
description: {One-line description}
model: fast
---

## When to Use This Agent

**Outcome:** After this agent completes, [guarantee].

**Delegate to `{agent-name}` when:**
- [Scenario] → [What it does]

**Example:** [Usage example]

---

## Interaction with Other Agents

| Agent | Relationship |
|-------|--------------|
| `implement-ticket` | [How they relate] |
| `verify-ticket` | [How they relate] |

## Skills to Use

- `.cursor/skills/relevant-skill/SKILL.md` - [What it provides]

## Core Capabilities

### 1. [Capability Name]

[Instructions]

## DO NOT

- Do NOT [boundary]

## YOU CAN

- [Allowed action]
```

## Example: Creating an Agent

User: "Create an agent for running database migrations"

1. **Draft** to `temp/draft-db-migrator-agent.md`
2. **Include** all required sections (Outcome, Interactions, Skills)
3. **Stop** and say: "Draft created at `temp/draft-db-migrator-agent.md`. Ready for your review."
4. **Wait** for user approval
5. **Promote** with: `cp temp/draft-db-migrator-agent.md .cursor/agents/db-migrator.md`
6. **Cleanup** with: `rm temp/draft-db-migrator-agent.md`

## Guidelines

- **Keep under 100 lines** if possible for readability
- **Use `fast` model** for straightforward infrastructure tasks
- **Omit model** for complex reasoning tasks (uses default)
- **Reference existing skills** rather than duplicating instructions
- **Be specific about boundaries** - what this agent does vs. others
