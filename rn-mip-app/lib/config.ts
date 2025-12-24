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
  apiBaseUrl: 'https://ws-ffci-copy.ddev.site',
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

