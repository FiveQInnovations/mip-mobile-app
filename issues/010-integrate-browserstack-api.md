---
status: backlog
area: rn-mip-app
created: 2026-01-20
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
- [ ] Research BrowserStack App Live REST API endpoints
- [ ] Set up BrowserStack API credentials (username/access key)
- [ ] Create script/utility to upload APK via API
- [ ] Integrate with EAS build workflow (post-build hook or script)
- [ ] Test automated upload process
- [ ] Document API integration setup and usage
- [ ] Consider Android Studio plugin integration (optional)

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

### Related Issues
- Issue #003: Deploy to Real device (EAS) - BrowserStack chosen as testing solution


