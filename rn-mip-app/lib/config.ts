import { Platform } from 'react-native';

// Load config from JSON file
const ffciConfig = require('../configs/ffci.json');
const ffciLocalConfig = require('../configs/ffci-local.json');

export interface SiteConfig {
  siteId: string;
  apiBaseUrl: string;
  apiKey: string;
  appName: string;
  appSlug: string;
  primaryColor: string;
  secondaryColor: string;
  textColor?: string;
  backgroundColor?: string;
  headerStyle?: 'light' | 'dark';
  iosBundle: string;
  androidPackage: string;
  logo?: string;
  homepageType?: 'content' | 'collection' | 'navigation' | 'action-hub';
}

// Use local DDEV API for web development only
// iOS and Android use production API (https://ffci.fiveq.dev)
const baseConfig = Platform.OS === 'web' ? ffciLocalConfig : ffciConfig;

// Load config from JSON file
const siteConfig: SiteConfig = {
  ...baseConfig,
  // Runtime config additions
  iosBundle: 'com.fiveq.ffci',
  androidPackage: 'com.fiveq.ffci',
};

export function getConfig(): SiteConfig {
  return siteConfig;
}

