import type { HomepageType } from './api';

export type HeaderStyle = 'light' | 'dark';

export interface SiteConfig {
  siteId: string;
  apiBaseUrl: string;
  appName: string;
  appSlug: string;
  primaryColor?: string;
  secondaryColor?: string;
  textColor?: string;
  backgroundColor?: string;
  headerStyle?: HeaderStyle;
  logo?: string;
  homepageType?: HomepageType;
}

const DEFAULT_CONFIG: SiteConfig = {
  siteId: 'template',
  apiBaseUrl: 'https://ws-ffci-copy.ddev.site',
  appName: 'Mobile Template',
  appSlug: 'mobile-template',
  primaryColor: '#2563eb',
  secondaryColor: '#0ea5e9',
  textColor: '#0f172a',
  backgroundColor: '#ffffff',
  headerStyle: 'light',
  logo: '/favicon.svg',
};

const configModules = import.meta.glob('../../configs/*.json', { eager: true });

function normalizeKey(filePath: string): string {
  const parts = filePath.split('/');
  const file = parts[parts.length - 1] || '';
  return file.replace('.json', '');
}

function getConfigById(siteId: string): Partial<SiteConfig> | null {
  for (const [path, mod] of Object.entries(configModules)) {
    if (normalizeKey(path) === siteId) {
      // Glob imports return the JSON object on `default`
      const data = (mod as { default?: Partial<SiteConfig> })?.default || (mod as Partial<SiteConfig>);
      return data;
    }
  }
  return null;
}

export function loadSiteConfig(siteId?: string): SiteConfig {
  const resolvedId = siteId || import.meta.env.PUBLIC_SITE_ID || DEFAULT_CONFIG.siteId;
  const selected = getConfigById(resolvedId);
  const fallback = getConfigById(DEFAULT_CONFIG.siteId);

  return {
    ...DEFAULT_CONFIG,
    ...fallback,
    ...selected,
    siteId: resolvedId,
  };
}

export function getThemeVariables(config: SiteConfig): Record<string, string> {
  return {
    '--color-primary': config.primaryColor || DEFAULT_CONFIG.primaryColor!,
    '--color-secondary': config.secondaryColor || DEFAULT_CONFIG.secondaryColor!,
    '--color-text': config.textColor || DEFAULT_CONFIG.textColor!,
    '--color-background': config.backgroundColor || DEFAULT_CONFIG.backgroundColor!,
    '--color-header-text': config.headerStyle === 'dark' ? '#ffffff' : config.textColor || DEFAULT_CONFIG.textColor!,
  };
}

export function toInlineStyle(themeVars: Record<string, string>): string {
  return Object.entries(themeVars)
    .map(([key, value]) => `${key}: ${value}`)
    .join('; ');
}
