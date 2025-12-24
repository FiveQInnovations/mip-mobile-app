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

async function fetchJson<T>(url: string, label: string): Promise<T> {
  console.log('[API] Making request to:', url);
  console.log('[API] Config apiBaseUrl:', config.apiBaseUrl);
  try {
    const response = await fetch(url, {
      headers: {
        'Authorization': `Bearer ${config.apiToken}`,
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

