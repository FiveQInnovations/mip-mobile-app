import { loadSiteConfig } from './config';

const config = loadSiteConfig();
const API_BASE = import.meta.env.PUBLIC_API_BASE || config.apiBaseUrl || 'https://ws-ffci-copy.ddev.site';

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

export interface PageData {
  page_type: 'content' | 'collection' | 'collection-item';
  type: string;
  title: string;
  cover: string | null;
  content?: any;
  page_content?: string;
  children?: Array<{
    uuid: string;
    type: string;
    url: string;
  }>;
  data?: {
    page_content?: string;
    content?: any;
    video?: {
      source: string;
      url?: string;
    };
    audio?: any;
  };
}

export async function getSiteData(): Promise<SiteData> {
  const res = await fetch(`${API_BASE}/mobile-api`);
  if (!res.ok) {
    throw new Error(`Failed to fetch site data: ${res.status}`);
  }
  return res.json();
}

export async function getMenu(): Promise<MenuItem[]> {
  const res = await fetch(`${API_BASE}/mobile-api/menu`);
  if (!res.ok) {
    throw new Error(`Failed to fetch menu: ${res.status}`);
  }
  return res.json();
}

export async function getPage(uuid: string): Promise<PageData> {
  const res = await fetch(`${API_BASE}/mobile-api/page/${uuid}`);
  if (!res.ok) {
    throw new Error(`Failed to fetch page: ${res.status}`);
  }
  return res.json();
}
