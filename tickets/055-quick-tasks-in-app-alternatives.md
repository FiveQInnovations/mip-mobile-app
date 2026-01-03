---
status: qa
area: rn-mip-app
phase: core
created: 2026-01-19
---

# Quick Tasks In-App Alternatives

## Problem

Currently, 3 out of 4 Quick Tasks on the home screen open an external browser, creating a fragmented user experience:

| Quick Task | Navigation |
|------------|------------|
| Prayer Request | Browser ❌ |
| Chaplain Request | Browser ❌ |
| Donate | Browser ❌ |
| Resources | In-app ✅ |

Meanwhile, the "Get Connected" section has items that navigate in-app (Chapters, Events) but are in a less prominent position.

## Solution

Swap the homepage sections so that **Quick Tasks are 100% in-app** and browser-based items move to "Get Connected":

**Before:**
```
Quick Tasks: Prayer Request, Chaplain Request, Resources, Donate
Get Connected: Chapters, Events
```

**After:**
```
Quick Tasks: Chapters, Events, Resources, Get Involved  (all in-app)
Get Connected: Prayer Request, Chaplain Request, Donate  (browser-based)
```

This keeps all content accessible while prioritizing native navigation for primary actions.

## Tasks

- [x] Update `quickTasks` array in `HomeScreen.tsx`:
  - Chapters, Events, Resources, Get Involved
- [x] Update `getConnected` array in `HomeScreen.tsx`:
  - Prayer Request, Chaplain Request, Donate
- [x] Update Maestro tests for new testIDs and labels
- [x] Test all Quick Tasks navigate in-app correctly
- [x] Test all Get Connected items open browser correctly

## Related

- **Ticket 056**: Homepage Featured Section Content (decide what to do with Featured section after this change)
- `rn-mip-app/components/HomeScreen.tsx` - Quick Tasks implementation

---

## Reference: Implementation Details

### New Quick Tasks Configuration

```typescript
const quickTasks = [
  {
    key: 'chapters',
    label: 'Find a Chapter',
    description: 'Connect with local firefighters',
    icon: '📍',
    onPress: () => handleNavigate('Chapters'),
    testID: 'home-quick-chapters',
  },
  {
    key: 'events',
    label: 'Upcoming Events',
    description: 'Retreats, trainings, & more',
    icon: '📅',
    onPress: () => handleNavigate('Events'),
    testID: 'home-quick-events',
  },
  {
    key: 'resources',
    label: 'Resources',
    description: 'PDFs, videos, & links',
    icon: '📚',
    onPress: () => handleNavigate('Resources'),
    testID: 'home-quick-resources',
  },
  {
    key: 'getinvolved',
    label: 'Get Involved',
    description: 'Outreach & volunteer',
    icon: '🤝',
    onPress: () => handleNavigate('Get Involved'),
    testID: 'home-quick-getinvolved',
  },
];
```

### New Get Connected Configuration

```typescript
const getConnected = [
  {
    key: 'prayer',
    label: 'Prayer Request',
    description: 'Submit a prayer request',
    icon: '🙏',
    onPress: () => handleNavigate('Prayer Request', 'https://ffci.fiveq.dev/prayer-request'),
    testID: 'home-connected-prayer',
  },
  {
    key: 'chaplain',
    label: 'Chaplain Request',
    description: 'Request chaplain support',
    icon: '✝️',
    onPress: () => handleNavigate('Chaplain Request', 'https://ffci.fiveq.dev/chaplain-request'),
    testID: 'home-connected-chaplain',
  },
  {
    key: 'donate',
    label: 'Donate',
    description: 'Support the ministry',
    icon: '💝',
    onPress: () => handleNavigate('Give', 'https://www.firefightersforchrist.org/donate'),
    testID: 'home-connected-donate',
  },
];
```

### Page UUIDs

| Page | UUID |
|------|------|
| Chapters | `pik8ysClOFGyllBY` |
| Events | `6ffa8qmIpJHM0C3r` |
| Resources | `uezb3178BtP3oGuU` |
| Get Involved | `3e56Ag4tc8SfnGAv` |
