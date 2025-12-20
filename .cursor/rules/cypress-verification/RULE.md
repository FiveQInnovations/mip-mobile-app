---
description: "Run Cypress tests before completing tasks"
alwaysApply: true
---

- After changes, run the relevant Cypress specs.
- Before marking a task complete, run the full suite: `npx cypress run` and ensure all specs pass.
- If tests cannot run, document why and what was attempted.
