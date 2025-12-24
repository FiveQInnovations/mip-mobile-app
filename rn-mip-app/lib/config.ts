import { Platform } from 'react-native';

// Load config from JSON file
const ffciConfig = require('../configs/ffci.json');

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
  logo?: string;
  homepageType?: 'content' | 'collection' | 'navigation' | 'action-hub';
}

// Load config from JSON file
// For development, override apiBaseUrl to use proxy
const siteConfig: SiteConfig = {
  ...ffciConfig,
  // Development overrides
  // Use Mac's IP address for iOS simulator (simulator can't reach localhost)
  // Port 8888 is the proxy that forwards to DDEV on localhost
  // Start proxy with: node scripts/ddev-proxy.js [DDEV_PORT]
  // Mac IP: 192.168.0.106 (update if your IP changes)
  apiBaseUrl: 'http://192.168.0.106:8888',
  apiToken: 'b92f8b5f3982b4778714ec76726e7b66d3f9c6574750d1617b5669322538c713', // Development bearer token
  iosBundle: 'com.fiveq.ffci',
  androidPackage: 'com.fiveq.ffci',
};

export function getConfig(): SiteConfig {
  return siteConfig;
}

