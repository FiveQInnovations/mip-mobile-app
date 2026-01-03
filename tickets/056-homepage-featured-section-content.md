---
status: backlog
area: rn-mip-app
phase: nice-to-have
created: 2026-01-19
---

# Homepage Featured Section Content

## Context

After implementing ticket 055 (Quick Tasks In-App Alternatives), the homepage will have:
- **Quick Tasks**: Chapters, Events, Resources, Get Involved (all in-app)
- **Get Connected**: Prayer Request, Chaplain Request, Donate (browser-based)
- **Featured**: Currently shows Resources

Since Resources will now be in Quick Tasks, the Featured section needs new content or should be removed/repurposed.

## Problem

The current Featured section points to Resources, which creates redundancy when Resources is promoted to Quick Tasks. We need to decide what content belongs in the Featured section.

## Current Implementation

```typescript
const featured = {
  label: 'Featured',
  title: 'Resources',
  description: 'Featured resource links',
  onPress: () => handleNavigate('Resources'),
  testID: 'home-featured',
};
```

The Featured section renders as a highlighted card with a "Featured" badge, distinct from Quick Tasks and Get Connected sections.

## Options

### Option 1: Remove Featured Section Entirely
**Description**: Delete the Featured section from the homepage.

**Pros**:
- Simpler homepage, less scrolling
- No redundancy
- Fewer things to maintain

**Cons**:
- Loses visual variety on homepage
- One less opportunity to highlight content

---

### Option 2: Featured Chapter (Static)
**Description**: Highlight a specific chapter (like the website's "Metro Atlanta Chapter").

**Content**:
- Title: "Featured Chapter"
- Subtitle: "Metro Atlanta"
- Description: Brief intro about the chapter
- Action: Navigate to chapter detail or Chapters page

**Pros**:
- Matches website pattern
- Promotes community engagement
- Showcases real ministry activity

**Cons**:
- Requires manual updates to rotate chapters
- Static content could feel stale
- May need chapter-specific page/UUID

---

### Option 3: Featured Event (Dynamic or Static)
**Description**: Highlight an upcoming event.

**Content**:
- Title: "Upcoming Event"
- Subtitle: Event name (e.g., "FFC First Responder's Retreat")
- Description: Date and location
- Action: Navigate to Events page or event detail

**Pros**:
- Time-sensitive, creates urgency
- Drives event attendance
- Could be dynamic (next upcoming event from API)

**Cons**:
- Static version needs manual updates
- Dynamic version requires API changes
- May show nothing if no events scheduled

---

### Option 4: Call to Action (Know God)
**Description**: Highlight the gospel/salvation message.

**Content**:
- Title: "Do You Know God?"
- Description: "You were created to know God personally"
- Action: Link to harvest.org or similar (browser)

**Pros**:
- Core mission of FFCI
- Always relevant
- Prominent placement for most important message

**Cons**:
- Opens browser (like Resources page's "Find Out How" link)
- Already accessible on Resources page

---

### Option 5: Crisis Support Banner
**Description**: Highlight crisis/mental health resources.

**Content**:
- Title: "Need someone to talk to?"
- Description: "Call or text 988 - Confidential. Free. 24/7."
- Action: Link to 988lifeline.org (browser)

**Pros**:
- Critical resource for first responders
- Life-saving visibility
- Matches website's crisis section

**Cons**:
- Opens browser
- Sensitive topic placement needs care
- May want dedicated always-visible placement instead

---

### Option 6: Rotating/Configurable Featured
**Description**: Make Featured section configurable from CMS.

**Content**:
- Pull from a "featured" field in site settings
- Could be any page, event, chapter, or external link

**Pros**:
- Flexible, no code changes needed
- FFCI can update as needed
- Supports campaigns, seasonal content

**Cons**:
- Requires API/plugin changes
- More complex implementation
- Out of scope for v1?

---

### Option 7: FFC Store Promotion
**Description**: Highlight the FFC Store for merchandise.

**Content**:
- Title: "FFC Store"
- Description: "Gear and resources that spark conversations"
- Action: Navigate to Store page (in-app)

**Pros**:
- Drives merchandise sales
- Navigates in-app
- Supports FFCI revenue

**Cons**:
- Commercial feel may not fit
- Store page might link out to external store anyway

---

### Option 8: Get Involved / Volunteer
**Description**: Highlight volunteer/outreach opportunities.

**Content**:
- Title: "Serve with FFC"
- Description: "Join an outreach trip or training mission"
- Action: Navigate to Get Involved page (in-app)

**Pros**:
- Action-oriented
- Drives volunteer engagement
- Navigates in-app

**Cons**:
- Get Involved already in Quick Tasks (per ticket 055)
- Redundant

## Recommendation

**Primary**: Option 4 (Know God) or Option 5 (Crisis Support)

**Rationale**:
- Both are mission-critical content that deserves prominent placement
- Neither is duplicated elsewhere on homepage
- "Know God" aligns with FFCI's core mission
- Crisis Support serves first responders' unique needs

**Secondary consideration**: Option 1 (Remove) if homepage feels too busy after Quick Tasks/Get Connected swap.

## Tasks

- [ ] Decide which option to implement
- [ ] Update `featured` object in `HomeScreen.tsx`
- [ ] Update Featured section UI if needed (different layout for different content types)
- [ ] Test navigation/link behavior
- [ ] Update Maestro tests if Featured section changes

## Related

- **Ticket 055**: Quick Tasks In-App Alternatives (depends on this completing first)
- `rn-mip-app/components/HomeScreen.tsx` - Featured section implementation

## Notes

- Featured section currently uses a distinct visual style (blue background, badge)
- Consider whether Featured should always be in-app navigation or can include browser links
- Crisis Support option may warrant always-visible placement (header/footer) rather than Featured section
