#!/usr/bin/env node

/**
 * EAS Build Webhook Server
 * 
 * Receives webhook notifications from Expo EAS when builds complete.
 * Verifies webhook authenticity using HMAC-SHA1 signature verification.
 * 
 * Setup:
 *   1. Copy .env.example to .env: cp .env.example .env
 *   2. Ensure WEBHOOK_SECRET is set in .env file
 * 
 * Usage:
 *   npm run webhook:server
 *   Or: node scripts/eas-webhook-server.js [port]
 *   Default port: 3000
 * 
 * For local testing with ngrok:
 *   1. Start this server: npm run webhook:server
 *   2. Start ngrok: ngrok http 3000
 *   3. Create webhook: eas webhook:create --url <ngrok-url>/webhook --secret <your-secret-from-env>
 */

// Load environment variables from .env file
require('dotenv').config();

const express = require('express');
const bodyParser = require('body-parser');
const crypto = require('crypto');
const safeCompare = require('safe-compare');
const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');
const https = require('https');
const { uploadFromUrl, uploadFile } = require('./upload-to-browserstack');

const PORT = process.argv[2] || process.env.PORT || 3000;
const WEBHOOK_SECRET = process.env.WEBHOOK_SECRET;

if (!WEBHOOK_SECRET) {
  console.error('ERROR: WEBHOOK_SECRET environment variable is required');
  console.error('');
  console.error('You can set it in one of these ways:');
  console.error('  1. Create a .env file in the project root with: WEBHOOK_SECRET=your-secret-key');
  console.error('  2. Export as environment variable: export WEBHOOK_SECRET=your-secret-key');
  console.error('  3. Pass inline: WEBHOOK_SECRET=your-secret-key node scripts/eas-webhook-server.js');
  console.error('');
  console.error('See .env.example for reference.');
  process.exit(1);
}

const app = express();

// Use raw body parser to get the exact request body for signature verification
// EAS webhooks send JSON, but we need the raw body for HMAC verification
app.use(bodyParser.text({ type: '*/*' }));

/**
 * Verify webhook signature using HMAC-SHA1
 * @param {string} signature - The expo-signature header value
 * @param {string} body - The raw request body
 * @param {string} secret - The webhook secret key
 * @returns {boolean} - True if signature is valid
 */
function verifySignature(signature, body, secret) {
  if (!signature) {
    return false;
  }

  // Compute HMAC-SHA1 digest
  const hmac = crypto.createHmac('sha1', secret);
  hmac.update(body);
  const computedHash = `sha1=${hmac.digest('hex')}`;

  // Use safe-compare to prevent timing attacks
  return safeCompare(signature, computedHash);
}

/**
 * Parse webhook payload and extract build information
 */
function parseWebhookPayload(body) {
  try {
    return JSON.parse(body);
  } catch (error) {
    console.error('Failed to parse webhook payload:', error);
    return null;
  }
}

/**
 * Download build artifact from EAS
 * @param {string} buildId - The build ID
 * @param {string} platform - The platform (android/ios)
 * @param {string} artifactUrl - Optional direct download URL from artifacts.buildUrl
 * @returns {Promise<string>} - Path to downloaded file
 */
async function downloadBuildArtifact(buildId, platform, artifactUrl = null) {
  const outputDir = path.join(__dirname, '..');
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, -5);
  const extension = platform === 'android' ? 'apk' : 'ipa';
  const filename = `ffci-build-${buildId.slice(0, 8)}-${timestamp}.${extension}`;
  const outputPath = path.join(outputDir, filename);

  console.log(`[DOWNLOAD] Downloading ${platform} build artifact...`);
  console.log(`[DOWNLOAD] Build ID: ${buildId}`);

  // Try direct download from artifact URL first (faster)
  if (artifactUrl && platform === 'android') {
    try {
      console.log(`[DOWNLOAD] Attempting direct download from: ${artifactUrl}`);
      return await downloadFromUrl(artifactUrl, outputPath);
    } catch (error) {
      console.log(`[DOWNLOAD] Direct download failed, trying eas build:download: ${error.message}`);
    }
  }

  // Fallback to eas build:download command
  try {
    console.log(`[DOWNLOAD] Using eas build:download command...`);
    execSync(
      `eas build:download --platform ${platform} --id ${buildId} --output "${outputPath}"`,
      { cwd: outputDir, stdio: 'inherit' }
    );

    if (fs.existsSync(outputPath)) {
      console.log(`[DOWNLOAD] ✅ Downloaded to: ${outputPath}`);
      return outputPath;
    } else {
      throw new Error('Downloaded file not found');
    }
  } catch (error) {
    console.error(`[DOWNLOAD] ❌ Failed to download: ${error.message}`);
    throw error;
  }
}

/**
 * Download file from URL
 * @param {string} url - URL to download from
 * @param {string} outputPath - Path to save file
 * @returns {Promise<string>} - Path to downloaded file
 */
function downloadFromUrl(url, outputPath) {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(outputPath);
    
    https.get(url, (response) => {
      if (response.statusCode === 302 || response.statusCode === 301) {
        // Follow redirect
        https.get(response.headers.location, (redirectResponse) => {
          redirectResponse.pipe(file);
          file.on('finish', () => {
            file.close();
            resolve(outputPath);
          });
        }).on('error', reject);
      } else if (response.statusCode === 200) {
        response.pipe(file);
        file.on('finish', () => {
          file.close();
          resolve(outputPath);
        });
      } else {
        reject(new Error(`Download failed with status ${response.statusCode}`));
      }
    }).on('error', (error) => {
      fs.unlink(outputPath, () => {}); // Delete partial file
      reject(error);
    });
  });
}

