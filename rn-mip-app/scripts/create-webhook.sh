#!/bin/bash

# Quick script to create/update EAS webhook with tunnel URL
# Usage: ./scripts/create-webhook.sh <tunnel-url>
# Example: ./scripts/create-webhook.sh https://odd-goats-greet.loca.lt

set -e

cd "$(dirname "$0")/.."

if [ -z "$1" ]; then
    echo "❌ Error: Tunnel URL required"
    echo ""
    echo "Usage: $0 <tunnel-url>"
    echo "Example: $0 https://odd-goats-greet.loca.lt"
    exit 1
fi

TUNNEL_URL="$1"
WEBHOOK_URL="${TUNNEL_URL%/}/webhook"

# Extract WEBHOOK_SECRET from .env file
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found"
    exit 1
fi

WEBHOOK_SECRET=$(node -e "require('dotenv').config(); console.log(process.env.WEBHOOK_SECRET)")

if [ -z "$WEBHOOK_SECRET" ]; then
    echo "❌ Error: WEBHOOK_SECRET not found in .env file"
    exit 1
fi

echo "🔗 Creating webhook..."
echo "   URL: $WEBHOOK_URL"
echo ""

eas webhook:create \
  --url "$WEBHOOK_URL" \
  --secret "$WEBHOOK_SECRET" \
  --event BUILD

echo ""
echo "✅ Webhook created successfully!"
