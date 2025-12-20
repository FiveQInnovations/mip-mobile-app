import { loadSiteConfig } from './config';

const config = loadSiteConfig();
const API_BASE =
  import.meta.env.PUBLIC_API_BASE || config.apiBaseUrl || 'https://ws-ffci-copy.ddev.site';

export type HomepageType = 'navigation' | 'content' | 'collection';

export interface SocialLink {
  url: string;
  label?: string;
  platform?: string;
}

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
  social: SocialLink[];
  logo: string | null;
  app_name: string;
  homepage_type?: HomepageType;
  homepage_content?: string;
  homepage_collection?: string;
}

export interface SiteData {
  menu: MenuItem[];
  site_data: SiteMeta;
  url_mappings?: Record<string, string>;
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

export type VideoSource = 'youtube' | 'vimeo' | 'url' | 'unknown';

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

export type PageType = 'content' | 'collection' | 'collection-item' | string;

export interface PageData {
  page_type: PageType;
  type: string;
  title: string;
  cover: string | null;
  content?: Record<string, unknown>;
  page_content?: string;
  children?: CollectionChild[];
  data?: {
    page_content?: string;
    content?: Record<string, unknown>;
    video?: VideoData;
    audio?: AudioData;
  };
  has_form?: boolean;
}

export class ApiError extends Error {
  status: number;
  url: string;
  details?: unknown;

  constructor(message: string, status: number, url: string, details?: unknown) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
    this.url = url;
    this.details = details;
  }
}

type CacheEntry<T> = {
  data: T;
  expiresAt: number;
};

const memoryCache = new Map<string, CacheEntry<unknown>>();
const SITE_TTL = 1000 * 60 * 5; // 5 minutes
const MENU_TTL = 1000 * 60 * 10; // 10 minutes
const PAGE_TTL = 1000 * 60; // 1 minute
const CACHE_PREFIX = 'api-cache:';

function isBrowser(): boolean {
  return typeof window !== 'undefined';
}

function getStorageKey(key: string): string {
  return `${CACHE_PREFIX}${key}`;
}

function persistToStorage<T>(key: string, entry: CacheEntry<T>) {
  if (!isBrowser()) return;
  try {
    window.localStorage.setItem(getStorageKey(key), JSON.stringify(entry));
  } catch (err) {
    console.warn('Failed to persist cache', key, err);
  }
}

function readFromStorage<T>(key: string): CacheEntry<T> | null {
  if (!isBrowser()) return null;
  try {
    const raw = window.localStorage.getItem(getStorageKey(key));
    if (!raw) return null;
    return JSON.parse(raw) as CacheEntry<T>;
  } catch (err) {
    console.warn('Failed to read cache', key, err);
    return null;
  }
}

function setCache<T>(key: string, data: T, ttl: number) {
  const entry: CacheEntry<T> = { data, expiresAt: Date.now() + ttl };
  memoryCache.set(key, entry);
  persistToStorage(key, entry);
}

function getEntry<T>(key: string): CacheEntry<T> | null {
  const memoryEntry = memoryCache.get(key) as CacheEntry<T> | undefined;
  if (memoryEntry) {
    return memoryEntry;
  }

  const storedEntry = readFromStorage<T>(key);
  if (storedEntry) {
    memoryCache.set(key, storedEntry);
    return storedEntry;
  }

  return null;
}

function getFresh<T>(key: string): T | null {
  const entry = getEntry<T>(key);
  if (!entry) return null;
  if (entry.expiresAt < Date.now()) return null;
  return entry.data;
}

function getStale<T>(key: string): T | null {
  const entry = getEntry<T>(key);
  return entry ? entry.data : null;
}

