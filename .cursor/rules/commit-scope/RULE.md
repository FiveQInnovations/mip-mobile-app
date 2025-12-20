---
description: "Keep commits scoped to the correct project directories"
alwaysApply: true
---

- Stage and commit only within the appropriate project area:
  - `astro-prototype/` for the Astro PWA
  - `plugins/` for the Kirby plugin
  - `sites/` for the Kirby site
- Check file paths before `git add` to avoid cross-project commits.
- Do not stage unrelated or untracked folders unless explicitly requested.
