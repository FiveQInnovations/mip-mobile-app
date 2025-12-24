# React Native Mobile App - Getting Started Guide

This guide will help you set up the React Native mobile app framework and get a basic homepage running on an iOS simulator (or Android emulator if needed).

## Prerequisites

Before starting, ensure you have:

- **Node.js** (v18 or later)
- **npm** or **yarn**
- **Expo CLI**: `npm install -g expo-cli` or `npm install -g @expo/cli`
- **Xcode** (for iOS simulator) - macOS only
- **Android Studio** (for Android emulator) - optional, use if iOS simulator has issues
- **Git** for cloning repositories
- **API Access**: Bearer token for the mobile API (you can create your own for development/testing)

## Project Structure Overview

This repository contains multiple related projects. Understanding the structure will help you navigate the codebase:

```
mip-mobile-app/                    # Project root
├── astro-prototype/               # Astro PWA prototype (reference implementation)
│   ├── src/                       # Astro components and pages
│   ├── cypress/                   # Integration tests
│   ├── docs/                      # Astro-specific documentation
│   └── configs/                   # Site configuration files
├── sites/
│   └── ws-ffci-copy/              # Kirby CMS site (content source)
│       ├── site/                  # Kirby site files
│       ├── content/               # CMS content
│       └── www/                   # Web root
├── plugins/
│   └── wsp-mobile/                # Mobile API plugin
│       ├── lib/                   # API endpoint implementations
│       └── index.php              # Plugin entry point
├── docs/                          # Core documentation
│   ├── mobile-app-specification.md
│   ├── mobile-api-prototype-results.md
│   ├── react-native-getting-started.md (this file)
│   └── ...
├── meetings/                      # Meeting notes
└── rn-mip-app/                    # React Native app (to be created)
```

### Key Components

- **`astro-prototype/`**: A working PWA prototype built with Astro. This serves as a reference implementation showing how the API is used, how components are structured, and how features work. Useful for understanding:
  - API response structures (see `src/lib/api.ts`)
  - Component patterns (see `src/components/`)
  - Integration tests (see `cypress/e2e/integration/`)

- **`sites/ws-ffci-copy/`**: The Kirby CMS site that provides content via the mobile API. This is where:
  - Content is managed (pages, collections, etc.)
  - Mobile settings are configured (logo, menu, homepage type)
  - The API endpoints are served (when plugin is installed)

- **`plugins/wsp-mobile/`**: The Kirby plugin that provides the `/mobile-api` endpoints. This plugin:
  - Exposes menu data (`/mobile-api/menu`)
  - Exposes site data (`/mobile-api`)
  - Exposes page data (`/mobile-api/page/{uuid}`)
  - Transforms internal links in content

- **`docs/`**: Core documentation including:
  - `mobile-app-specification.md` - Complete requirements
  - `mobile-api-prototype-results.md` - API structure and examples
  - `react-native-getting-started.md` - This guide
  - `maestro-getting-started-guide.md` - Testing documentation

- **`rn-mip-app/`**: Your new React Native app (created in Step 1). This will be a sibling folder to the other projects.

### How They Work Together

1. **Kirby Site** (`sites/ws-ffci-copy/`) serves content via the **Mobile API Plugin** (`plugins/wsp-mobile/`)
2. **Astro Prototype** (`astro-prototype/`) demonstrates how to consume the API (useful reference)
3. **React Native App** (`rn-mip-app/`) will consume the same API endpoints as the Astro prototype
4. **Documentation** (`docs/`) provides specifications and guides

**Note**: The React Native app will be created as a new folder at the project root, alongside `astro-prototype/`, `sites/`, `plugins/`, and `docs/`.

## Step 1: Create Expo Project

Create a new Expo project with TypeScript:

```bash
npx create-expo-app@latest rn-mip-app --template blank-typescript
cd rn-mip-app
```

**Recommended dependencies to install:**

```bash
npm install expo-router react-native-safe-area-context react-native-screens
npm install @react-native-async-storage/async-storage
npm install react-native-webview
npm install @tanstack/react-query zustand
npm install nativewind tailwindcss
npm install --save-dev @types/react
```

## Step 2: React Native App Structure

Set up the basic folder structure for your React Native app (`rn-mip-app/`):

```
rn-mip-app/
├── app/                    # Expo Router app directory
│   ├── _layout.tsx         # Root layout
│   ├── index.tsx           # Homepage
│   └── (tabs)/             # Tab navigation (future)
├── components/             # Reusable components
│   ├── HomeScreen.tsx
│   └── SplashScreen.tsx
├── lib/                    # Utilities and API
│   ├── api.ts              # API client
│   └── config.ts           # Site configuration
├── configs/                # Site-specific configs
│   ├── ffci.json
│   └── template.json
├── types/                  # TypeScript types
│   └── api.ts
└── app.json                # Expo config
```

