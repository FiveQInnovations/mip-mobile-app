---
title: "TEST: Increase ContentCard shadow opacity"
status: in-progress
priority: low
created: 2026-01-17
labels: [test, trivial]
---

## Description

**This is a trivial test ticket to verify the implement-ticket agent does NOT change status to QA.**

Increase the ContentCard shadow opacity from 0.1 to 0.15 for a slightly more pronounced shadow effect.

## Acceptance Criteria

- [ ] ContentCard shadows are slightly more visible
- [ ] Change is visible on the homepage where cards appear

## Technical Details

**File:** `rn-mip-app/components/ContentCard.tsx`
**Line:** 68
**Change:** `shadowOpacity: 0.1,` → `shadowOpacity: 0.15,`

## Research Findings (Scouted)

### Code Locations

| File | Line | Current | Change To |
|------|------|---------|-----------|
| `rn-mip-app/components/ContentCard.tsx` | 68 | `shadowOpacity: 0.1,` | `shadowOpacity: 0.15,` |

### Implementation Plan

1. Open `rn-mip-app/components/ContentCard.tsx`
2. Find line 68: `shadowOpacity: 0.1,`
3. Change to: `shadowOpacity: 0.15,`

### Files that DON'T need changes

- All other files
