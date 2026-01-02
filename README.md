# MIP Mobile App - FFCI

React Native mobile app for FFCI (Firefighters for Christ International) built with Expo, pulling content from the Kirby CMS website via KQL API.

## Cursor Rule
- Commit as you work, but only in the correct project: `astro-prototype/` for the Astro PWA, `plugins/` for the Kirby plugin, `sites/` for the Kirby site. Check the folder path before staging so changes land in the right repo.
- Always verify changes by running the relevant Cypress specs, and run the full Cypress suite (`npx cypress run`) and ensure it passes before marking a task complete.

## Project Overview

This project builds a reusable mobile app template that displays content from Kirby CMS websites (MIP platform) via REST API. The app will be deployed to both iOS and Android app stores.

**Client**: FFCI (ws-ffci)  
**Timeline**: Target launch late February / early March 2025  
**Urgency**: FFCI's current SubSplash app expires January 15, 2025

## Current App Reference

The existing FFCI app is built on the SubSplash platform:
- **iOS App Store**: https://apps.apple.com/us/app/firefighters-for-christ/id1461816552
- **Platform**: SubSplash (version 6.3.1 as of September 2023)
- **Developer**: FIREFIGHTERS FOR CHRIST INTERNATIONAL

## Quick Links

- **[Mobile App Specification](docs/mobile-app-specification.md)** - Complete technical specification
- **[FFCI Strategy Meeting](meetings/ffci-mobile-app-strategy.md)** - December 8, 2025 planning meeting
- **[Local Development Guide](docs/guide-to-running-locally.md)** - How to run the FFCI site locally
- **[KQL/Headless Reference](docs/kirby-headless-cef.md)** - Example of KQL API setup
- **[Scope Additions](docs/scope-additions.md)** - Additional scope beyond original job posting

## Project Structure

```
mip-mobile-app/
├── docs/                    # Documentation
│   ├── mobile-app-specification.md
│   ├── guide-to-running-locally.md
│   ├── kirby-headless-cef.md
│   └── scope-additions.md
├── meetings/                # Meeting notes
│   └── ffci-mobile-app-strategy.md
├── sites/
│   └── ws-ffci/             # FFCI Kirby CMS site (content source)
└── plugins/
    └── wsp-mobile/          # Mobile API plugin (needs to be installed)
```

## Technical Stack

- **Framework**: React Native with Expo (managed workflow)
- **Navigation**: Expo Router
- **Deployment**: Expo EAS Build + EAS Submit + EAS Update (OTA)
- **Testing**: Maestro UI testing
- **Backend**: Kirby CMS with KQL API
- **Analytics**: Firebase Analytics

## Local Development Setup

### Prerequisites

- Docker and DDEV installed
- Bitbucket SSH access (for Composer dependencies)
- Node.js & npm
- Expo CLI

### Setting Up the FFCI Site Locally

The FFCI site (`sites/ws-ffci/`) needs to be running locally so you can:

1. Test KQL API queries
2. See the content structure
3. Configure mobile settings in the Panel

**Steps:**

1. Navigate to the FFCI site:
   ```bash
   cd sites/ws-ffci
   ```

2. Configure DDEV:
   ```bash
   ddev config --docroot www --omit-containers db
   ```

3. Authenticate with Bitbucket (required for Composer):
   ```bash
   ddev auth ssh
   ```

4. Install dependencies:
   ```bash
   ddev composer install
   ddev npm install
   ddev composer update
   ddev exec gulp
   ```

5. Start the site:
   ```bash
   ddev start
   ddev list  # Click the URL to open the site
   ```

See [guide-to-running-locally.md](docs/guide-to-running-locally.md) for troubleshooting.

### Installing the Mobile Plugin

The `wsp-mobile` plugin provides the mobile API endpoints (`/mobile-api/*`) and Panel configuration. It needs to be installed on the FFCI site.

**Option 1: Symlink (for development)**
```bash
cd sites/ws-ffci
ln -s ../../plugins/wsp-mobile site/plugins/wsp-mobile
```

**Option 2: Add to composer.json (production)**
Add to `sites/ws-ffci/composer.json`:
```json
{
  "require": {
    "fiveq/wsp-mobile": "dev-master"
  },
  "repositories": [
    {
      "type": "vcs",
      "url": "git@bitbucket.org:fiveqwasap/wsp-mobile.git"
    }
  ]
}
```

Then run `ddev composer update`.

### Accessing the Mobile API

Once the plugin is installed and the site is running:

- **KQL Endpoint**: `POST /mobile-api/kql` (or `GET /mobile-api/kql?q=<base64-encoded-query>`)
- **Menu API**: `GET /mobile-api/menu`
- **Page API**: `GET /mobile-api/page/<uuid>`
- **Site Data**: `GET /mobile-api`

See [kirby-headless-cef.md](docs/kirby-headless-cef.md) for KQL query examples.

### Configuring Mobile Settings

1. Log into the Kirby Panel at `/panel`
2. Go to Site Settings → Mobile tab
3. Configure:
   - App Name
   - Mobile Logo
   - Homepage Type (content/collection/navigation)
   - Mobile Main Menu structure

## Key Requirements

### Phase 1: Core App (Current Scope)

- Pull content from FFCI website via KQL API
- Display brochure pages (About Us, etc.)
- Basic contact forms
- Video/audio collections (if available on site)
- Native navigation (tabs/drawer from CMS menu)

### Phase 2: Custom Features (Future)

- Bible integration
- In-app notes
- Additional custom features from current SubSplash app

**Note**: Phase 1 focuses on website-based content only. Custom features will be addressed separately.

## API Authentication

The mobile app uses **Bearer Token authentication** for KQL API access. The token will be provided by Five Q and should be stored securely in app configuration.

See the [mobile-app-specification.md](docs/mobile-app-specification.md) for detailed API integration requirements.

## Contact & Timeline

- **Project Manager**: Mike Kaczorowski
- **Technical Lead**: Anthony Elliott
- **Target Launch**: Late February / Early March 2025
- **Urgent Deadline**: FFCI's SubSplash app expires January 15, 2025

## Next Steps

1. Review [mobile-app-specification.md](docs/mobile-app-specification.md) for complete requirements
2. Set up local FFCI site using DDEV
3. Install and configure `wsp-mobile` plugin
4. Test KQL queries against local site
5. Begin React Native app development
