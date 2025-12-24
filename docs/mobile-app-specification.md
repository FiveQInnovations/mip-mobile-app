# MIP Mobile App Specification

## Project Overview

Build a reusable mobile app template that displays content from Kirby CMS websites (MIP platform) via REST API. The app will be deployed to both iOS and Android app stores, with a streamlined deployment pipeline for future updates.

**Initial Clients**: FFCI (ws-ffci-copy) and C4I (ws-c4i)

---

## Technical Requirements

### Platform & Framework

| Requirement | Specification |
|-------------|---------------|
| Platforms | iOS and Android |
| Framework | React Native with Expo (managed workflow) |
| Navigation | Expo Router |
| Deployment | Expo EAS Build + EAS Submit |
| Testing | Maestro UI testing |
| App Store Accounts | Five Q's accounts (credentials provided) |
| Analytics | Firebase Analytics (required) |
| Minimum OS Versions | Follow Expo defaults (iOS 13.4+, Android 6.0+) |

### Preferred Libraries (Nice-to-Have)

These are not required but preferred if the contractor has experience:

- **UI Components**: Gluestack UI
- **Styling**: NativeWind (Tailwind for React Native)
- **State Management**: React Query + Zustand
- **AI Tools**: Proficiency with AI coding assistants (Cursor, Copilot, etc.)

### Expo & Deployment Pipeline

The contractor must:

1. **Use Expo managed workflow** for simplified builds and updates
2. **Configure EAS Build** for iOS and Android production builds
3. **Configure EAS Submit** for automated app store submission
4. **Enable EAS Update** (OTA updates) for non-native code changes
5. **Document the deployment process** so a future developer can:
   - Push a code update
   - Trigger a new build
   - Submit to app stores
   - Push an OTA update for minor fixes

### Automated Testing with Maestro

