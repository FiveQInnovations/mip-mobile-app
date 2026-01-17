---
title: "TEST: Increase ContentCard border radius"
status: qa
priority: low
created: 2026-01-17
labels: [test, trivial]
---

## Description

**This is a trivial test ticket to validate the implement-ticket agent workflow.**

Change the ContentCard border radius from 8px to 12px for a slightly more rounded appearance.

## Acceptance Criteria

- [x] ContentCard corners are visibly more rounded
- [x] Change is visible on the homepage where cards appear

## Technical Details

**File:** `rn-mip-app/components/ContentCard.tsx`
**Line:** 62
**Change:** `borderRadius: 8` → `borderRadius: 12`

## Research Findings (Scouted)

### Code Locations

| File | Line | Current | Change To |
|------|------|---------|-----------|
| `rn-mip-app/components/ContentCard.tsx` | 62 | `borderRadius: 8,` | `borderRadius: 12,` |

### Implementation Plan

1. Open `rn-mip-app/components/ContentCard.tsx`
2. Find line 62: `borderRadius: 8,`
3. Change to: `borderRadius: 12,`

### Files that DON'T need changes

- All other files
