---
status: done
area: rn-mip-app
phase: core
created: 2026-01-03
---

# Android Release Build Exploratory Testing

Quick update: I did this manually and logged a couple issues. Nothing major. I should do this again later.

## Context
We've completed significant development work on iOS and need to verify everything works correctly on Android. This ticket is for building a Release APK and performing exploratory testing on an Android emulator, focusing on recently completed features.

**Recently Completed Tickets to Verify:**
- [051](051-external-links-handling.md) - External Links Handling
- [052](052-internal-links-url-mapping.md) - Internal Links URL-to-UUID Mapping
- [053](053-remove-html-crash-debug-screen.md) - Remove Debug Elements from HomeScreen
- [054](054-internal-page-back-navigation.md) - Internal Page Back Navigation Not Working
- [055](055-quick-tasks-in-app-alternatives.md) - Quick Tasks In-App Alternatives
- [056](056-homepage-featured-section-content.md) - Homepage Featured Section Content
- [057](057-header-safe-area-insets.md) - Header Should Respect Safe Area Insets

**In Progress (when complete):**
- [058](058-tab-icons.md) - Add Icons to Each Tab

## Tasks
- [ ] Build Release APK for Android emulator
- [ ] Install APK on Android emulator
- [ ] Run existing Android Maestro tests to verify baseline
- [ ] Perform exploratory testing on completed features:
  - [ ] External links open in browser correctly
  - [ ] Internal links navigate to correct pages
  - [ ] No debug elements visible on HomeScreen
  - [ ] Back navigation works on internal pages
  - [ ] Quick Tasks navigate to correct destinations
  - [ ] Homepage Featured section displays content
  - [ ] Header respects safe area insets
  - [ ] Tab icons display correctly (if 058 complete)
- [ ] Document any Android-specific issues found
- [ ] Create tickets for any work items identified

## Notes

### Build Commands

```bash
# Navigate to app directory
cd rn-mip-app

# Build Release APK for Android
eas build --platform android --profile preview --local

# Or for faster local testing without EAS:
npx expo run:android --variant release
```

### Exploratory Testing Checklist

**Homepage:**
- [ ] Logo displays correctly
- [ ] Quick Tasks section renders
- [ ] Get Connected section renders
- [ ] Featured section displays content
- [ ] No debug/crash info visible

**Navigation:**
- [ ] Tab bar displays with icons
- [ ] Tab switching works smoothly
- [ ] Internal links navigate correctly
- [ ] Back button returns to previous page
- [ ] Android hardware back button works

**Content Pages:**
- [ ] Pages load without errors
- [ ] Images render correctly
- [ ] Text displays properly
- [ ] External links open in browser

**Forms (if applicable):**
- [ ] Prayer Request form loads
- [ ] Chaplain Request form loads

### Issues Found

> Add any issues found during testing here. For each issue, determine if it needs a new ticket.

**Template for documenting issues:**
```
**Issue:** [Brief description]
**Steps to Reproduce:**
1. Step 1
2. Step 2
**Expected:** [What should happen]
**Actual:** [What actually happens]
**Severity:** [Critical/High/Medium/Low]
**New Ticket Needed:** Yes/No - [ticket number if created]
```

### New Tickets Created

> List any new tickets created as a result of this exploratory testing:

- (none yet)