The contractor must set up basic automated UI testing using [Maestro](https://maestro.mobile.dev/):

**Why Maestro**:
- Simple YAML-based test flows
- Works well with Expo/React Native
- Can run locally and in CI
- No flaky selectors — uses accessibility labels and text matching

**Required Test Coverage**:

| Flow | What to Test |
|------|--------------|
| App Launch | Splash screen appears, initial data loads, home screen displays |
| Navigation | Each menu item navigates to correct screen |
| Content Page | Page loads, HTML content renders in WebView |
| Collection | Collection grid displays, items are tappable |
| Video Playback | Video item opens, player appears, playback starts |
| Audio Playback | Audio item opens, player controls appear |
| Error Handling | Graceful error screen when API unavailable |

**Test Structure**:
```
tests/
├── flows/
│   ├── app-launch.yaml
│   ├── navigation.yaml
│   ├── content-page.yaml
│   ├── collection.yaml
│   ├── video-playback.yaml
│   ├── audio-playback.yaml
│   └── error-handling.yaml
└── config.yaml
```

**Example Flow** (`app-launch.yaml`):
```yaml
appId: com.fiveq.ffci
---
- launchApp
- assertVisible: "Loading..."
- waitForAnimationToEnd
- assertVisible: "Home"  # or site-specific home indicator
- takeScreenshot: app-launch
```

**Deliverables**:
- Maestro test flows for all required scenarios
- Documentation on running tests locally
- Instructions for adding new test flows

---

## App Architecture

### Configuration System

Each site deployment uses a configuration file. No code changes required per site.

```json
{
  "siteId": "ffci",
  "apiBaseUrl": "https://ffci.org",
  "apiToken": "<BEARER_TOKEN_FROM_FIVE_Q>",
  "appName": "FFCI",
  "appSlug": "ffci-app",
  "primaryColor": "#1a56db",
  "secondaryColor": "#ffffff",
  "iosBundle": "com.fiveq.ffci",
  "androidPackage": "com.fiveq.ffci",
  "firebaseConfig": {
    "ios": "GoogleService-Info.plist path or config",
    "android": "google-services.json path or config"
  }
}
```

**Note**: The `apiToken` is a static bearer token for API access. It will be provided by Five Q for each site. The token should be stored securely and not committed to public repositories.

### Multi-Site Build Strategy

**Required approach: Config at build time**

- Single codebase with site-specific config files
- Build script injects config for target site
- Each site = separate EAS build profile
- Produces separate app binaries per site (required for separate App Store listings)

```
configs/
├── ffci.json      # FFCI site config
├── c4i.json       # C4I site config
└── template.json  # Template for new sites
```

Build command specifies target site:
```bash
eas build --profile ffci --platform all
```

### Reusability Requirement: New Site Deployment

A key goal of this project is **easy replication for future MIP sites**. After the initial build, Five Q should be able to launch a new mobile app for any MIP site **without additional coding**.

**What should be reused (no changes needed):**
- React Native codebase
- All components, screens, navigation
- Maestro test flows
- EAS configuration

**What changes per new site (config only):**

| Item | Description | Time |
|------|-------------|------|
| Config file | New `config.<site>.json` with API URL, token, bundle IDs | 15 min |
| Firebase project | New iOS/Android apps in Firebase | 30 min |
| App icons/splash | Generate from client logo | 15 min |
| EAS build profile | Add profile to `eas.json` | 10 min |
| Store listing | App name, description, screenshots | 30 min |

**Deployment commands for new site:**
```bash
# Build for new site
eas build --profile newsite --platform all

# Submit to app stores
eas submit --profile newsite --platform all
```

**Expected process for new site:**

| Step | Duration | Owner |
|------|----------|-------|
| Create config + assets | 1-2 hours | Five Q dev |
| Build via EAS | 30-60 min | Automated |
| App store review | 1-7 days | Apple/Google |
| **Total active work** | **~2-4 hours** | |

**Contractor deliverable**: Documentation and tooling that enables this process. Include a step-by-step guide for "Adding a New Site" in the README.

---

## Screens & Navigation

### 1. Splash Screen
- Display site logo (from config or API)
- Fetch initial data via KQL (menu, branding, homepage config)
- Handle offline/error gracefully

### 2. Home Screen
- Configurable via `mobileHomepageType` from API:
  - **"content"**: Render a content page
  - **"collection"**: Show collection grid (e.g., video series)
  - **"navigation"**: Button list linking to menu items

### 3. Navigation
- **Bottom tab bar** or **drawer menu** driven by KQL menu query response
- Each menu item links to a page by UUID
- Icons from menu configuration (or sensible defaults)
- **Page inclusion/exclusion**: The mobile menu is configured separately in the CMS Panel (via `mobileMainMenu` field), allowing site admins to include only relevant pages in the app navigation. Not all website pages need to appear in the app.

### 4. Content Page
- Fetch page data via KQL query using page UUID
- Render `page_content` HTML in WebView with injected mobile-friendly CSS
- Support for:
  - Internal links (navigate within app)
  - External links (open in browser)
  - Responsive scaling

### Content Rendering Strategy & App Store Compliance

**Apple Guideline 4.2** states:

> "Your app should include features, content, and UI that elevate it beyond a repackaged website. If your app is not particularly useful, unique, or 'app-like,' it doesn't belong on the App Store."
>
> — [Apple App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

**This app is NOT a website wrapper** and should pass review because:

| Component | Implementation | Why It's "App-Like" |
|-----------|---------------|---------------------|
| Navigation | Native (tabs/drawer) | Platform-standard UI patterns |
| Collection grids | Native components | Custom layout, pull-to-refresh |
| Video player | Native (react-native-video) | Not a web embed |
| Audio player | Native controls | Platform-appropriate UI |
| Splash screen | Native | Branded launch experience |
| Analytics | Native (Firebase) | Device-level integration |
| **Rich text content only** | WebView | Standard pattern for formatted text |

WebView is used **only** for rendering formatted HTML content from the page builder — not for the entire app experience. This is an accepted pattern used by news apps, documentation apps, and content platforms.

### Forms Handling

MIP sites include dynamic forms (e.g., "Become a Member") built with Vue.js. These forms require JavaScript to render and submit. Two approaches for handling forms in the app:

| Option | Approach | Trade-off |
|--------|----------|-----------|
| **A. Full page WebView** | Detect pages with forms via KQL; load the actual website URL instead of just HTML content | Forms work seamlessly, but those pages feel more "webby" |
| **B. Link out** | Show page content normally; when form is present, prompt user to open in Safari/Chrome | Clear separation, but disruptive UX |

Contractor may choose the approach that best fits the overall UX. If Option A, the KQL query should include a flag indicating form presence.

### 5. Collection List
- Grid or list view of collection children
- Display: cover image, title, date/episode number
- Pull-to-refresh
- Pagination if API supports it

### 6. Collection Item (Video/Audio)
- **Video**: Native video player (react-native-video or Expo AV)
  - Support YouTube/Vimeo URLs (via WebView or react-native-youtube-iframe)
  - Support direct video URLs
- **Audio**: Audio player with controls
  - Background playback (nice-to-have for v1)
- Content/description below player (WebView for HTML)

### 7. Error/Offline Screen
- Friendly error message
- Retry button
- Cache last successful data if feasible

---

## API Integration

### Overview

The app uses **Kirby's official KQL (Kirby Query Language) plugin** for all data fetching. KQL provides flexible, GraphQL-like queries over a simple REST endpoint.

- **Documentation**: [github.com/getkirby/kql](https://github.com/getkirby/kql)
- **Endpoint**: `POST /api/query`

### Authentication

The API uses **Bearer Token authentication** to:
- Prevent unauthorized access and casual scraping
- Ensure draft pages are not exposed
- Allow token rotation without code changes

**Request format**:
```javascript
const response = await fetch('https://site.org/api/query', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer <API_TOKEN>',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    query: 'site',
    select: { title: true }
  })
});
```

**Token management**:
- Token is stored in app configuration (per-site)
- Five Q provides token to contractor for each site
- Token can be rotated server-side; app update required for new token

### Security Configuration (Five Q implements)

Each site will have KQL configured with:

```php
// site/config/config.php
return [
    // Using kirby-headless plugin for bearer auth
    'johannschopplich.headless' => [
        'token' => '<SECURE_API_TOKEN>',
    ],
    'kql' => [
        'auth' => 'bearer',
        'classes' => [
            'blocked' => [
                'Kirby\\Cms\\User',
                'Kirby\\Cms\\Users',
            ],
        ],
    ],
];
```

### Example KQL Queries

**App initialization** (menu, branding):
```json
{
  "query": "site",
  "select": {
    "title": "site.title",
    "appName": "site.mobileAppName",
    "logo": "site.mobileLogo.toFile.url",
    "homepageType": "site.mobileHomepageType",
    "menu": {
      "query": "site.mobileMainMenu.toStructure",
      "select": {
        "label": true,
        "uuid": "item.page.toPage.uuid.id",
        "template": "item.page.toPage.intendedTemplate.name",
        "title": "item.page.toPage.title"
      }
    }
  }
}
```

**Page content**:
```json
{
  "query": "page('page://abc123')",
  "select": {
    "title": true,
    "template": "page.intendedTemplate.name",
    "content": "page.page_content.toBlocks.toHtml",
    "cover": "page.cover.toFile.url",
    "children": {
      "query": "page.children.listed",
      "select": {
        "uuid": "page.uuid.id",
        "title": true,
        "cover": "page.cover.toFile.url"
      }
    }
  }
}
```

**Video collection with pagination**:
```json
{
  "query": "page('page://collection-uuid').children.listed",
  "select": {
    "uuid": "page.uuid.id",
    "title": true,
    "episode": "page.episode",
    "series": "page.series",
    "cover": "page.cover.toFile.url",
    "videoUrl": "page.video_url"
  },
  "pagination": {
    "limit": 20,
    "page": 1
  }
}
```

### Draft Page Handling

- Use `.listed` in queries to exclude drafts (e.g., `page.children.listed`)
- Drafts have status "draft" and are excluded from `.listed` collections
- Bearer token auth provides additional protection layer

### API Response Handling

- Handle 401 (unauthorized) — token may be invalid/expired
- Handle 404s gracefully (page not found)
- Cache responses with React Query (recommended)
- Include `User-Agent` header identifying the app

### Backend Setup (Five Q implements before development)

1. **Install plugins**: `getkirby/kql` and `johannschopplich/kirby-headless`
2. **Configure bearer auth**: Set token in site config
3. **Block sensitive classes**: User, form submissions, etc.
4. **Add Panel blueprint**: Mobile settings tab for menu/branding
5. **Test queries**: Verify all required data is accessible

---

## Firebase Analytics

### Required Events

| Event | When |
|-------|------|
| `app_open` | App launched |
| `screen_view` | Each screen navigation |
| `content_view` | Page/item viewed (with page UUID, title, type) |
| `video_play` | Video playback started |
| `video_complete` | Video watched to end |
| `audio_play` | Audio playback started |
| `external_link` | User tapped external link |

### Configuration

- Firebase project per site (or single project with separate apps)
- Contractor sets up Firebase projects and provides config files
- Five Q will own Firebase projects long-term

---

## Design & Theming

### Theme System

App should support theming via configuration:

```json
{
  "theme": {
    "primaryColor": "#1a56db",
    "secondaryColor": "#f3f4f6",
    "textColor": "#111827",
    "backgroundColor": "#ffffff",
    "headerStyle": "light"
  }
}
```

### Design Expectations

- Clean, modern UI following platform conventions
- Consistent with site branding (colors, logo)
- Accessible (minimum AA contrast, touch targets 44pt+)
- Dark mode: Nice-to-have for v1, not required

### Assets

- App icons: Contractor provides template, Five Q supplies per-site artwork
- Splash screens: Generated from logo + background color

---

## Deliverables

### Code & Documentation

1. **Source code** in GitHub repository (Five Q ownership)
2. **README** with:
   - Local development setup
   - How to run Maestro tests locally
   - How to build and deploy
3. **"Adding a New Site" guide** (critical for reusability):
   - Step-by-step checklist for launching a new site's app
   - Config file template with all required fields
   - Firebase setup instructions
   - App icon/splash generation process
   - EAS profile setup
   - Store listing requirements
   - Expected timeline and commands
4. **Deployment documentation**:
   - EAS Build process
   - App store submission steps
   - OTA update process
5. **Testing documentation**:
   - Maestro test structure and conventions
   - How to add new test flows
   - CI test pipeline explanation

### Builds & Submissions

1. **Initial builds** for FFCI and C4I
2. **TestFlight/Internal Testing** deployment for review
3. **Production submission** to both app stores
4. **App store listing** content (contractor drafts, Five Q approves)

---

## Out of Scope (v1)

The following are explicitly NOT included:

- User accounts / authentication
- Push notifications
- Offline mode / content downloading
- In-app purchases or donations
- Search functionality
- Deep linking / universal links
- Background audio playback (nice-to-have, not required)
- Accessibility audit beyond basic compliance
- Localization / multi-language

---

## Appendix A: Site-Specific Notes

### FFCI (ws-ffci)

#### Site Overview
- General content site (about, chapters, resources, get involved)
- Primarily page builder content
- English-only for v1 (no multi-language support)

#### Existing SubSplash App (Google Play)
**Listing**: [Firefighters For Christ on Google Play](https://play.google.com/store/apps/details?id=com.subsplashconsulting.s_F52C3B)

**Details**:
- **Package ID**: `com.subsplashconsulting.s_F52C3B`
- **Developer**: Subsplash Inc
- **Rating**: 5.0 stars (9 reviews)
- **Downloads**: 500+
- **Last Updated**: May 30, 2024
- **Category**: Lifestyle

**Current Features**:
- Watch or listen to past messages
- Push notifications
- Contacts for local Chapter leaders
- Bible reader (included in app)
- Ministry videos of mission trips

**Note**: This app expires January 15, 2025. The new MIP-based app will replace this SubSplash app.

#### Timeline & Phased Delivery
- **Urgent deadline**: Client needs app by late Feb/early Mar 2025 for an event
- **SubSplash expiration**: Current SubSplash app expires Jan 15, 2025
- **Phase 1** (in scope): Core app pulling content from website — meets deadline
- **Phase 2** (future, potentially paid): Custom features like Bible integration

#### Content Migration Prerequisites
- Audio/video collections exist in the current SubSplash app but **not on the website yet**
- These must be downloaded from SubSplash and uploaded to MIP before app development
- Events Calendar plugin must be implemented (site currently uses static content blocks)

#### Homepage Design
- Custom, resource-focused homepage (not just navigation buttons)
- Core quick-action buttons: **Prayer Requests, Resources, Connect, Donate/Give**
- Figma wireframe to be created before contractor engagement

#### Features Explicitly Out of Scope (v1)
These exist in the current SubSplash app but are NOT included in the initial build:
- Bible integration (embedded Bible reader)
- In-app notes (save notes on any page)
- Multi-language/Spanish version

#### Key Forms
- Prayer request form
- Chaplain request form
- Donate (links to external donation page)

### C4I (ws-c4i)

- Video-focused ministry content
- TV show "Israel: The Prophetic Connection" with seasons/episodes
- Audio collection with podcast content
- Homepage likely "collection" type showing latest videos
- Season filtering in collections (already implemented in web)

---

## Appendix B: Firebase Setup Checklist

For each site:

1. [ ] Create Firebase project (or add apps to existing)
2. [ ] Add iOS app with bundle ID
3. [ ] Add Android app with package name
4. [ ] Download config files (GoogleService-Info.plist, google-services.json)
5. [ ] Enable Analytics in Firebase console
6. [ ] Set up any custom event definitions
7. [ ] Add Five Q team members to Firebase project

