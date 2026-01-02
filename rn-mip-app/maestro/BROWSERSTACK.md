# BrowserStack Testing Guide

This guide explains how to run Maestro tests on BrowserStack cloud devices for Android app testing.

## Quick Start: Manual Sanity Check First

If you've already uploaded your APK to BrowserStack App Live:

1. **Manual Verification** (Recommended first step):
   - Open your uploaded app in BrowserStack App Live
   - Manually verify the homepage loads
   - Check that key elements (FFCI, Menu, Resources) are visible
   - This gives you confidence before automating

2. **Then Automate**: Follow the steps below to automate the sanity check

## Prerequisites

1. **BrowserStack Account**: You need a BrowserStack account with App Automate access
2. **APK Uploaded**: Your APK must be uploaded to BrowserStack App Automate (not App Live)
3. **Maestro Installed**: Maestro CLI must be installed locally

## BrowserStack App Automate vs App Live

- **App Live**: For manual testing - you interact with devices through a web interface
- **App Automate**: For automated testing - Maestro can run tests programmatically

**Important**: For automated Maestro tests, you need to upload your APK to **App Automate**, not App Live. If you only uploaded to App Live, you'll need to upload again to App Automate.

## Upload APK to BrowserStack App Automate

### Option 1: Using BrowserStack Dashboard

1. Go to [BrowserStack App Automate](https://www.browserstack.com/app-automate)
2. Navigate to "Apps" → "Upload App"
3. Upload your APK file
4. Note the `app_url` or `custom_id` from the response

### Option 2: Using API (Recommended for Automation)

```bash
curl -u "YOUR_USERNAME:YOUR_ACCESS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/upload" \
  -F "file=@/path/to/your/app.apk" \
  -F "custom_id=ffci-app-latest"
```

Save the `app_url` from the response - you'll need it for Maestro configuration.

## Running Maestro Tests on BrowserStack

### Step 1: Upload APK to App Automate

If you haven't already, upload your APK to BrowserStack App Automate:

```bash
# Using the existing upload script
node scripts/upload-to-browserstack.js your-app.apk

# Or using curl directly
curl -u "YOUR_USERNAME:YOUR_ACCESS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/upload" \
  -F "file=@/path/to/your/app.apk" \
  -F "custom_id=ffci-app-latest"
```

Save the `app_url` from the response (format: `bs://...`).

### Step 2: Set Environment Variables

Create a `.env` file or export variables:

```bash
export BROWSERSTACK_USERNAME="your_username"
export BROWSERSTACK_ACCESS_KEY="your_access_key"
export BROWSERSTACK_APP_URL="bs://your_app_url_from_upload"
```

### Step 3: Run Maestro Test

**Option A: Using Maestro Cloud (if available)**

```bash
maestro cloud \
  --username "$BROWSERSTACK_USERNAME" \
  --access-key "$BROWSERSTACK_ACCESS_KEY" \
  --app-url "$BROWSERSTACK_APP_URL" \
  test maestro/flows/homepage-sanity-check-browserstack.yaml
```

**Option B: Using npm script**

```bash
npm run test:maestro:browserstack
```

**Option C: Manual Maestro command**

Check Maestro documentation for the exact BrowserStack integration syntax. The command may vary based on your Maestro version.

**Note**: Maestro's BrowserStack integration may require Maestro Cloud subscription or specific CLI flags. Check [Maestro BrowserStack docs](https://docs.maestro.dev/cloud/browserstack) for the latest syntax.

## Simple Sanity Check Test

The `homepage-sanity-check-browserstack.yaml` test performs minimal checks:

1. Launches the app
2. Handles optional developer prompts
3. Waits for homepage to load
4. Verifies at least one key element is visible (FFCI, Menu, Resources, etc.)
5. Takes a screenshot for manual verification

This is intentionally minimal since your iOS test hasn't been validated on Android yet.

## Environment Variables

Create a `.env` file in `rn-mip-app/` directory:

```bash
BROWSERSTACK_USERNAME=your_username
BROWSERSTACK_ACCESS_KEY=your_access_key
BROWSERSTACK_APP_URL=bs://your_app_url_from_upload
```

Or export them before running tests:

```bash
export BROWSERSTACK_USERNAME="your_username"
export BROWSERSTACK_ACCESS_KEY="your_access_key"
export BROWSERSTACK_APP_URL="bs://your_app_url"
```

## Alternative: Test Locally First

Before running on BrowserStack, you can test the sanity check locally on an Android emulator:

```bash
# Start Android emulator
# Then run the test
maestro test maestro/flows/homepage-sanity-check-browserstack.yaml
```

This helps validate the test works before running on BrowserStack cloud devices.

## Troubleshooting

### Maestro doesn't recognize BrowserStack

- **Check Maestro version**: BrowserStack integration may require Maestro Cloud (paid service)
- **Verify credentials**: Ensure BrowserStack username and access key are correct
- **App URL format**: Should start with `bs://` (from App Automate upload response)
- **Check Maestro docs**: BrowserStack integration syntax may have changed - check [latest docs](https://docs.maestro.dev/cloud/browserstack)

### Maestro Cloud Not Available

If you don't have Maestro Cloud access, alternatives:

1. **Manual testing**: Use BrowserStack App Live for manual sanity checks
2. **Local emulator**: Test with Maestro on local Android emulator
3. **BrowserStack App Automate API**: Use BrowserStack's REST API with Appium/Detox instead of Maestro

### Test fails to launch app

- Verify the APK is uploaded to **App Automate** (not App Live)
- Check that the `appId` in the test file matches your app's package name (`com.fiveq.ffci`)
- Ensure the device configuration is correct
- Check BrowserStack device logs for launch errors

### Elements not found

- Android UI may differ from iOS - adjust selectors if needed
- Use `takeScreenshot` to inspect the actual screen state
- Consider using resource IDs instead of text matching for Android
- The sanity check uses flexible regex patterns - adjust if your homepage text differs

## Next Steps

Once the sanity check passes:

1. Gradually add more assertions from your iOS test
2. Test on multiple Android devices/versions
3. Integrate into CI/CD pipeline if needed
4. Expand test coverage based on Android-specific behavior

## References

- [Maestro BrowserStack Integration](https://docs.maestro.dev/cloud/browserstack)
- [BrowserStack App Automate API](https://www.browserstack.com/docs/app-automate/api-reference)
- [Maestro Cloud Testing](https://docs.maestro.dev/cloud/getting-started)