/**
 * Upload build to BrowserStack
 * @param {string} filePath - Path to APK/IPA file
 * @param {string} buildId - Build ID for custom ID
 * @returns {Promise<void>}
 */
async function uploadToBrowserStack(filePath, buildId) {
  console.log(`[BROWSERSTACK] Uploading to BrowserStack...`);
  console.log(`[BROWSERSTACK] File: ${path.basename(filePath)}`);
  console.log(`[BROWSERSTACK] Build ID: ${buildId}`);

  try {
    const result = await uploadFile(filePath, `eas-build-${buildId}`);
    console.log(`[BROWSERSTACK] ✅ Upload successful!`);
    if (result.app_url) {
      console.log(`[BROWSERSTACK] 🔗 App URL: ${result.app_url}`);
    }
    if (result.app_id) {
      console.log(`[BROWSERSTACK] 🆔 App ID: ${result.app_id}`);
    }
  } catch (error) {
    console.error(`[BROWSERSTACK] ❌ Upload failed: ${error.message}`);
    throw error;
  }
}

/**
 * Process completed build: download and upload to BrowserStack
 * @param {object} build - Build data from webhook
 */
async function processCompletedBuild(build) {
  const { id: buildId, platform, status, artifacts } = build;

  // Only process successful Android builds for now
  if (platform !== 'android') {
    console.log(`[PROCESS] Skipping ${platform} build (only Android supported for BrowserStack)`);
    return;
  }

  if (status !== 'finished') {
    console.log(`[PROCESS] Skipping build with status: ${status}`);
    return;
  }

  try {
    // Download the build artifact
    const artifactUrl = artifacts?.buildUrl || null;
    const downloadedFile = await downloadBuildArtifact(buildId, platform, artifactUrl);

    // Upload to BrowserStack
    await uploadToBrowserStack(downloadedFile, buildId);

    console.log(`[PROCESS] ✅ Successfully processed build ${buildId}`);
    
    // Optionally clean up downloaded file after upload
    // fs.unlinkSync(downloadedFile);
  } catch (error) {
    console.error(`[PROCESS] ❌ Failed to process build ${buildId}: ${error.message}`);
    // Don't throw - we don't want to fail the webhook response
  }
}

// Webhook endpoint
app.post('/webhook', (req, res) => {
  const expoSignature = req.headers['expo-signature'];
  const rawBody = req.body;

  console.log(`\n[WEBHOOK] Received webhook request`);
  console.log(`[WEBHOOK] Headers:`, {
    'expo-signature': expoSignature ? 'present' : 'missing',
    'content-type': req.headers['content-type'],
    'user-agent': req.headers['user-agent']
  });

  // Verify signature
  if (!verifySignature(expoSignature, rawBody, WEBHOOK_SECRET)) {
    console.error('[WEBHOOK] ❌ Signature verification failed');
    return res.status(401).json({ 
      error: 'Invalid signature',
      message: 'Webhook signature verification failed'
    });
  }

  console.log('[WEBHOOK] ✅ Signature verified');

  // Parse payload
  const payload = parseWebhookPayload(rawBody);
  if (!payload) {
    return res.status(400).json({ 
      error: 'Invalid payload',
      message: 'Failed to parse webhook payload'
    });
  }

  // Log webhook event details
  console.log('[WEBHOOK] Event type:', payload.type || 'unknown');
  console.log('[WEBHOOK] Payload:', JSON.stringify(payload, null, 2));

  // Handle different event types
  // Note: EAS webhook payload structure is { type: "build.completed", data: { ...build info... } }
  if (payload.type === 'build.completed') {
    // Handle both nested (data) and flat payload structures
    const build = payload.data || payload;
    console.log(`[WEBHOOK] Build completed:`);
    console.log(`  - Build ID: ${build.id}`);
    console.log(`  - Platform: ${build.platform}`);
    console.log(`  - Status: ${build.status}`);
    console.log(`  - Profile: ${build.profile || 'N/A'}`);
    
    if (build.status === 'finished') {
      console.log(`  - ✅ Build succeeded`);
      if (build.artifacts) {
        console.log(`  - Artifacts available:`, build.artifacts);
      }
      
      // Process completed build: download and upload to BrowserStack
      // Run asynchronously so we can respond to webhook immediately
      processCompletedBuild(build).catch((error) => {
        console.error(`[WEBHOOK] ❌ Error processing build: ${error.message}`);
        console.error(`[WEBHOOK] Stack:`, error.stack);
      });
    } else if (build.status === 'errored') {
      console.log(`  - ❌ Build failed`);
      if (build.error) {
        console.log(`  - Error:`, build.error);
      }
    } else if (build.status === 'canceled') {
      console.log(`  - ⚠️  Build canceled`);
    }
  } else if (payload.type === 'build.started') {
    const build = payload.data;
    console.log(`[WEBHOOK] Build started:`);
    console.log(`  - Build ID: ${build.id}`);
    console.log(`  - Platform: ${build.platform}`);
    console.log(`  - Profile: ${build.profile || 'N/A'}`);
  }

  // Respond with success
  res.status(200).json({ 
    success: true,
    message: 'Webhook received and processed'
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok',
    service: 'eas-webhook-server',
    port: PORT
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`\n🚀 EAS Webhook Server running on port ${PORT}`);
  console.log(`📡 Webhook endpoint: http://localhost:${PORT}/webhook`);
  console.log(`💚 Health check: http://localhost:${PORT}/health`);
  console.log(`\n⚠️  For local testing, use ngrok to expose this server:`);
  console.log(`   ngrok http ${PORT}`);
  console.log(`\n📝 Then create webhook with:`);
  console.log(`   eas webhook:create --url <ngrok-url>/webhook --secret <your-secret>\n`);
});
