# Tickets

Quick reference for active tasks. See individual files for details.

> **Note:** This README is auto-generated from ticket files. To regenerate it, run:
> ```bash
> node tickets/generate-readme.js
> ```

## In Progress
- [048](048-content-page-images-not-rendering.md) - Content Page Images Not Rendering

## Backlog

### 🔴 Core Functionality (FFCI)
- [017](017-prayer-request-form-handling.md) - Prayer Request Form Handling
- [018](018-chaplain-request-form-handling.md) - Chaplain Request Form Handling
- [037](037-error-offline-screen.md) - Error/Offline Screen Design

### 🟡 Nice to Have
- [019](019-form-detection-api-flag.md) - Form Detection API Flag
- [020](020-webview-form-pages.md) - WebView Full-Page Fallback for Form Pages
- [026](026-collection-pull-to-refresh.md) - Collection Pull-to-Refresh
- [027](027-collection-pagination.md) - Collection Pagination
- [038](038-cache-last-data.md) - Cache Last Successful Data for Offline Access
- [044](044-refresh-indicator-overlay.md) - Add Refresh Indicator During Background Refresh
- [045](045-android-back-button-tab-history.md) - Android Back Button Tab Navigation History

### 🟣 C4I Phase
- [021](021-native-video-player.md) - Native Video Player Component
- [022](022-youtube-vimeo-embed.md) - YouTube/Vimeo Embed Support
- [023](023-audio-player-component.md) - Audio Player Component
- [024](024-collection-item-metadata.md) - Display Video/Audio Metadata on Collection Items
- [025](025-collection-cover-images.md) - Collection Grid Cover Images
- [030](030-firebase-media-events.md) - Firebase Media Events (video_play, video_complete, audio_play)
- [034](034-maestro-video-test.md) - Maestro Test: Video Playback
- [035](035-maestro-audio-test.md) - Maestro Test: Audio Playback
- [039](039-c4i-site-config.md) - Create C4I Site Configuration

### 🟢 Production Ready
- [028](028-firebase-setup.md) - Firebase Analytics Setup
- [029](029-firebase-navigation-events.md) - Firebase Navigation Events (app_open, screen_view, content_view)
- [031](031-firebase-external-link-event.md) - Firebase External Link Event
- [040](040-eas-build-profiles.md) - Set Up EAS Build Profiles for Multiple Sites
- [041](041-new-site-guide.md) - Document "Adding a New Site" Step-by-Step Guide
- [042](042-remove-dev-tools.md) - Remove Dev Tools Section Before Production

### 📋 Testing
- [033](033-maestro-collection-test.md) - Maestro Test: Collection Grid and Navigation
- [036](036-maestro-error-handling-test.md) - Maestro Test: Error Handling

### Unassigned
- [049](049-ticket-generator-qa-status.md) - Ticket Generator Does Not Recognize "qa" Status

## Blocked
- [003](003-deploy-to-real-device-eas.md) - Deploy to Real device (EAS)
- [005](005-link-apple-account-eas.md) - Link Apple Account with EAS
- [015](015-ios-browserstack-without-apple-dev-account.md) - Build and Upload iOS to BrowserStack Without Apple Developer Account

## Maybe
- [013](013-speed-up-eas-android-builds.md) - Speed Up EAS Android Build Time

## Done
- [001](done/001-api-key-auth.md) - Update RN app to use X-API-Key authentication
- [002](002-enable-api-on-ffci-site.md) - Enable API on the real FFCI site
- [004](004-resources-page-loading-delay.md) - Resources page loading delay
- [006](006-add-expo-to-gitignore.md) - Add .expo directory to .gitignore
- [007](007-install-expo-constants-peer-dependency.md) - Install missing peer dependency: expo-constants
- [008](008-resolve-native-config-sync-issues.md) - Resolve native config sync issues (app.json vs native folders)
- [009](009-update-package-versions-expo-sdk.md) - Update package versions to match Expo SDK requirements
- [010](010-integrate-browserstack-api.md) - Integrate BrowserStack App Live API
- [010](done/010-integrate-browserstack-api.md) - Integrate BrowserStack App Live API
- [011](011-android-baseline-ux.md) - Android Baseline UX Issues
- [012](012-eas-build-webhook.md) - EAS Build Completion Webhook
- [014](014-setup-expo-mcp-server.md) - Set Up Expo MCP Server Locally
- [016](016-reliable-android-emulator-local.md) - Prove Android Emulator Reliability with Maestro Testing
- [032](done/032-maestro-content-page-test.md) - Maestro Test: Content Page Rendering
- [043](043-svg-logo-support.md) - Fix SVG Logo Support
- [046](046-reliable-maestro-tests-android.md) - Reliable Maestro Tests for Android

---

## Status Values
- `backlog` - Not started yet
- `in-progress` - Currently working on this
- `blocked` - Waiting on something else
- `maybe` - Low priority, revisit later
- `done` - Completed (move to `done/` folder)

## Phases (for backlog prioritization)
- `core` - Core functionality, fix first
- `nice-to-have` - Polish, not blocking launch
- `c4i` - C4I-specific, after FFCI launch
- `production` - Final tasks before App Store submission
- `testing` - Ongoing test coverage

## Areas
- `rn-mip-app` - React Native mobile app
- `wsp-mobile` - Kirby plugin for mobile API
- `ws-ffci-copy` - Kirby site configuration
- `astro-prototype` - Astro PWA prototype
- `general` - Cross-cutting or repo-level tasks

