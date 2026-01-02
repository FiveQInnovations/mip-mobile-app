# EAS Webhook Server - Running Guide

Quick reference guide for starting and stopping the EAS build webhook server.

## Prerequisites

- `.env` file configured with `WEBHOOK_SECRET` (see [eas-webhook-setup.md](./eas-webhook-setup.md))
- Dependencies installed: `npm install`

## Starting the Webhook Server

### Step 1: Start the Webhook Server

In the `rn-mip-app` directory, run:

```bash
npm run webhook:server
```

The server will start on port 3000 by default. You should see:

```
🚀 EAS Webhook Server running on port 3000
📡 Webhook endpoint: http://localhost:3000/webhook
💚 Health check: http://localhost:3000/health
```

### Step 2: Expose with Tunnel (for local testing)

You need to expose the local server to the internet so EAS can reach it. Choose one:

#### Option A: Using ngrok (requires authentication)

1. Install ngrok: `brew install ngrok/ngrok/ngrok`
2. Authenticate: `ngrok config add-authtoken <your-token>` (get token from https://dashboard.ngrok.com/get-started/your-authtoken)
3. Start tunnel: `ngrok http 3000`
4. Copy the HTTPS URL (e.g., `https://abc123.ngrok.io`)

#### Option B: Using localtunnel (no auth required)

```bash
npx localtunnel --port 3000
```

Copy the URL shown (e.g., `https://vast-clouds-judge.loca.lt`)

### Step 3: Create/Update EAS Webhook

If creating a new webhook:

```bash
cd rn-mip-app
WEBHOOK_SECRET=$(node -e "require('dotenv').config(); console.log(process.env.WEBHOOK_SECRET)") && \
eas webhook:create \
  --url <your-tunnel-url>/webhook \
  --secret "$WEBHOOK_SECRET" \
  --event BUILD \
  --non-interactive
```

If updating an existing webhook, first list webhooks:

```bash
eas webhook:list
```

Then delete the old one and create a new one with the updated URL.

## Stopping the Webhook Server

### Stop the Webhook Server

Press `Ctrl+C` in the terminal where the server is running, or:

```bash
pkill -f "eas-webhook-server"
```

### Stop the Tunnel

- **ngrok**: Press `Ctrl+C` in the ngrok terminal, or `pkill -f ngrok`
- **localtunnel**: Press `Ctrl+C` in the localtunnel terminal, or `pkill -f localtunnel`

### Stop Everything at Once

```bash
pkill -f "eas-webhook-server" && pkill -f "localtunnel" && pkill -f ngrok
```

## Verifying It's Running

### Check Webhook Server

```bash
curl http://localhost:3000/health
```

Should return: `{"status":"ok","service":"eas-webhook-server","port":3000}`

### Check Running Processes

```bash
ps aux | grep -E "(eas-webhook-server|localtunnel|ngrok)" | grep -v grep
```

### List EAS Webhooks

```bash
eas webhook:list
```

## Troubleshooting

### Port Already in Use

If port 3000 is busy, specify a different port:

```bash
PORT=3001 npm run webhook:server
```

Then update your tunnel to use port 3001.

### Webhook Secret Not Found

Ensure your `.env` file exists and contains `WEBHOOK_SECRET`:

```bash
cd rn-mip-app
cat .env | grep WEBHOOK_SECRET
```

### Tunnel URL Changed

If using localtunnel, the URL changes each time you restart it. You'll need to update the EAS webhook URL:

1. Get new tunnel URL
2. List existing webhooks: `eas webhook:list`
3. Delete old webhook (if needed)
4. Create new webhook with updated URL

For a stable URL, use ngrok with authentication.

## Background Operation

To run the webhook server in the background:

```bash
npm run webhook:server > /tmp/webhook.log 2>&1 &
```

View logs:
```bash
tail -f /tmp/webhook.log
```

Stop background server:
```bash
pkill -f "eas-webhook-server"
```

## Related Documentation

- **[EAS Webhook Setup](./eas-webhook-setup.md)** - Complete setup and configuration guide
- **[EAS Webhooks Documentation](https://docs.expo.dev/eas/webhooks/)** - Official Expo documentation
