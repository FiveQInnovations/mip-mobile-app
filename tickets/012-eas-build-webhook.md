---
status: backlog
area: rn-mip-app
created: 2026-01-21
---

# EAS Build Completion Webhook

## Context
Set up a webhook to receive notifications when EAS builds complete. This will enable automated workflows for downloading build artifacts and uploading them to BrowserStack for testing. 

For this initial ticket, focus on verifying the webhook setup works locally. Future tickets will handle downloading the APK and uploading to BrowserStack.

**Reference:** https://docs.expo.dev/eas/webhooks/

## Tasks
- [ ] Create webhook endpoint server (Express.js) to receive EAS webhook POST requests
- [ ] Implement signature verification using HMAC-SHA1 to validate webhook authenticity
- [ ] Set up local webhook server with ngrok or similar tunnel for testing
- [ ] Configure EAS webhook using `eas webhook:create` command
- [ ] Test webhook receives build completion events (success, error, canceled)
- [ ] Verify webhook signature validation works correctly
- [ ] Document webhook setup and configuration

## Notes

