import type { APIRoute } from 'astro';
import { loadSiteConfig } from '../lib/config';

export const GET: APIRoute = () => {
  const config = loadSiteConfig();
  
  const manifest = {
    name: config.appName,
    short_name: config.appName,
    description: `${config.appName} - Mobile Web App`,
    start_url: '/',
    scope: '/',
    display: 'standalone',
    background_color: config.backgroundColor || '#ffffff',
    theme_color: config.primaryColor || '#2563eb',
    orientation: 'portrait',
    icons: [
      {
        src: '/icons/icon-192.png',
        sizes: '192x192',
        type: 'image/png',
        purpose: 'any maskable'
      },
      {
        src: '/icons/icon-512.png',
        sizes: '512x512',
        type: 'image/png',
        purpose: 'any maskable'
      }
    ]
  };

  return new Response(JSON.stringify(manifest), {
    headers: {
      'Content-Type': 'application/manifest+json',
    },
  });
};
