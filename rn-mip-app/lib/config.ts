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
  logo?: string;
}

// For now, use a simple config object
// Later, this will load from configs/{siteId}.json
export const siteConfig: SiteConfig = {
  siteId: 'ffci',
  // Use Mac's IP address for iOS simulator (simulator can't reach localhost)
  // Port 8888 is the proxy that forwards to DDEV on localhost:55038
  // Start proxy with: node scripts/ddev-proxy.js 55038
  // Mac IP: 192.168.0.106 (update if your IP changes)
  apiBaseUrl: 'http://192.168.0.106:8888',
  apiToken: 'b92f8b5f3982b4778714ec76726e7b66d3f9c6574750d1617b5669322538c713', // Development bearer token
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

