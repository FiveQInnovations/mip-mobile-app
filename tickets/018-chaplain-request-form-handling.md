---
status: in-progress
area: rn-mip-app
phase: core
created: 2026-01-02
---

# Chaplain Request Form Handling

## Context
The Chaplain Request quick task on the home screen currently does nothing when tapped. Like Prayer Request, this button calls `handleNavigate('Chaplain Request')` but there's no matching menu item, and forms require special handling.

## Research Findings (from ticket 017)

### Chaplain Request Page Details
- **Page URL**: `https://ffci.fiveq.dev/chaplain-request`
- **Page UUID**: `M9GmWmqtvlpMuoLP`
- **Form UUID**: `IPEdk3YSkRMj8sYw`
- **Form location**: `content/forms/3_chaplain-request/form.txt`

### Page Content
The page includes:
- Header with "Chaplain Request" title and background image
- Phone numbers: USA (805) 796-4757, Europe 00 49 170 8907799
- Form for submitting chaplain request

### Implementation Approach
Same as ticket 017 - use link-out pattern with fallback URL:

```typescript
{
  key: 'chaplain',
  label: 'Chaplain Request',
  onPress: () => handleNavigate('Chaplain Request', 'https://ffci.fiveq.dev/chaplain-request'),
}
```

## Tasks
- [x] Identify the Chaplain Request form URL on the FFCI website
- [x] Implement navigation using same approach as Prayer Request (ticket 017)
- [x] Test form submission works correctly
- [x] Verify consistent UX with other form buttons

## Notes
- Depends on approach decided in ticket 017 (Prayer Request)
- Same implementation pattern should apply to all form-based quick tasks
- One-line change similar to ticket 017

## Verification
- ✅ **Implementation completed**: Added fallback URL `https://ffci.fiveq.dev/chaplain-request` to Chaplain Request button
- ✅ **Release build verified**: Built in Release mode and verified app functionality
- ✅ **Manual MCP exploration**: Verified button exists and is tappable on home screen
- ✅ **Maestro tests passed**: All iOS Maestro tests pass (4/4)
