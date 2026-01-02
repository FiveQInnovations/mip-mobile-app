---
status: in progress
area: rn-mip-app
created: 2026-01-21
---

# EAS Build Completion Webhook

## Context
Set up a webhook to receive notifications when EAS builds complete. This will enable automated workflows for downloading build artifacts and uploading them to BrowserStack for testing. 

For this initial ticket, focus on verifying the webhook setup works locally. Future tickets will handle downloading the APK and uploading to BrowserStack.

**Reference:** https://docs.expo.dev/eas/webhooks/

## Tasks
- [x] Create webhook endpoint server (Express.js) to receive EAS webhook POST requests
- [x] Implement signature verification using HMAC-SHA1 to validate webhook authenticity
- [x] Set up local webhook server with ngrok or similar tunnel for testing
- [ ] Configure EAS webhook using `eas webhook:create` command
- [ ] Test webhook receives build completion events (success, error, canceled)
- [ ] Verify webhook signature validation works correctly
- [x] Document webhook setup and configuration

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
- Generated secure webhook secret: `51c8b7689ea19830ff5f5ebd1ba4423e82887e85eab7cd40de202ff827684eb6`
- Added `WEBHOOK_SECRET` to `.env.example` for reference
- Server uses `dotenv` to load environment variables

### Next Steps for Testing
1. Copy `.env.example` to `.env`: `cp .env.example .env`
2. Verify `WEBHOOK_SECRET` is set in `.env` (or generate a new one)
3. Start webhook server: `npm run webhook:server`
4. Start ngrok tunnel: `ngrok http 3000`
5. Create EAS webhook: `eas webhook:create --url <ngrok-url>/webhook --secret <your-secret-from-env>`
6. Trigger a build to test webhook reception

See `docs/eas-webhook-setup.md` for detailed setup instructions.

