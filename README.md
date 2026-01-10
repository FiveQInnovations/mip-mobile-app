# MIP Mobile App - FFCI

React Native mobile app for FFCI (Firefighters for Christ International) built with Expo, pulling content from the Kirby CMS website via KQL API.

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
- **[Deployment Quick Guide](docs/deployment-quick-guide.md)** - Workflow for adding features and deploying to BrowserStack
- **[Expo MCP Server Setup](tickets/014-setup-expo-mcp-server.md)** - Guide for setting up Expo MCP Server with Cursor
- **[FFCI Strategy Meeting](meetings/ffci-mobile-app-strategy.md)** - December 8, 2025 planning meeting
- **[Local Development Guide](docs/guide-to-running-locally.md)** - How to run the FFCI site locally
- **[KQL/Headless Reference](docs/kirby-headless-cef.md)** - Example of KQL API setup
- **[Scope Additions](docs/scope-additions.md)** - Additional scope beyond original job posting

## Project Structure

```
mip-mobile-app/
├── rn-mip-app/              # React Native mobile app (main project)
│   ├── app/                 # Expo Router app directory
│   ├── components/          # React components
│   ├── lib/                 # API and utilities
│   ├── maestro/             # Maestro UI tests
│   └── scripts/             # Deployment scripts
├── astro-prototype/         # Astro PWA prototype (separate project)
├── docs/                    # Documentation
│   ├── mobile-app-specification.md
│   ├── deployment-quick-guide.md
│   ├── guide-to-running-locally.md
│   └── ...
├── meetings/                 # Meeting notes
├── tickets/                  # Development tickets
```

## Technical Stack

- **Framework**: React Native with Expo (managed workflow)
- **Navigation**: Expo Router
- **Deployment**: Expo EAS Build + EAS Submit + EAS Update (OTA)
- **Testing**: Maestro UI testing
- **Backend**: Kirby CMS with KQL API
- **Analytics**: Firebase Analytics

## Continuous Native Generation (CNG)

This project uses **Continuous Native Generation (CNG)**, which means the native iOS and Android projects are generated on-demand from configuration files rather than being manually maintained.

### What is CNG?

CNG is a process where native projects (`ios/` and `android/` directories) are automatically generated from:
- Your `app.json`/`app.config.js` configuration
- Your `package.json` dependencies
- Config plugins (for custom native modifications)
- Expo's prebuild template

When you run `npx expo run:ios`, `npx expo run:android`, or build with EAS, Expo automatically runs `npx expo prebuild` to generate fresh native projects.

### Important: Do Not Modify Native Folders

⚠️ **Do not manually edit files in the `ios/` or `android/` directories.** These folders are generated artifacts (similar to `node_modules`) and will be overwritten the next time prebuild runs.

- ✅ **Do**: Modify `app.json`/`app.config.js` for configuration changes
- ✅ **Do**: Use config plugins for native customizations
- ✅ **Do**: Use Expo Modules API for custom native code
- ❌ **Don't**: Edit files directly in `ios/` or `android/` folders

### Benefits of CNG

- **Easier upgrades**: Upgrade React Native/Expo SDK by updating dependencies and running `npx expo prebuild --clean`
- **Less code to maintain**: Only commit what's unique to your app, not boilerplate
- **Automatic native module linking**: Expo handles linking via autolinking
- **Cleaner git history**: Native folders are in `.gitignore` (like `node_modules`)

For more information, see the [Expo CNG documentation](https://docs.expo.dev/workflow/continuous-native-generation/).

## Local Development Setup

### Prerequisites

- **Node.js 20.18.0** (managed via `mise`)
- **EAS CLI**: `npm install -g eas-cli`
- Docker and DDEV (for Kirby CMS site)
- Bitbucket SSH access (for Composer dependencies)
- iOS Simulator (for mobile app testing)

### Setting Up the FFCI Site Locally

The FFCI site (`ws-ffci/`) needs to be running locally so you can:

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

### Running the Mobile App Locally

1. Navigate to the React Native app:
   ```bash
   cd rn-mip-app
   ```

2. Install dependencies:
   ```bash
   npm install --legacy-peer-deps
   ```

3. Start Metro bundler with iOS Simulator:
   ```bash
   mise exec -- bash -c "export LANG=en_US.UTF-8 && npx expo start --ios --clear"
   ```

4. Run Maestro tests:
   ```bash
   npm run test:maestro:ios
   ```

See [deployment-quick-guide.md](docs/deployment-quick-guide.md) for the complete development workflow.

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


### Deploying API changes
- Commit changes on a feature branch in wsp-mobile.
- When ready, merge into master locally
- Push changes to origin master
- Server should auto-update about every 10 minutes
- You can manually trigger an update with: `curl "https://api.fiveq.dev/api/proxy/ffci/composer-update?api_key=$MIP_API_TOKEN"`

### Configuring Mobile Settings

1. Log into the Kirby Panel at `/panel`
2. Go to Site Settings → Mobile tab
3. Configure:
   - App Name
   - Mobile Logo
   - Homepage Type (content/collection/navigation)
   - Mobile Main Menu structure

## Adding Features & Deployment

When adding new features or making changes to the mobile app, follow the **[Deployment Quick Guide](docs/deployment-quick-guide.md)** for the complete workflow:

1. Make code changes
2. Test locally on iOS Simulator
3. Run Maestro tests
4. Build Android preview APK with EAS
5. Upload to BrowserStack for testing
6. Commit changes

**Important for Cursor AI:** When asking Cursor to follow the deployment guide, explicitly request a plan first:
```
Create a Plan to follow the guide: @docs/deployment-quick-guide.md
```

This ensures the agent tests locally before building, which saves time and build minutes. Without explicitly creating a plan, the agent may skip local testing and jump straight to EAS builds.

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

See [tickets/TICKETS.md](tickets/TICKETS.md) for active development tickets and progress tracking.
