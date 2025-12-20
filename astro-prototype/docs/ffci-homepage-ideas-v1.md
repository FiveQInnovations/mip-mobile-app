# FFCI v1 homepage ideas (text-first, no offline)

## Decision

**Chosen for v1:** **Idea 1 — Action Hub + Quick Tasks**  
Decision record: `docs/decisions/ffci-homepage-action-hub.md`

Context considered:
- **Kirby content**: lots of text + PDFs/external links; chapters directory is large; events exist but are currently block-based; forms exist (prayer/chaplain request).
- **Meeting direction (Adam/Mike/Anthony)**: a **custom, resource-focused homepage**; core actions: **Prayer Requests, Resources, Connect, Donate/Give**; English-only in v1; keep scope simple.
- **Constraint**: the Astro prototype may support offline, but **v1 should not ship offline** (keep simple).

Scoring key:
- **5 = excellent**, **3 = solid**, **1 = weak**
- Additional factors include: **Apple review risk reduction**, **content dependency**, **implementation complexity**, **scalability**, **maintainability**, **analytics/retention leverage**

---

## 5 homepage ideas (v1)

### 1) Action Hub + Quick Tasks (recommended)
**What it is:** A “home dashboard” that prioritizes the top 4 actions as large, tappable cards:
- Prayer Request (in-app form)
- Chaplain Request (in-app form)
- Resources (in-app; PDFs + links)
- Donate/Give (opens external browser)

Then add 2–3 secondary sections:
- “Find a Chapter” (chapters list/search)
- “Upcoming Events” (next 1–3; even if initially pulled from a simple page/list)
- “Featured Resource” (one highlighted PDF/link/topic)

**Why it fits FFCI:** It mirrors the meeting’s resource-first direction and matches what’s actually on the site (forms + resources + chapters).

---

### 2) “Start Here” Pathways (new vs. returning)
**What it is:** A segmented home with two primary pathways:
- **New here**: “What is FFCI?”, “Do you know God?”, “Find a Chapter”
- **I’m already connected**: “Resources”, “Prayer”, “Chaplain Request”, “Events”

**Why it fits FFCI:** The website has outreach/intro content and many pages; this prevents users from getting lost.

---

### 3) Chapters-first Home (location + find a chapter)
**What it is:** Home is centered on **Chapters**:
- Search/filter chapters (state/province/country; quick list)
- “Featured Chapter”
- “Start a Chapter” / “Connect”
- Secondary strip of the top actions (Prayer/Resources/Donate)

**Why it fits FFCI:** “Find a chapter” is a recurring CTA and chapters are a core real-world action for users.

---

### 4) Resources Library Home (curated categories)
**What it is:** Home is a curated “library front door” for text/PDF resources:
- 6–10 resource categories/cards (e.g., “Stress & Recovery”, “Chaplain Tools”, “Family”, “Disaster Relief”, “New Believer”, “Leadership”)
- “Recently opened” (device-local list, not offline)
- “Share a resource” affordance (copy link/share sheet later; v1 can just link)

**Why it fits FFCI:** There are many PDFs and external links; this provides a clean, app-like discovery layer without requiring media.

---

### 5) Minimal “Feed” Home (updates + pinned actions)
**What it is:** A simple feed-like home:
- Top pinned actions row: Prayer / Chaplain / Resources / Donate
- Below: latest updates in cards (e.g., recent articles, announcements, featured event)
- A persistent search field for pages/resources

**Why it fits FFCI:** If they start publishing regular updates/articles, this feels “alive” and encourages return visits.

---

## Evaluation scorecard

| Idea | Reusability (multi-site) | App-like feel | Real value | Apple-risk reduction | Complexity | Content dependency |
|---|---:|---:|---:|---:|---:|---|
| 1) Action Hub + Quick Tasks | 5 | 5 | 5 | 5 | 3 | Low |
| 2) Start Here Pathways | 5 | 4 | 4 | 4 | 3 | Low |
| 3) Chapters-first | 4 | 4 | 4 | 4 | 3 | Medium (chapters data quality) |
| 4) Resources Library | 5 | 4 | 5 | 4 | 4 | Medium (taxonomy/curation) |
| 5) Minimal Feed | 4 | 5 | 3–5 | 4 | 4 | High (needs consistent updates) |

Notes on the columns:
- **Apple-risk reduction**: Higher when the homepage provides clear app-specific utility (task hub, structured navigation) vs. mirroring a website.
- **Complexity**: Higher if it requires additional data modeling (resource taxonomy, feed generation, personalization).
- **Content dependency**: Higher if the experience relies on regular new content or structured data that isn’t currently consistent.

---

## Recommendation for v1 (given “keep it simple”, text-first, no offline)

### Best choice: **Idea 1 — Action Hub + Quick Tasks**
Why it’s best for v1:
- Matches the meeting’s explicitly stated “resource-focused homepage” direction.
- Works great with today’s site reality: **forms + chapters + resources + events** (even if events start simple).
- Maximizes “app-like feel” without needing offline, media, or complex personalization.
- Strong “Apple-friendly” posture: it’s clearly an app surface, not a web view.

### Optional “v1.1” upgrades (still simple, no offline)
- Add **device-local “Recently viewed”** (history of pages/resources opened).
- Add **Saved** items (bookmark any page/resource) to increase retention without server-side accounts.
- Add **Events structure** once the Events Calendar plugin exists (better data source, consistent listing).

