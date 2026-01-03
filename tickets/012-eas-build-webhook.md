---
status: done
area: rn-mip-app
created: 2026-01-21
completed: 2026-01-02
---

# EAS Build Completion Webhook

## Context
Set up a webhook to receive notifications when EAS builds complete. This enables automated workflows for downloading build artifacts and uploading them to BrowserStack for testing. 

**Reference:** https://docs.expo.dev/eas/webhooks/

## Tasks
- [x] Create webhook endpoint server (Express.js) to receive EAS webhook POST requests
- [x] Implement signature verification using HMAC-SHA1 to validate webhook authenticity
- [x] Set up local webhook server with ngrok or similar tunnel for testing
- [x] Configure EAS webhook using `eas webhook:create` command
- [x] Test webhook receives build completion events (success, error, canceled)
- [x] Verify webhook signature validation works correctly
- [x] Document webhook setup and configuration
- [x] Implement automatic download and upload to BrowserStack on build completion
- [x] Update deployment workflow documentation to include automated webhook workflow

## Notes

### Implementation Complete

Created webhook server at `scripts/eas-webhook-server.js` with:
- Express.js server listening on `/webhook` endpoint
- HMAC-SHA1 signature verification using `expo-signature` header
- Support for `build.completed` and `build.started` events
- Detailed logging of webhook events and build status
- Health check endpoint at `/health`

### Dependencies Added
- `express` - Web server framework
- `body-parser` - Raw body parsing for signature verification
- `safe-compare` - Constant-time string comparison to prevent timing attacks

### Environment Setup
- Webhook server now loads `WEBHOOK_SECRET` from `.env` file automatically
- Added `WEBHOOK_SECRET` placeholder to `.env.example` for reference
- Users should generate their own secret: `node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"`
- Server uses `dotenv` to load environment variables

### BrowserStack Integration ✅

The webhook server automatically:
1. Downloads Android build artifacts when builds complete successfully
2. Uploads APK files to BrowserStack App Live
3. Uses build ID as custom ID for tracking in BrowserStack

**Requirements:**
- `BROWSERSTACK_USERNAME` and `BROWSERSTACK_ACCESS_KEY` must be set in `.env` file
- Only Android builds are processed (iOS support can be added later)
- Build must have status `finished` to trigger download/upload

**Process Flow:**
1. EAS sends `build.completed` webhook when build finishes
2. Webhook server verifies signature
3. If Android build with status `finished`:
   - Downloads APK from EAS (uses `artifacts.buildUrl` if available, otherwise `eas build:download`)
   - Uploads APK to BrowserStack with custom ID `eas-build-{buildId}`
   - Logs success/failure

### Documentation Updates ✅

- Updated `docs/deployment-workflow.md` with automated webhook workflow option
- Updated `docs/deployment-quick-guide.md` to include webhook workflow
- Created `docs/eas-webhook-setup.md` - Complete setup guide
- Created `docs/eas-webhook-running-guide.md` - Quick reference for running server

### File Logging ✅

Added file logging functionality to webhook server:
- Logs directory: `logs/eas-webhook-YYYY-MM-DD.log` (one file per day)
- Logs all webhook events, build processing, downloads, and BrowserStack uploads
- JSON format with timestamps for easy parsing
- Created automation script `scripts/test-webhook-automated.sh` for end-to-end testing

### Local Testing Limitations ⚠️

**Note:** While the webhook implementation is complete and functional, local testing has reliability issues:
- Localtunnel connections are unstable and frequently disconnect
- Tunnel URLs change on each restart, requiring webhook reconfiguration
- Long-running builds (10-20 minutes) make it difficult to keep tunnels active
- Manual deployment workflow (`scripts/deploy-to-browserstack.sh`) is more reliable for local use

**Recommendation:** Webhook automation works best in production/CI environments with stable URLs. For local development, use the manual deployment script.

## Documentation

- **[EAS Webhook Setup Guide](./rn-mip-app/docs/eas-webhook-setup.md)** - Complete setup and configuration instructions
- **[EAS Webhook Running Guide](./rn-mip-app/docs/eas-webhook-running-guide.md)** - Quick reference for starting/stopping the webhook server

