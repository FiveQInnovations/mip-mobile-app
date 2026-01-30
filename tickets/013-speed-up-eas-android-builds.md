---
status: cancelled
area: rn-mip-app
created: 2026-01-21
---

# Speed Up EAS Android Build Time

## Context
EAS Android builds are currently taking approximately 18 minutes, with the Gradle step being the primary bottleneck. This significantly slows down the development and testing workflow. Need to explore optimization strategies to reduce build times.

## Tasks
- [ ] Research EAS build optimization options (caching, build profiles, resource classes)
- [ ] Review current `eas.json` build configuration for optimization opportunities
- [ ] Investigate Gradle build cache configuration
- [ ] Check if using a higher resource class would speed up builds
- [ ] Explore Android build profile optimizations (e.g., `developmentClient: true` for dev builds)
- [ ] Benchmark build times before and after optimizations
- [ ] Document findings and recommended optimizations

## Notes

