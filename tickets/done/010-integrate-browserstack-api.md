---
status: done
area: rn-mip-app
created: 2026-01-20
completed: 2026-01-21
---

# Integrate BrowserStack App Live API

## Context
We've chosen BrowserStack App Live for testing Android apps on real devices in the cloud. Currently, we manually upload APKs through the BrowserStack dashboard. Integrating with their API will allow us to automate the upload and testing process, making it easier to test builds from EAS.

**Current State:**
- BrowserStack account already exists
- Manual APK upload via BrowserStack dashboard
- EAS builds Android APKs successfully
- Need to download APK and manually upload to BrowserStack

**Benefits of API Integration:**
- Automate APK upload after EAS builds complete
- Streamline testing workflow
- Potentially integrate into CI/CD pipeline
- Reduce manual steps in testing process

## Tasks
- [x] Research BrowserStack App Live REST API endpoints
- [x] Set up BrowserStack API credentials (username/access key)
- [x] Create script/utility to upload APK via API
- [x] Integrate with EAS build workflow (post-build hook or script)
- [x] Test automated upload process
- [x] Document API integration setup and usage
- [x] Consider Android Studio plugin integration (optional - not needed, scripts work well)

## Notes

### BrowserStack App Live API Documentation
- Main docs: https://www.browserstack.com/docs?product=app-live
- REST API reference: https://www.browserstack.com/app-live/rest-api

### API Upload Methods

**1. Upload APK File:**
```bash
curl -u "USERNAME:ACCESS_KEY" -X POST "https://api-cloud.browserstack.com/app-live/upload" -F "file=@/path/to/your/app.apk"
```

**2. Upload from Public URL:**
```bash
curl -u "USERNAME:ACCESS_KEY" -X POST "https://api-cloud.browserstack.com/app-live/upload" -F "data={\"url\": \"https://example.com/your-app.apk\"}"
```

**3. Upload with Custom ID:**
```bash
curl -u "USERNAME:ACCESS_KEY" -X POST "https://api-cloud.browserstack.com/app-live/upload" -F "file=@/path/to/your/app.apk" -F "data={\"custom_id\": \"YourAppID\"}"
```

### Integration Options

**Option 1: Post-Build Script**
- Create Node.js script that runs after EAS build completes
- Downloads APK from EAS build URL
- Uploads to BrowserStack via REST API
- Could be triggered manually or via CI/CD

**Option 2: Android Studio Plugin**
- BrowserStack offers Android Studio plugin
- Allows testing directly from IDE
- Less useful for automated workflows

**Option 3: CI/CD Integration**
- Add BrowserStack upload step to GitHub Actions or similar
- Automatically upload builds for testing
- Requires API credentials in CI/CD secrets

### Related Tickets
- Ticket #003: Deploy to Real device (EAS) - BrowserStack chosen as testing solution

---

### ✅ COMPLETED (2026-01-21)

**Status:** Complete - BrowserStack API integration fully implemented

**Implementation:**
- ✅ Created `scripts/upload-to-browserstack.js` - Node.js script using BrowserStack REST API
- ✅ Created `scripts/upload-to-browserstack.sh` - Shell script wrapper for easy CLI usage
- ✅ Created `scripts/deploy-to-browserstack.sh` - Complete workflow integrating EAS build with BrowserStack upload
- ✅ Scripts support multiple upload methods:
  - Direct file upload
  - Upload from public URL
  - Custom ID support
- ✅ Integrated with EAS build workflow - `deploy-to-browserstack.sh` handles full process:
  1. Pre-build validation
  2. EAS build
  3. Download APK
  4. Upload to BrowserStack via API
- ✅ Uses environment variables for credentials (`BROWSERSTACK_USERNAME`, `BROWSERSTACK_ACCESS_KEY`)
- ✅ Supports `.env` file for credential management
- ✅ Comprehensive error handling and user feedback

**Usage:**
```bash
# Complete workflow (build + upload)
./scripts/deploy-to-browserstack.sh

# Upload existing APK
./scripts/upload-to-browserstack.sh ffci-preview.apk

# Upload from URL
./scripts/upload-to-browserstack.sh --url https://example.com/app.apk
```

**Files Created:**
- `rn-mip-app/scripts/upload-to-browserstack.js`
- `rn-mip-app/scripts/upload-to-browserstack.sh`
- `rn-mip-app/scripts/deploy-to-browserstack.sh`