## Step 3: Configuration System

Create `lib/config.ts` to load site configuration:

```typescript
import { Platform } from 'react-native';

export interface SiteConfig {
  siteId: string;
  apiBaseUrl: string;
  apiToken: string;
  appName: string;
  appSlug: string;
  primaryColor: string;
  secondaryColor: string;
  iosBundle: string;
  androidPackage: string;
}

// For now, use a simple config object
// Later, this will load from configs/{siteId}.json
export const siteConfig: SiteConfig = {
  siteId: 'ffci',
  apiBaseUrl: 'https://ws-ffci-copy.ddev.site',
  apiToken: 'YOUR_BEARER_TOKEN_HERE', // Create your own token for development (see below)
  appName: 'FFCI',
  appSlug: 'ffci-app',
  primaryColor: '#D9232A', // FFCI Red
  secondaryColor: '#024D91', // FFCI Blue
  iosBundle: 'com.fiveq.ffci',
  androidPackage: 'com.fiveq.ffci',
};

export function getConfig(): SiteConfig {
  return siteConfig;
}
```

**Important**: Replace `YOUR_BEARER_TOKEN_HERE` with your own bearer token. You can create a token for development/testing purposes. For production, Five Q will provide the official bearer token.

## Step 4: API Client Setup

Create `lib/api.ts` with TypeScript types matching the API response structure:

```typescript
import { getConfig } from './config';

const config = getConfig();

export interface MenuPage {
  uuid: string;
  type: string;
  url: string;
}

export interface MenuItem {
  label: string;
  icon?: string;
  page: MenuPage;
}

export interface SiteMeta {
  title: string;
  social: Array<{ platform: string; url: string }>;
  logo: string | null;
  app_name: string;
  homepage_type?: 'content' | 'collection' | 'navigation' | 'action-hub';
  homepage_content?: string;
  homepage_collection?: string;
}

export interface SiteData {
  menu: MenuItem[];
  site_data: SiteMeta;
}

export class ApiError extends Error {
  status: number;
  url: string;

  constructor(message: string, status: number, url: string) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
    this.url = url;
  }
}

async function fetchJson<T>(url: string, label: string): Promise<T> {
  const response = await fetch(url, {
    headers: {
      'Authorization': `Bearer ${config.apiToken}`,
      'Content-Type': 'application/json',
    },
  });

  if (!response.ok) {
    throw new ApiError(
      `Failed to fetch ${label} (${response.status})`,
      response.status,
      url
    );
  }

  return response.json() as Promise<T>;
}

export async function getSiteData(): Promise<SiteData> {
  return fetchJson<SiteData>(
    `${config.apiBaseUrl}/mobile-api`,
    'site data'
  );
}

export async function getPage(uuid: string): Promise<any> {
  return fetchJson<any>(
    `${config.apiBaseUrl}/mobile-api/page/${uuid}`,
    `page ${uuid}`
  );
}
```

## Step 5: Splash Screen Component

Create `components/SplashScreen.tsx`:

```typescript
import React from 'react';
import { View, Text, ActivityIndicator, Image, StyleSheet } from 'react-native';
import { getConfig } from '../lib/config';

export function SplashScreen() {
  const config = getConfig();

  return (
    <View style={styles.container}>
      {config.logo && (
        <Image
          source={{ uri: config.logo }}
          style={styles.logo}
          resizeMode="contain"
        />
      )}
      <Text style={styles.appName}>{config.appName}</Text>
      <ActivityIndicator size="large" color={config.primaryColor} style={styles.loader} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#ffffff',
  },
  logo: {
    width: 200,
    height: 120,
    marginBottom: 20,
  },
  appName: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
  },
  loader: {
    marginTop: 20,
  },
});
```

## Step 6: Homepage Component

Create `components/HomeScreen.tsx`:

