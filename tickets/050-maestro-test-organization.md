---
status: cancelled
area: rn-mip-app
phase: testing
created: 2026-01-03
---

# Research Maestro Test Organization

**Cancelled:** Research about iOS/Android test organization is no longer needed - Android testing has been abandoned.

## Context
Currently we have duplicated test files for iOS and Android:
- `homepage-loads-ios.yaml` / `homepage-loads-android.yaml`
- `tab-switch-from-home-ios.yaml` / `tab-switch-from-home-android.yaml`
- `content-page-rendering-ios.yaml` / `content-page-rendering-android.yaml`
- `resources-tab-navigation-ios.yaml` / `resources-tab-navigation-android.yaml`

The tests are nearly identical, differing only in:
- Comments about how to launch the app
- iOS uses `tapOn: "Home tab"` for back navigation (no hardware back button)
- Android uses `- back` for hardware back button

## Questions to Research
1. **Folder structure:** Should we have `maestro/flows/ios/` and `maestro/flows/android/` folders?
2. **Duplication:** Is there a way to share test logic between platforms?
3. **Maestro features:** Does Maestro support platform conditionals or shared flows?
4. **Best practices:** What do other projects do for cross-platform Maestro testing?

## Options to Consider

### Option A: Keep current flat structure with suffix naming
- Pros: Simple, explicit, easy to understand
- Cons: Duplication, changes need to be made in two places

### Option B: Separate folders per platform
- `maestro/flows/ios/*.yaml`
- `maestro/flows/android/*.yaml`
- Pros: Clear separation, easier to run platform-specific tests
- Cons: Still duplicated logic

### Option C: Shared tests with platform conditionals (if supported)
- Single test file with platform-specific sections
- Pros: DRY, single source of truth
- Cons: More complex, may not be supported by Maestro

### Option D: Shared base tests + platform overrides
- Common assertions in shared files
- Platform-specific setup/navigation in separate files
- Pros: Reduces duplication for common logic
- Cons: More complex structure

## Tasks
- [ ] Research Maestro documentation for platform conditionals
- [ ] Research Maestro community best practices
- [ ] Evaluate options and document recommendation
- [ ] Implement chosen approach (separate ticket if needed)

## Notes
- Current approach works, this is an optimization/organization task
- Priority: low - revisit when adding more tests
