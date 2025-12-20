# Homepage concepts evaluation (app-like + Apple-friendly)

Scoring key:
- **5 = excellent**, **3 = solid**, **1 = weak**
- “Other important factors” includes: **Apple review risk**, **implementation complexity**, **performance/offline**, **content scalability**, **analytics/retention leverage**, **accessibility**

---

## Summary scorecard

| Concept | Reusability (multi-site) | App-like feel | Real user value | Apple-risk reduction | Complexity | Notes |
|---|---:|---:|---:|---:|---:|---|
| 1) **“Today” dashboard** | 5 | 5 | 4 | 5 | 4 | Strong “native app hub”; needs user state/persistence to shine |
| 2) **Offline-first Library + downloads** | 5 | 5 | 5 | 5 | 4 | Highest practical value; requires download mgmt + UX polish |
| 3) **Explore w/ filters + saved searches** | 5 | 4 | 4 | 4 | 3 | Highly reusable; best if content is large and taxonomy is consistent |
| 4) **Guided journeys (multi-step flows)** | 3 | 5 | 4 | 5 | 5 | Great retention; harder to generalize across sites without “journey authoring” |
| 5) **Media-first home (queue + player)** | 4 | 5 | 5 (for media sites) | 4 | 4 | Excellent when audio/video is core; less universal for text-first orgs |

---

## Deep evaluation by concept

## 1) “Today” dashboard (personalized, stateful)
- **Reusability**: **Excellent**. Works for almost any org: “Continue”, “Saved”, “Downloads”, “Recently viewed”, “New this week”.
- **App-like feel**: **Very high**. Feels like a native hub, not a website landing page.
- **Real value**: **High**, especially for repeat visitors. Value depends on having *some* personalization (even device-local).
- **Apple-risk reduction**: **Very high** because it’s clearly not a thin wrapper—there’s persistent state and a home “surface” designed for ongoing use.
- **Other factors**
  - **Complexity**: Moderate—needs local persistence (and optionally login sync).
  - **Works without login**: Yes (device-local “history/saved”).
  - **Scales with content**: Great; the home becomes a personalized lens.

## 2) Offline-first Library + smart downloads
- **Reusability**: **Excellent**. Offline and “saved” patterns apply universally.
- **App-like feel**: **Very high**. Offline mode, downloads, storage controls are strongly “native”.
- **Real value**: **Highest** (when users are mobile, traveling, spotty signal, or want quick access).
- **Apple-risk reduction**: **Very high**. Offline, storage management, background tasks, “download on Wi‑Fi only” are strong differentiators.
- **Other factors**
  - **Complexity**: Moderate-high. Needs clear UX for download states, failures, and storage limits.
  - **Performance**: Excellent perceived speed once cached.
  - **Policy/ethics**: Must be transparent about storage usage and provide delete controls.

## 3) Explore with native filters + saved searches
- **Reusability**: **Excellent**. Taxonomy browsing is portable across many sites.
- **App-like feel**: **High** (especially with fast, responsive filtering and saved searches).
- **Real value**: **High** for large catalogs; medium for small sites.
- **Apple-risk reduction**: **High**. Saved searches/alerts + native navigation makes it more “app product” than website wrapper.
- **Other factors**
  - **Complexity**: Moderate. Requires consistent tagging/categories in the API.
  - **Retention**: Strong if you add “follow tag/author/topic” + notifications (optional).
  - **Accessibility**: Filters must be keyboard/screen-reader friendly.

## 4) Guided journeys (multi-step flows)
- **Reusability**: **Medium** unless you build a generic “journey builder” (admin-authored steps, checkpoints, and content mapping).
- **App-like feel**: **Very high**. Progression + streaks + reminders screams “app”.
- **Real value**: **High** when users want structure (training, devotionals, onboarding, learning paths).
- **Apple-risk reduction**: **Very high**. A guided experience is clearly more than mirroring a site.
- **Other factors**
  - **Complexity**: Highest. Needs content modeling, progress tracking, edge cases, and good UX.
  - **Risk**: If poorly authored or too “gamified,” it can feel forced.

## 5) Media-first home (queue + persistent player)
- **Reusability**: **High** for media-heavy orgs; **medium** otherwise.
- **App-like feel**: **Very high** with queue, mini-player, background controls.
- **Real value**: **Highest** when audio/video is core.
- **Apple-risk reduction**: **High** (sometimes very high) because native media behaviors differentiate strongly.
- **Other factors**
  - **Complexity**: Moderate-high. Queue, resume position, playback state.
  - **Performance**: Must be smooth; media UX issues are very noticeable.

---

## Recommendation (best “overall” for reuse + Apple safety)

**Best overall: (2) Offline-first Library + smart downloads**, with a light layer of **(1) Today dashboard** on top.

- **Why**: Offline/downloads are universally valuable on mobile, highly reusable across future sites, and strongly demonstrate “native value” that helps reduce Apple rejection risk.
- **Practical pairing**: Home = “Today” (Continue/Saved/Downloaded/New), second tab = “Library” (downloads + saved collections), third tab = “Explore”.

---

## Key Apple-friendly principles (applies to any option)
- **Persistent user state** (saved, continue, downloads, preferences) even without login
- **Offline capability** and/or device integration (storage, media controls)
- **Navigation that feels native** (tabbed structure, consistent header behavior)
- **Fast perceived performance** (skeleton loading, caching, instant back)
- **Meaningful features not present on the website** (or at least not trivially replicated)

