# React Native Version Mismatch Troubleshooting

## Problem

App crashes on launch with error:
```
FATAL EXCEPTION: com.facebook.react.common.JavascriptException
Error: Incompatible React versions:
  - react: 19.2.3
  - react-native-renderer: 19.1.0
```

## Root Cause

React Native has strict version requirements for React. Each React Native version requires a specific React version:

- **React Native 0.81.5** requires **React 19.1.0** (exact match)
- Using React 19.2.3 causes a mismatch with `react-native-renderer` which is bundled with React Native

This typically happens when:
- Dependencies pull in a newer React version (e.g., `expo-router` requiring `react-dom@19.2.3`)
- `npm install` upgrades React without checking React Native compatibility
- Package.json uses `^19.2.3` instead of exact version `19.1.0`

## Solution

### 1. Fix package.json
```json
{
  "dependencies": {
    "react": "19.1.0",  // Exact version, not ^19.1.0
    "react-native": "0.81.5"
  }
}
```

### 2. Configure EAS Build
Add to `eas.json` for all build profiles:
```json
{
  "build": {
    "preview": {
      "env": {
        "NPM_CONFIG_LEGACY_PEER_DEPS": "true"
      }
    }
  }
}
```

### 3. Reinstall Dependencies
```bash
npm install --legacy-peer-deps
```

### 4. Rebuild
```bash
eas build --profile preview --platform android
```

## Prevention

1. **Use exact React version** - Don't use `^` or `~` for React version in package.json
2. **Check React Native compatibility** - Verify required React version in React Native docs
3. **Use `--legacy-peer-deps`** - Always use this flag when installing to handle peer dependency conflicts
4. **Configure EAS builds** - Add `NPM_CONFIG_LEGACY_PEER_DEPS` to all build profiles in `eas.json`

## Quick Reference

| React Native Version | Required React Version |
|---------------------|----------------------|
| 0.81.5              | 19.1.0 (exact)       |

## Related Files

- `package.json` - React version specification
- `eas.json` - Build configuration with `NPM_CONFIG_LEGACY_PEER_DEPS`
- Issue #003 - Full context and resolution history

