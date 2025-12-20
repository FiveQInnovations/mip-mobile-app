import { loadSiteConfig } from './config';

const config = loadSiteConfig();
const API_BASE =
  import.meta.env.PUBLIC_API_BASE || config.apiBaseUrl || 'https://ws-ffci-copy.ddev.site';

export interface MenuItem {
  label: string;
  page: {
    uuid: string;
    type: string;
    url: string;
  };
}

export interface SiteData {
  menu: MenuItem[];
  site_data: {
    title: string;
    social: any[];
    logo: string;
    app_name: string;
    homepage_type?: string;
    homepage_content?: string;
    homepage_collection?: string;
  };
}

export interface CollectionChild {
  uuid: string;
  type: string;
  url: string;
  title?: string;
  cover?: string | null;
  episode?: number;
  series?: string;
  date?: string;
}

export type VideoSource = 'youtube' | 'vimeo' | 'url';

export interface VideoData {
  source: VideoSource;
  url?: string;
  id?: string;
  title?: string;
}

export interface AudioData {
  url?: string;
  duration?: number;
  artwork?: string;
  title?: string;
}

export interface PageData {
  page_type: 'content' | 'collection' | 'collection-item';
  type: string;
  title: string;
  cover: string | null;
  content?: any;
  page_content?: string;
  children?: CollectionChild[];
  data?: {
    page_content?: string;
    content?: any;
    video?: VideoData;
    audio?: AudioData;
  };
  has_form?: boolean;
}

export class ApiError extends Error {
  status: number;
  url: string;

  constructor(message: string, status: number, url: string) {
    super(message);
    this.status = status;
    this.url = url;
  }
}

type CacheEntry<T> = {
  data: T;
  expiresAt: number;
};

const cache = new Map<string, CacheEntry<unknown>>();
const SITE_TTL = 1000 * 60 * 5; // 5 minutes
const MENU_TTL = 1000 * 60 * 10; // 10 minutes
const PAGE_TTL = 1000 * 60; // 1 minute

function setCache<T>(key: string, data: T, ttl: number) {
  cache.set(key, { data, expiresAt: Date.now() + ttl });
}

function getFresh<T>(key: string): T | null {
  const entry = cache.get(key) as CacheEntry<T> | undefined;
  if (!entry) return null;
  if (entry.expiresAt < Date.now()) return null;
  return entry.data;
}

async function fetchJson<T>(url: string, label: string): Promise<T> {
  const res = await fetch(url);
  if (!res.ok) {
    throw new ApiError(`Failed to fetch ${label}`, res.status, url);
  }
  return res.json() as Promise<T>;
}

async function fetchWithCache<T>(key: string, ttl: number, fetcher: () => Promise<T>): Promise<T> {
  const cached = getFresh<T>(key);
  if (cached) {
    return cached;
  }

  const staleEntry = cache.get(key) as CacheEntry<T> | undefined;
  if (staleEntry) {
    // Return stale while revalidating
    void fetcher()
      .then((data) => setCache(key, data, ttl))
      .catch((err) => console.warn('Revalidate failed for', key, err));
    return staleEntry.data;
  }

  const data = await fetcher();
  setCache(key, data, ttl);
  return data;
}

function buildUrl(path: string): string {
  return `${API_BASE}${path}`;
}

export function getSiteData(): Promise<SiteData> {
  return fetchWithCache<SiteData>('site', SITE_TTL, () =>
    fetchJson<SiteData>(buildUrl('/mobile-api'), 'site data')
  );
}

export function getMenu(): Promise<MenuItem[]> {
  return fetchWithCache<MenuItem[]>('menu', MENU_TTL, () =>
    fetchJson<MenuItem[]>(buildUrl('/mobile-api/menu'), 'menu')
  );
}

export function getPage(uuid: string): Promise<PageData> {
  return fetchWithCache<PageData>(`page-${uuid}`, PAGE_TTL, () =>
    fetchJson<PageData>(buildUrl(`/mobile-api/page/${uuid}`), `page ${uuid}`)
  );
}
