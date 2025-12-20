// Service Worker for PWA caching
const CACHE_NAME = 'mip-mobile-v1';
const STATIC_CACHE_NAME = 'mip-static-v1';
const API_CACHE_NAME = 'mip-api-v1';

// Assets to cache immediately on install
const STATIC_ASSETS = [
  '/',
  '/offline',
  '/favicon.svg',
  '/icons/icon-192.png',
  '/icons/icon-512.png',
];

// Install event - cache static assets
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(STATIC_CACHE_NAME).then((cache) => {
      return cache.addAll(STATIC_ASSETS).catch((err) => {
        console.warn('Failed to cache some static assets:', err);
      });
    })
  );
  self.skipWaiting();
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames
          .filter((name) => {
            return (
              name !== CACHE_NAME &&
              name !== STATIC_CACHE_NAME &&
              name !== API_CACHE_NAME
            );
          })
          .map((name) => caches.delete(name))
      );
    })
  );
  self.clients.claim();
});

// Fetch event - network-first for API, cache-first for static
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // Skip non-GET requests
  if (request.method !== 'GET') {
    return;
  }

  // Skip cross-origin requests (except our API)
  if (url.origin !== location.origin && !url.pathname.startsWith('/mobile-api')) {
    return;
  }

  // API calls - network-first with cache fallback
  if (url.pathname.startsWith('/mobile-api') || url.pathname.includes('/api/')) {
    event.respondWith(
      fetch(request)
        .then((response) => {
          // Clone response before caching
          const responseClone = response.clone();
          if (response.ok) {
            caches.open(API_CACHE_NAME).then((cache) => {
              cache.put(request, responseClone);
            });
          }
          return response;
        })
        .catch(() => {
          // Network failed, try cache
          return caches.match(request).then((cachedResponse) => {
            if (cachedResponse) {
              return cachedResponse;
            }
            // If no cache and API call, return offline response
            if (url.pathname.startsWith('/mobile-api')) {
              return new Response(
                JSON.stringify({ error: 'Offline', message: 'No network connection' }),
                {
                  status: 503,
                  headers: { 'Content-Type': 'application/json' },
                }
              );
            }
            // For other requests, return offline page
            return caches.match('/offline');
          });
        })
    );
    return;
  }

  // Static assets - cache-first
  event.respondWith(
    caches.match(request).then((cachedResponse) => {
      if (cachedResponse) {
        return cachedResponse;
      }

      return fetch(request)
        .then((response) => {
          // Only cache successful responses
          if (response.ok) {
            const responseClone = response.clone();
            caches.open(STATIC_CACHE_NAME).then((cache) => {
              cache.put(request, responseClone);
            });
          }
          return response;
        })
        .catch(() => {
          // If offline and page request, return offline page
          if (request.mode === 'navigate') {
            return caches.match('/offline');
          }
          return new Response('Offline', { status: 503 });
        });
    })
  );
});
