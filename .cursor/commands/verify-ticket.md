# Verify Ticket

Delegates to the `verify-ticket` subagent to build the React Native app, run Maestro tests, and conduct exploratory testing.

## Usage

```
/verify-ticket <ticket-number>
```

## Example

```
/verify-ticket 069
```

## What it does

The verify agent will:
1. Build the app in Release mode for iOS
2. Run Maestro test suite
3. Conduct exploratory testing via MCP tools
4. Report findings back (pass/fail with evidence)
