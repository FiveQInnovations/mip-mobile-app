# EAS Build Webhook Setup

This guide explains how to set up and test the EAS build completion webhook locally.

## Overview

The webhook server receives notifications from Expo EAS when builds complete (success, error, or canceled). It verifies webhook authenticity using HMAC-SHA1 signature verification.

## Prerequisites

- Node.js installed
- Expo CLI installed (`npm install -g eas-cli`)
- ngrok installed (for local testing): `brew install ngrok` or download from [ngrok.com](https://ngrok.com)

## Installation

1. Install dependencies:
```bash
npm install
```

2. Set up your webhook secret:
   - Copy `.env.example` to `.env`: `cp .env.example .env`
   - Generate a secure secret (or use the one in `.env.example`):
     ```bash
     node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
     ```
   - Add `WEBHOOK_SECRET=your-generated-secret` to your `.env` file

3. The webhook server script is located at `scripts/eas-webhook-server.js`

## Running the Webhook Server

### Start the Server

The server automatically loads environment variables from `.env` file. Simply start it:

```bash
npm run webhook:server
```

Or specify a custom port:

```bash
PORT=3001 npm run webhook:server
```

**Alternative:** You can also set `WEBHOOK_SECRET` as an environment variable:
```bash
WEBHOOK_SECRET=your-secret-key npm run webhook:server
```

The server will start on port 3000 by default and listen for webhook POST requests at `/webhook`.

### Expose Locally with ngrok

For local testing, you need to expose the webhook server to the internet using ngrok:

1. Start the webhook server (in one terminal):
```bash
npm run webhook:server
```
(The server will automatically load `WEBHOOK_SECRET` from your `.env` file)

2. Start ngrok (in another terminal):
```bash
ngrok http 3000
```

3. Copy the HTTPS URL from ngrok (e.g., `https://abc123.ngrok.io`)

## Creating the EAS Webhook

Once your webhook server is running and exposed via ngrok:

1. Create the webhook using EAS CLI:
```bash
eas webhook:create --url https://your-ngrok-url.ngrok.io/webhook --secret your-secret-key
```

2. The webhook secret must match the `WEBHOOK_SECRET` environment variable used when starting the server.

3. EAS will send a test webhook to verify the endpoint is working.

## Webhook Events

The server handles the following EAS webhook events:

- `build.completed` - Fired when a build finishes (success, error, or canceled)
- `build.started` - Fired when a build starts

### Build Status Values

- `finished` - Build completed successfully
- `errored` - Build failed with an error
- `canceled` - Build was canceled

## Signature Verification

The webhook server automatically verifies all incoming requests using HMAC-SHA1:

1. Extracts the `expo-signature` header from the request
2. Computes HMAC-SHA1 digest of the raw request body using the webhook secret
3. Compares the computed signature with the received signature using constant-time comparison

If signature verification fails, the server returns a 401 Unauthorized response.

## Testing

### Manual Test

You can test the webhook endpoint manually:

```bash
curl -X POST http://localhost:3000/webhook \
  -H "Content-Type: application/json" \
  -H "expo-signature: sha1=test-signature" \
  -d '{"type":"build.completed","data":{"id":"test-build","status":"finished"}}'
```

Note: This will fail signature verification unless you use the correct secret and signature.

### Health Check

Check if the server is running:

```bash
curl http://localhost:3000/health
```

## Webhook Payload Structure

Example `build.completed` payload:

```json
{
  "type": "build.completed",
  "data": {
    "id": "build-id",
    "platform": "android",
    "status": "finished",
    "profile": "preview",
    "artifacts": {
      "buildUrl": "https://..."
    }
  }
}
```

## Troubleshooting

### Signature Verification Fails

- Ensure `WEBHOOK_SECRET` in your `.env` file matches the secret used when creating the webhook with `eas webhook:create`
- Verify the webhook server is receiving the raw request body (not parsed JSON)
- Check that the `expo-signature` header is present in the request
- Make sure your `.env` file is in the `rn-mip-app/` directory (same level as `package.json`)

### Webhook Not Received

- Verify ngrok is running and the URL is accessible
- Check that the webhook URL in EAS matches your ngrok URL
- Ensure the webhook server is running and listening on the correct port
- Check ngrok logs for incoming requests

### Port Already in Use

If port 3000 is already in use, specify a different port:

```bash
WEBHOOK_SECRET=your-secret PORT=3001 node scripts/eas-webhook-server.js
```

Then update ngrok to forward to the new port:

```bash
ngrok http 3001
```

## Next Steps

Future enhancements:
- Download build artifacts automatically when builds complete
- Upload APK/IPA files to BrowserStack for automated testing
- Send notifications (Slack, email, etc.) on build completion
- Store build history in a database

## References

- [EAS Webhooks Documentation](https://docs.expo.dev/eas/webhooks/)
- [ngrok Documentation](https://ngrok.com/docs)
