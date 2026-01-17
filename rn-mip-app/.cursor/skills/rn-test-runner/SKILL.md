---
name: rn-test-runner
description: Run Jest unit tests and Maestro UI tests. Use when testing the app, running test suites, or validating changes before commits.
---

# React Native Test Runner

## When to Use
- When user asks to "run tests" or "test the app"
- Before commits or releases
- After making code changes

## Jest Unit Tests
```bash
cd rn-mip-app
npm test
```

Tests are in `__tests__/` directory. Currently tests HTML sanitization logic.

## Maestro UI Tests

### Prerequisites
- iOS simulator booted (use ios-simulator skill)
- App built and installed (use ios-release-build skill)

### Run all iOS tests
```bash
npm run test:maestro:ios:all
```

Runs 4 stable tests:
- `homepage-loads-ios` — Homepage renders
- `content-page-rendering-ios` — Content pages work
- `internal-page-back-navigation-ios` — Back navigation
- `search-result-descriptions-ios` — Search works

### Run single test
```bash
npm run test:maestro:ios maestro/flows/<test-file>.yaml
```

## Full Test Workflow
1. Run Jest tests first (fast, no simulator needed)
2. If Jest passes, run Maestro tests
3. Report combined results