function normalizeVideo(video?: Partial<VideoData>): VideoData | undefined {
  if (!video) return undefined;
  const url = video.url;

  if (video.source === 'youtube' || video.source === 'vimeo') {
    return {
      source: video.source,
      url,
      id: video.id,
      title: video.title,
    };
  }

  if (url) {
    const ytMatch = url.match(
      /(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([\w-]{11})/
    );
    if (ytMatch) {
      return {
        source: 'youtube',
        id: ytMatch[1],
        url: `https://www.youtube.com/embed/${ytMatch[1]}`,
        title: video.title,
      };
    }

    const vimeoMatch = url.match(/vimeo\.com\/(\d+)/);
    if (vimeoMatch) {
      return {
        source: 'vimeo',
        id: vimeoMatch[1],
        url: `https://player.vimeo.com/video/${vimeoMatch[1]}`,
        title: video.title,
      };
    }

    return {
      source: video.source ?? 'url',
      url,
      title: video.title,
    };
  }

  return { source: 'unknown', title: video.title };
}

function normalizePageData(raw: PageData): PageData {
  // Handle children as either array or object
  let normalizedChildren: CollectionChild[] | undefined;
  
  if (raw.children) {
    if (Array.isArray(raw.children)) {
      // Already an array, normalize it
      normalizedChildren = raw.children.map((child) => ({
        ...child,
        cover: child.cover ?? null,
      }));
    } else if (typeof raw.children === 'object') {
      // Convert object to array of values
      normalizedChildren = Object.values(raw.children).map((child) => ({
        ...child,
        cover: child.cover ?? null,
      }));
    }
  }

  return {
    ...raw,
    cover: raw.cover ?? null,
    children: normalizedChildren,
    data: raw.data
      ? {
          ...raw.data,
          video: normalizeVideo(raw.data.video),
          audio: raw.data.audio ? { ...raw.data.audio } : undefined,
        }
      : undefined,
  };
}

async function fetchJson<T>(url: string, label: string): Promise<T> {
  try {
    const res = await fetch(url);

    if (!res.ok) {
      let errorBody: unknown = null;
      try {
        errorBody = await res.json();
      } catch {
        // ignore JSON parse errors for non-JSON responses
      }

      throw new ApiError(
        `Failed to fetch ${label} (${res.status})`,
        res.status,
        url,
        errorBody
      );
    }

    return res.json() as Promise<T>;
  } catch (err) {
    if (err instanceof ApiError) {
      throw err;
    }

    const message = err instanceof Error ? err.message : 'Unknown network error';
    throw new ApiError(`Failed to fetch ${label}: ${message}`, 0, url, err);
  }
}

async function fetchWithCache<T>(
  key: string,
  ttl: number,
  fetcher: () => Promise<T>
): Promise<T> {
  const cached = getFresh<T>(key);
  if (cached) {
    return cached;
  }

  const staleEntry = getStale<T>(key);
  if (staleEntry) {
    void fetcher()
      .then((data) => setCache(key, data, ttl))
      .catch((err) => console.warn('Revalidate failed for', key, err));
    return staleEntry;
  }

  const data = await fetcher();
  setCache(key, data, ttl);
  return data;
}

function buildUrl(path: string): string {
  return `${API_BASE}${path}`;
}

export function clearApiCache(key?: string) {
  if (key) {
    memoryCache.delete(key);
    if (isBrowser()) {
      window.localStorage.removeItem(getStorageKey(key));
    }
    return;
  }

  memoryCache.clear();
  if (isBrowser()) {
    const keysToClear: string[] = [];
    for (let i = 0; i < window.localStorage.length; i++) {
      const k = window.localStorage.key(i);
      if (k && k.startsWith(CACHE_PREFIX)) {
        keysToClear.push(k);
      }
    }
    keysToClear.forEach((k) => window.localStorage.removeItem(k));
  }
}

export function expireCacheEntryForTesting(key: string) {
  const entry = memoryCache.get(key);
  if (entry) {
    memoryCache.set(key, { ...entry, expiresAt: Date.now() - 1000 });
  }

  if (isBrowser()) {
    const storageKey = getStorageKey(key);
    const raw = window.localStorage.getItem(storageKey);
    if (raw) {
      try {
        const parsed = JSON.parse(raw) as CacheEntry<unknown>;
        parsed.expiresAt = Date.now() - 1000;
        window.localStorage.setItem(storageKey, JSON.stringify(parsed));
      } catch {
        // ignore parse errors in tests
      }
    }
  }
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
  return fetchWithCache<PageData>(`page-${uuid}`, PAGE_TTL, async () => {
    const data = await fetchJson<PageData>(
      buildUrl(`/mobile-api/page/${uuid}`),
      `page ${uuid}`
    );
    return normalizePageData(data);
  });
}

declare global {
  interface Window {
    __mipApi?: {
      getSiteData: typeof getSiteData;
      getMenu: typeof getMenu;
      getPage: typeof getPage;
      clearApiCache: typeof clearApiCache;
      expireCacheEntryForTesting: typeof expireCacheEntryForTesting;
      ApiError: typeof ApiError;
    };
  }
}

if (isBrowser()) {
  window.__mipApi = {
    getSiteData,
    getMenu,
    getPage,
    clearApiCache,
    expireCacheEntryForTesting,
    ApiError,
  };
}
