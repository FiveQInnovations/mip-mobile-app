import { getConfig } from './config';
import { toByteArray, fromByteArray } from 'base64-js';

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

export interface PageData {
  page_type: string;
  type: string;
  title: string;
  cover: string | null;
  content?: Record<string, unknown>;
  page_content?: string;
  children?: unknown;
  data?: {
    page_content?: string;
    content?: Record<string, unknown>;
    video?: unknown;
    audio?: unknown;
  };
  has_form?: boolean;
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

// Base64 encoder for React Native (Basic Auth)
function base64Encode(str: string): string {
  // Convert string to UTF-8 bytes, then to base64
  // TextEncoder might not be available in all React Native environments
  let utf8Bytes: Uint8Array;
  if (typeof TextEncoder !== 'undefined') {
    utf8Bytes = new TextEncoder().encode(str);
  } else {
    // Fallback: manual UTF-8 encoding
    utf8Bytes = new Uint8Array(str.length);
    for (let i = 0; i < str.length; i++) {
      utf8Bytes[i] = str.charCodeAt(i);
    }
  }
  return fromByteArray(utf8Bytes);
}

async function fetchJson<T>(url: string, label: string): Promise<T> {
  console.log('[API] Making request to:', url);
  console.log('[API] Config apiBaseUrl:', config.apiBaseUrl);
  
  // HTTP Basic Auth credentials for deployed server
  const basicAuth = base64Encode('fiveq:demo');
  
  try {
    const response = await fetch(url, {
      headers: {
        'X-API-Key': config.apiKey,
        'Authorization': `Basic ${basicAuth}`,
        'Content-Type': 'application/json',
      },
    });
    console.log('[API] Response status:', response.status, 'for', label);

    if (!response.ok) {
      throw new ApiError(
        `Failed to fetch ${label} (${response.status})`,
        response.status,
        url
      );
    }

    return response.json() as Promise<T>;
  } catch (error: any) {
    console.error('[API] Fetch error:', error.message, error);
    console.error('[API] Error details:', JSON.stringify(error, null, 2));
    throw error;
  }
}

export async function getSiteData(): Promise<SiteData> {
  const url = `${config.apiBaseUrl}/mobile-api`;
  console.log('[API] Fetching site data from:', url);
  return fetchJson<SiteData>(url, 'site data');
}

export async function getPage(uuid: string): Promise<PageData> {
  return fetchJson<PageData>(
    `${config.apiBaseUrl}/mobile-api/page/${uuid}`,
    `page ${uuid}`
  );
}