```typescript
import React from 'react';
import { View, Text, ScrollView, Image, StyleSheet, ActivityIndicator } from 'react-native';
import { getSiteData, SiteData } from '../lib/api';
import { getConfig } from '../lib/config';

export function HomeScreen() {
  const [siteData, setSiteData] = React.useState<SiteData | null>(null);
  const [loading, setLoading] = React.useState(true);
  const [error, setError] = React.useState<string | null>(null);
  const config = getConfig();

  React.useEffect(() => {
    loadData();
  }, []);

  async function loadData() {
    try {
      setLoading(true);
      const data = await getSiteData();
      setSiteData(data);
      setError(null);
    } catch (err: any) {
      setError(err.message || 'Failed to load data');
      console.error('Error loading site data:', err);
    } finally {
      setLoading(false);
    }
  }

  if (loading) {
    return (
      <View style={styles.container}>
        <ActivityIndicator size="large" color={config.primaryColor} />
        <Text style={styles.loadingText}>Loading...</Text>
      </View>
    );
  }

  if (error) {
    return (
      <View style={styles.container}>
        <Text style={styles.errorText}>Error: {error}</Text>
        <Text style={styles.retryText} onPress={loadData}>
          Tap to retry
        </Text>
      </View>
    );
  }

  if (!siteData) {
    return null;
  }

  const { site_data, menu } = siteData;
  const logoUrl = site_data.logo;

  return (
    <ScrollView style={styles.scrollView} contentContainerStyle={styles.content}>
      {/* Logo Section */}
      {logoUrl && (
        <View style={styles.logoSection}>
          <Image
            source={{ uri: logoUrl }}
            style={styles.logo}
            resizeMode="contain"
          />
          {site_data.title && (
            <Text style={styles.siteTitle}>{site_data.title}</Text>
          )}
        </View>
      )}

      {/* App Name */}
      <Text style={styles.appName}>{site_data.app_name || config.appName}</Text>

      {/* Menu Items */}
      <View style={styles.menuSection}>
        <Text style={styles.sectionTitle}>Menu</Text>
        {menu.map((item, index) => (
          <View key={index} style={styles.menuItem}>
            <Text style={styles.menuLabel}>{item.label}</Text>
            <Text style={styles.menuUuid}>{item.page.uuid}</Text>
          </View>
        ))}
      </View>

      {/* Homepage Type Info */}
      {site_data.homepage_type && (
        <View style={styles.infoSection}>
          <Text style={styles.infoLabel}>Homepage Type:</Text>
          <Text style={styles.infoValue}>{site_data.homepage_type}</Text>
        </View>
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#ffffff',
  },
  scrollView: {
    flex: 1,
    backgroundColor: '#ffffff',
  },
  content: {
    padding: 20,
  },
  loadingText: {
    marginTop: 10,
    fontSize: 16,
    color: '#666',
  },
  errorText: {
    fontSize: 16,
    color: '#d32f2f',
    marginBottom: 10,
  },
  retryText: {
    fontSize: 16,
    color: '#1976d2',
    textDecorationLine: 'underline',
  },
  logoSection: {
    alignItems: 'center',
    marginBottom: 30,
    paddingVertical: 20,
    backgroundColor: '#f5f5f5',
    borderRadius: 8,
  },
  logo: {
    width: 200,
    height: 120,
    marginBottom: 10,
  },
  siteTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: '#333',
  },
  appName: {
    fontSize: 28,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 30,
    color: '#333',
  },
  menuSection: {
    marginBottom: 20,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: '600',
    marginBottom: 15,
    color: '#333',
  },
  menuItem: {
    padding: 15,
    backgroundColor: '#f9f9f9',
    borderRadius: 8,
    marginBottom: 10,
  },
  menuLabel: {
    fontSize: 18,
    fontWeight: '500',
    color: '#333',
    marginBottom: 5,
  },
  menuUuid: {
    fontSize: 12,
    color: '#666',
    fontFamily: 'monospace',
  },
  infoSection: {
    padding: 15,
    backgroundColor: '#e3f2fd',
    borderRadius: 8,
  },
  infoLabel: {
    fontSize: 14,
    fontWeight: '600',
    color: '#1976d2',
    marginBottom: 5,
  },
  infoValue: {
    fontSize: 16,
    color: '#333',
  },
});
```

## Step 7: Expo Router Setup

Create `app/_layout.tsx`:

```typescript
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';

export default function RootLayout() {
  return (
    <>
      <StatusBar style="auto" />
      <Stack
        screenOptions={{
          headerShown: false,
        }}
      >
        <Stack.Screen name="index" />
      </Stack>
    </>
  );
}
```

Create `app/index.tsx`:

```typescript
import React from 'react';
import { HomeScreen } from '../components/HomeScreen';

export default function Index() {
  return <HomeScreen />;
}
```

## Step 8: Update app.json

Update `app.json` with your app configuration:

```json
{
  "expo": {
    "name": "FFCI Mobile",
    "slug": "ffci-app",
    "version": "1.0.0",
    "orientation": "portrait",
    "icon": "./assets/icon.png",
    "userInterfaceStyle": "light",
    "splash": {
      "image": "./assets/splash.png",
      "resizeMode": "contain",
      "backgroundColor": "#ffffff"
    },
    "ios": {
      "supportsTablet": true,
      "bundleIdentifier": "com.fiveq.ffci"
    },
    "android": {
      "adaptiveIcon": {
        "foregroundImage": "./assets/adaptive-icon.png",
        "backgroundColor": "#ffffff"
      },
      "package": "com.fiveq.ffci"
    },
    "web": {
      "favicon": "./assets/favicon.png"
    },
    "scheme": "ffci-app"
  }
}
```

