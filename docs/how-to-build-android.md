# How To Build Android

Quick reference for building Android APKs with EAS Build.

## Build Types

| Profile | Dev Server Required? | Use Case |
|---------|----------------------|----------|
| **development** | ✅ Yes | Local development with hot reload |
| **preview** | ❌ No | Testing standalone builds (BrowserStack, physical devices) |
| **production** | ❌ No | App store releases |

## Building

### Development Build (requires dev server)
```bash
eas build --profile development --platform android
```
- Includes `expo-dev-client`
- Requires running `npx expo start --dev-client` to load JavaScript
- Use for: Local development with hot reload

### Preview Build (standalone, no dev server)
```bash
eas build --profile preview --platform android
```
- Standalone build that runs independently
- No dev server needed
- Use for: Testing on BrowserStack, physical devices, sharing with testers

### Production Build (standalone, app store ready)
```bash
eas build --profile production --platform android
```
- Standalone build optimized for release
- Auto-increments version numbers
- Use for: App store submission

## Testing on BrowserStack

**Important:** Use the `preview` profile for BrowserStack testing.

1. Build with preview profile:
   ```bash
   eas build --profile preview --platform android
   ```

2. Download APK from EAS build page

3. Upload to BrowserStack App Live dashboard

4. Select Android device and test

The preview build will run without requiring an Expo dev server.

## Configuration

Build profiles are defined in `eas.json`:

- **development**: `developmentClient: true` → requires dev server
- **preview**: No `developmentClient` → standalone build
- **production**: No `developmentClient` → standalone build for release

## Pre-Build Validation

Before starting an EAS build, run the pre-build check to catch dependency issues early:

```bash
./scripts/pre-build-check.sh
```

This script:
- Verifies `package-lock.json` exists (required for `npm ci`)
- Runs `npm ci` to catch dependency conflicts (same as EAS Build)
- Runs `expo-doctor` to check for common issues

**Why this matters:** EAS builds can take 20+ minutes. Catching dependency conflicts locally (which fail in ~1 minute) saves significant time.

The build script (`./scripts/build-and-download-preview.sh`) automatically runs this check before starting a build.

## Common Issues

**"Need a dev server" error on BrowserStack:**
- You're using the `development` profile
- Solution: Build with `--profile preview` instead

**App won't load:**
- Check you're using the correct build type for your use case
- Preview/production builds are standalone and don't need a dev server

**Build fails with "ERESOLVE could not resolve" during dependency installation:**
- This is a peer dependency conflict (e.g., React version mismatch)
- **Fix:** Run `./scripts/pre-build-check.sh` locally to reproduce and fix
- Common cause: React version doesn't match react-dom requirements
- Solution: Update React to match react-dom's peer dependency requirement

