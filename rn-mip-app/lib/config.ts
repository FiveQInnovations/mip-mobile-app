import { Platform } from 'react-native';

// Load config from JSON file
const ffciConfig = require('../configs/ffci.json');

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

// Load config from JSON file
const siteConfig: SiteConfig = {
  ...ffciConfig,
  // Runtime config additions
  iosBundle: 'com.fiveq.ffci',
  androidPackage: 'com.fiveq.ffci',
};

export function getConfig(): SiteConfig {
  return siteConfig;
}

