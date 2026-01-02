#!/usr/bin/env node

/**
 * Upload APK to BrowserStack App Live
 * 
 * Usage:
 *   node scripts/upload-to-browserstack.js <apk-file-path>
 *   node scripts/upload-to-browserstack.js --url <apk-url>
 *   node scripts/upload-to-browserstack.js --custom-id <id> <apk-file-path>
 * 
 * Environment variables:
 *   BROWSERSTACK_USERNAME - BrowserStack username (required)
 *   BROWSERSTACK_ACCESS_KEY - BrowserStack access key (required)
 */

const fs = require('fs');
const path = require('path');
const https = require('https');
const { URL } = require('url');

const BROWSERSTACK_API_URL = 'https://api-cloud.browserstack.com/app-live/upload';

// Load .env file if it exists
function loadEnvFile() {
  const envPath = path.join(__dirname, '..', '.env');
  if (fs.existsSync(envPath)) {
    const envContent = fs.readFileSync(envPath, 'utf8');
    const lines = envContent.split('\n');
    for (const line of lines) {
      const trimmed = line.trim();
      // Skip comments and empty lines
      if (trimmed && !trimmed.startsWith('#')) {
        const match = trimmed.match(/^([^=]+)=(.*)$/);
        if (match) {
          const key = match[1].trim();
          const value = match[2].trim().replace(/^["']|["']$/g, ''); // Remove quotes
          if (!process.env[key]) {
            process.env[key] = value;
          }
        }
      }
    }
  }
}

// Load .env before checking credentials
loadEnvFile();

function getCredentials() {
  const username = process.env.BROWSERSTACK_USERNAME;
  const accessKey = process.env.BROWSERSTACK_ACCESS_KEY;

  if (!username || !accessKey || accessKey === 'your_access_key_here') {
    console.error('❌ Error: BrowserStack credentials not found');
    console.error('');
    console.error('Please set the following environment variables:');
    console.error('  BROWSERSTACK_USERNAME - Your BrowserStack username');
    console.error('  BROWSERSTACK_ACCESS_KEY - Your BrowserStack access key');
    console.error('');
    console.error('You can either:');
    console.error('  1. Create a .env file in the project root (see .env.example)');
    console.error('  2. Export them as environment variables');
    console.error('');
    console.error('You can find these in your BrowserStack account settings:');
    console.error('  https://www.browserstack.com/accounts/settings');
    process.exit(1);
  }

  return { username, accessKey };
}

function uploadFile(filePath, customId = null) {
  return new Promise((resolve, reject) => {
    const { username, accessKey } = getCredentials();

    if (!fs.existsSync(filePath)) {
      reject(new Error(`APK file not found: ${filePath}`));
      return;
    }

    const fileStats = fs.statSync(filePath);
    if (fileStats.size === 0) {
      reject(new Error(`APK file is empty: ${filePath}`));
      return;
    }

    console.log(`📤 Uploading APK: ${path.basename(filePath)}`);
    console.log(`   Size: ${(fileStats.size / 1024 / 1024).toFixed(2)} MB`);

    const fileStream = fs.createReadStream(filePath);
    const boundary = `----WebKitFormBoundary${Math.random().toString(36).substring(2)}`;
    
    const formData = [];
    
    // Add file field
    formData.push(`--${boundary}`);
    formData.push(`Content-Disposition: form-data; name="file"; filename="${path.basename(filePath)}"`);
    formData.push(`Content-Type: application/vnd.android.package-archive`);
    formData.push('');
    
    // Add custom_id if provided
    if (customId) {
      formData.push(`--${boundary}`);
      formData.push(`Content-Disposition: form-data; name="data"`);
      formData.push(`Content-Type: application/json`);
      formData.push('');
      formData.push(JSON.stringify({ custom_id: customId }));
    }
    
    formData.push(`--${boundary}--`);

    const formDataString = formData.join('\r\n');
    const fileBuffer = fs.readFileSync(filePath);
    
    // Calculate total length
    const formDataBuffer = Buffer.from(formDataString, 'utf8');
    const totalLength = formDataBuffer.length + fileBuffer.length + 2; // +2 for CRLF before file

    const url = new URL(BROWSERSTACK_API_URL);
    const auth = Buffer.from(`${username}:${accessKey}`).toString('base64');

    const options = {
      hostname: url.hostname,
      port: 443,
      path: url.pathname,
      method: 'POST',
      headers: {
        'Authorization': `Basic ${auth}`,
        'Content-Type': `multipart/form-data; boundary=${boundary}`,
        'Content-Length': totalLength,
      },
    };

    const req = https.request(options, (res) => {
      let responseData = '';

      res.on('data', (chunk) => {
        responseData += chunk;
      });

      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          try {
            const result = JSON.parse(responseData);
            resolve(result);
          } catch (e) {
            // If response is not JSON, might be success anyway
            if (responseData.includes('app_url') || responseData.includes('app_id')) {
              resolve(responseData);
            } else {
              reject(new Error(`Unexpected response: ${responseData}`));
            }
          }
        } else {
          reject(new Error(`Upload failed with status ${res.statusCode}: ${responseData}`));
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    // Write form data
    req.write(formDataBuffer);
    req.write('\r\n');
    
    // Write file
    req.write(fileBuffer);
    
    // Write closing boundary
    req.write('\r\n');
    req.write(`--${boundary}--`);
    
    req.end();
  });
}

function uploadFromUrl(apkUrl, customId = null) {
  return new Promise((resolve, reject) => {
    const { username, accessKey } = getCredentials();

    console.log(`📤 Uploading APK from URL: ${apkUrl}`);

    const boundary = `----WebKitFormBoundary${Math.random().toString(36).substring(2)}`;
    const data = customId 
      ? JSON.stringify({ url: apkUrl, custom_id: customId })
      : JSON.stringify({ url: apkUrl });
    
    const formData = [
      `--${boundary}`,
      `Content-Disposition: form-data; name="data"`,
      `Content-Type: application/json`,
      '',
      data,
      `--${boundary}--`
    ].join('\r\n');

    const url = new URL(BROWSERSTACK_API_URL);
    const auth = Buffer.from(`${username}:${accessKey}`).toString('base64');

    const options = {
      hostname: url.hostname,
      port: 443,
      path: url.pathname,
      method: 'POST',
      headers: {
        'Authorization': `Basic ${auth}`,
        'Content-Type': `multipart/form-data; boundary=${boundary}`,
        'Content-Length': Buffer.byteLength(formData),
      },
    };

    const req = https.request(options, (res) => {
      let responseData = '';

      res.on('data', (chunk) => {
        responseData += chunk;
      });

      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          try {
            const result = JSON.parse(responseData);
            resolve(result);
          } catch (e) {
            reject(new Error(`Failed to parse response: ${responseData}`));
          }
        } else {
          reject(new Error(`Upload failed with status ${res.statusCode}: ${responseData}`));
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    req.write(formData);
    req.end();
  });
}

function displayResult(result) {
  console.log('');
  console.log('✅ Upload successful!');
  console.log('');
  
  if (typeof result === 'string') {
    // Try to extract info from string response
    const appUrlMatch = result.match(/app_url["\s:]+([^\s"']+)/i);
    const appIdMatch = result.match(/app_id["\s:]+([^\s"']+)/i);
    
    if (appUrlMatch) {
      console.log(`🔗 App URL: ${appUrlMatch[1]}`);
    }
    if (appIdMatch) {
      console.log(`🆔 App ID: ${appIdMatch[1]}`);
    }
    if (!appUrlMatch && !appIdMatch) {
      console.log('📄 Response:', result);
    }
  } else {
    if (result.app_url) {
      console.log(`🔗 App URL: ${result.app_url}`);
    }
    if (result.app_id) {
      console.log(`🆔 App ID: ${result.app_id}`);
    }
    if (result.custom_id) {
      console.log(`🏷️  Custom ID: ${result.custom_id}`);
    }
    if (!result.app_url && !result.app_id) {
      console.log('📄 Response:', JSON.stringify(result, null, 2));
    }
  }
  
  console.log('');
  console.log('💡 You can now test your app on BrowserStack App Live:');
  console.log('   https://www.browserstack.com/app-live');
}

function main() {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    console.error('❌ Error: No APK file or URL provided');
    console.error('');
    console.error('Usage:');
    console.error('  node scripts/upload-to-browserstack.js <apk-file-path>');
    console.error('  node scripts/upload-to-browserstack.js --url <apk-url>');
    console.error('  node scripts/upload-to-browserstack.js --custom-id <id> <apk-file-path>');
    console.error('');
    console.error('Examples:');
    console.error('  node scripts/upload-to-browserstack.js ffci-preview.apk');
    console.error('  node scripts/upload-to-browserstack.js --url https://example.com/app.apk');
    console.error('  node scripts/upload-to-browserstack.js --custom-id "build-123" ffci-preview.apk');
    process.exit(1);
  }

  let customId = null;
  let apkPath = null;
  let useUrl = false;
  let url = null;

  // Parse arguments
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--custom-id' && i + 1 < args.length) {
      customId = args[i + 1];
      i++;
    } else if (args[i] === '--url' && i + 1 < args.length) {
      useUrl = true;
      url = args[i + 1];
      i++;
    } else if (!apkPath && !useUrl) {
      apkPath = args[i];
    }
  }

  // Validate arguments
  if (useUrl && !url) {
    console.error('❌ Error: --url flag requires a URL');
    process.exit(1);
  }

  if (!useUrl && !apkPath) {
    console.error('❌ Error: APK file path required');
    process.exit(1);
  }

  // Upload
  const uploadPromise = useUrl 
    ? uploadFromUrl(url, customId)
    : uploadFile(apkPath, customId);

  uploadPromise
    .then((result) => {
      displayResult(result);
    })
    .catch((error) => {
      console.error('');
      console.error('❌ Upload failed:', error.message);
      console.error('');
      process.exit(1);
    });
}

if (require.main === module) {
  main();
}

module.exports = { uploadFile, uploadFromUrl };