## Step 9: Run on iOS Simulator

1. **Start the iOS Simulator**:
   ```bash
   # Open Xcode and start a simulator, or:
   open -a Simulator
   ```

2. **Start Expo**:
   ```bash
   npx expo start
   ```

3. **Press `i`** in the terminal to open iOS simulator, or scan the QR code with your device.

4. **Verify the app loads**:
   - You should see the splash screen briefly
   - Then the homepage should load with:
     - Site logo (if available)
     - App name
     - Menu items from the API
     - Homepage type information

## Step 10: Troubleshooting

### API Connection Issues

If you see "Failed to load data":

1. **Check API URL**: Verify `apiBaseUrl` in `lib/config.ts` matches the test site
2. **Check API Token**: Ensure the bearer token is correct. You can create your own token for development/testing purposes (see note below).
3. **Test API manually**:
   ```bash
   curl -H "Authorization: Bearer YOUR_TOKEN" \
        https://ws-ffci-copy.ddev.site/mobile-api
   ```
4. **Check network**: Ensure simulator/emulator can reach the API (may need to use your Mac's IP if testing on physical device)
5. **Create a bearer token**: You can generate your own bearer token for development. The API accepts any bearer token for testing purposes - you can use a simple string like `dev-token-123` or generate a more secure token using `openssl rand -hex 32`

### iOS Simulator Issues

If iOS simulator has problems:

1. **Reset simulator**: Device → Erase All Content and Settings
2. **Try Android emulator** instead (see Android section below)
3. **Check Xcode version**: Ensure Xcode is up to date

### Android Emulator (Alternative)

If iOS simulator doesn't work:

1. **Start Android Studio** and create/start an emulator
2. **Run Expo**: `npx expo start`
3. **Press `a`** to open Android emulator

## Step 11: Simple Maestro Test

Create a basic Maestro test to verify the homepage loads correctly.

### Install Maestro

```bash
curl -Ls "https://get.maestro.mobile.dev" | bash
```

Or on macOS:
```bash
brew tap mobile-dev-inc/tap
brew install maestro
```

### Create Test Directory

```bash
mkdir -p maestro/flows
```

### Create Basic Test: `maestro/flows/homepage-loads.yaml`

```yaml
appId: com.fiveq.ffci
---
- launchApp
- assertVisible: "FFCI"
- assertVisible: "Menu"
- takeScreenshot: homepage-loaded
```

**Note**: Adjust `appId` to match your bundle identifier, and `assertVisible` text to match what actually appears on screen (app name, menu labels, etc.).

### Run Maestro Test

```bash
# First, ensure the app is running in simulator/emulator
npx expo start

# In another terminal, run Maestro
maestro test maestro/flows/homepage-loads.yaml
```

### Expected Result

Maestro should:
1. Launch the app
2. Wait for the homepage to load
3. Verify "FFCI" text is visible
4. Verify "Menu" text is visible
5. Take a screenshot

If the test passes, you've successfully verified the basic user-facing behavior!

## Step 12: Next Steps

Once you have the homepage loading:

1. **Add Navigation**: Implement bottom tabs or drawer menu using Expo Router
2. **Add Content Pages**: Create a page detail screen that fetches and displays page content
3. **Add WebView**: Implement WebView for rendering HTML content
4. **Add Error Handling**: Improve error states and retry logic
5. **Add Loading States**: Better loading indicators
6. **Add Splash Screen**: Proper splash screen with logo
7. **Review Key Issues**: See `astro-prototype/docs/notes/key-issues-for-react-native.md` for RN-specific challenges

## Reference Documentation

- **[Mobile App Specification](mobile-app-specification.md)** - Complete requirements
- **[Mobile API Prototype Results](mobile-api-prototype-results.md)** - API structure and examples
- **[Key Issues for React Native](astro-prototype/docs/notes/key-issues-for-react-native.md)** - RN-specific challenges
- **[Internal Link Resolution](astro-prototype/docs/internal-link-resolution.md)** - How links are handled
- **[Maestro Getting Started Guide](maestro-getting-started-guide.md)** - Maestro testing documentation

## Support

If you encounter issues:

1. Check the API is accessible: `curl https://ws-ffci-copy.ddev.site/mobile-api`
2. Verify your bearer token is correct
3. Review error messages in Expo logs
4. Check Maestro test output for specific failures

For questions, contact:
- **Technical Lead**: Anthony Elliott
- **Project Manager**: Mike Kaczorowski

