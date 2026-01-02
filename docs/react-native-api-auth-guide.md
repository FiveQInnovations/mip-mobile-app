# React Native Mobile API Authentication Guide

## Overview

The FFCI mobile API uses **X-API-Key header authentication**. All API requests must include the `X-API-Key` header with the API secret.

**⚠️ Important:** The API has been migrated from Bearer Token authentication. The old `Authorization: Bearer <token>` method is no longer supported. You must use `X-API-Key` header instead.

---

## Configuration

### API Base URL

**Development (DDEV):**
```
https://ws-ffci.ddev.site
```

**Production:**
```
https://ffci.org
```
*(Update this when production URL is confirmed)*

### API Secret

```
777359235aecc10fdfb144041dfdacfc80ca0751c7bed7b14c96f935456fc4ce
```

**⚠️ Security Note:** Store this securely in your app's configuration (e.g., environment variables, secure storage). Never commit it to version control or expose it in client-side code if possible.

---

## Authentication Method

### Header Format

All API requests must include:

```
X-API-Key: 777359235aecc10fdfb144041dfdacfc80ca0751c7bed7b14c96f935456fc4ce
```

### Response Codes

- **200 OK** - Request successful
- **401 Unauthorized** - Missing or invalid API key
- **404 Not Found** - Endpoint or resource not found

---

## Available Endpoints

### 1. Get Site Data and Menu

**Endpoint:** `GET /mobile-api`

**Description:** Returns both menu and site configuration data in a single request.

**Request:**
```javascript
GET /mobile-api
Headers:
  X-API-Key: 777359235aecc10fdfb144041dfdacfc80ca0751c7bed7b14c96f935456fc4ce
```

**Response:**
```json
{
  "menu": [
    {
      "label": "Resources",
      "page": {
        "uuid": "uezb3178BtP3oGuU",
        "type": "article-collection",
        "url": "/resources"
      }
    },
    {
      "label": "Chapters",
      "page": {
        "uuid": "pik8ysClOFGyllBY",
        "type": "chapter-collection",
        "url": "/chapters"
      }
    }
  ],
  "site_data": {
    "title": "FFCI",
    "app_name": "FFCI",
    "logo": "https://cdn.example.com/logo.png",
    "social": [
      {
        "platform": "facebook",
        "url": "https://facebook.com/ffci"
      }
    ],
    "homepage_type": "content",
    "homepage_content": "nD0WLvWvzANPxq4m",
    "homepage_collection": null
  }
}
```

---

### 2. Get Menu Only

**Endpoint:** `GET /mobile-api/menu`

**Description:** Returns only the menu structure.

**Request:**
```javascript
GET /mobile-api/menu
Headers:
  X-API-Key: 777359235aecc10fdfb144041dfdacfc80ca0751c7bed7b14c96f935456fc4ce
```

**Response:**
```json
[
  {
    "label": "Resources",
    "page": {
      "uuid": "uezb3178BtP3oGuU",
      "type": "article-collection",
      "url": "/resources"
    }
  }
]
```

---

### 3. Get Page Data

**Endpoint:** `GET /mobile-api/page/{uuid}`

**Description:** Returns detailed data for a specific page by UUID.

**Request:**
```javascript
GET /mobile-api/page/uezb3178BtP3oGuU
Headers:
  X-API-Key: 777359235aecc10fdfb144041dfdacfc80ca0751c7bed7b14c96f935456fc4ce
```

**Response:** *(Varies by page type - see API documentation for specific page structures)*

---

### 4. KQL Query Endpoint

**Endpoint:** `GET /mobile-api/kql` or `POST /mobile-api/kql`

**Description:** Execute Kirby Query Language (KQL) queries.

**Request (POST):**
```javascript
POST /mobile-api/kql
Headers:
  X-API-Key: 777359235aecc10fdfb144041dfdacfc80ca0751c7bed7b14c96f935456fc4ce
  X-Language: en (optional, for multilanguage sites)
Content-Type: application/json

Body:
{
  "query": "site.children"
}
```

**Request (GET with base64 encoded query):**
```javascript
GET /mobile-api/kql?q=<base64_encoded_query>
Headers:
  X-API-Key: 777359235aecc10fdfb144041dfdacfc80ca0751c7bed7b14c96f935456fc4ce
  X-Language: en (optional)
```

---

## React Native Implementation

### Basic API Client Example

```typescript
// api/config.ts
export const API_CONFIG = {
  baseURL: __DEV__ 
    ? 'https://ws-ffci.ddev.site' 
    : 'https://ffci.org',
  apiKey: '777359235aecc10fdfb144041dfdacfc80ca0751c7bed7b14c96f935456fc4ce',
};

// api/client.ts
import { API_CONFIG } from './config';

class ApiClient {
  private baseURL: string;
  private apiKey: string;

  constructor() {
    this.baseURL = API_CONFIG.baseURL;
    this.apiKey = API_CONFIG.apiKey;
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const url = `${this.baseURL}${endpoint}`;
    
    const headers = {
      'X-API-Key': this.apiKey,
      'Content-Type': 'application/json',
      ...options.headers,
    };

    const response = await fetch(url, {
      ...options,
      headers,
    });

    if (!response.ok) {
      if (response.status === 401) {
        throw new Error('Unauthorized: Invalid or missing API key');
      }
      throw new Error(`API Error: ${response.status} ${response.statusText}`);
    }

    return response.json();
  }

  // Get site data and menu
  async getSiteData() {
    return this.request<{
      menu: Array<{
        label: string;
        page: {
          uuid: string;
          type: string;
          url: string;
        };
      }>;
      site_data: {
        title: string;
        app_name: string | null;
        logo: string | null;
        social: Array<{
          platform: string;
          url: string;
        }>;
        homepage_type: string | null;
        homepage_content: string | null;
        homepage_collection: string | null;
      };
    }>('/mobile-api');
  }

  // Get menu only
  async getMenu() {
    return this.request<Array<{
      label: string;
      page: {
        uuid: string;
        type: string;
        url: string;
      };
    }>>('/mobile-api/menu');
  }

  // Get page data
  async getPage(uuid: string) {
    return this.request(`/mobile-api/page/${uuid}`);
  }

  // Execute KQL query
  async kqlQuery(query: any, language?: string) {
    const headers: Record<string, string> = {};
    if (language) {
      headers['X-Language'] = language;
    }

    return this.request('/mobile-api/kql', {
      method: 'POST',
      headers,
      body: JSON.stringify(query),
    });
  }
}

export const apiClient = new ApiClient();
```

---

### Usage Example

```typescript
// App.tsx or your component
import { useEffect, useState } from 'react';
import { apiClient } from './api/client';

function App() {
  const [siteData, setSiteData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadSiteData();
  }, []);

  const loadSiteData = async () => {
    try {
      setLoading(true);
      const data = await apiClient.getSiteData();
      setSiteData(data);
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load data');
      console.error('API Error:', err);
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <Text>Loading...</Text>;
  if (error) return <Text>Error: {error}</Text>;
  if (!siteData) return null;

  return (
    <View>
      <Text>Welcome to {siteData.site_data.app_name}</Text>
      {/* Render menu, etc. */}
    </View>
  );
}
```

---

### Using Axios (Alternative)

If you prefer Axios:

```typescript
import axios from 'axios';

const apiClient = axios.create({
  baseURL: API_CONFIG.baseURL,
  headers: {
    'X-API-Key': API_CONFIG.apiKey,
    'Content-Type': 'application/json',
  },
});

// Add response interceptor for error handling
apiClient.interceptors.response.use(
  (response) => response.data,
  (error) => {
    if (error.response?.status === 401) {
      throw new Error('Unauthorized: Invalid or missing API key');
    }
    throw error;
  }
);

// Usage
const siteData = await apiClient.get('/mobile-api');
const menu = await apiClient.get('/mobile-api/menu');
const page = await apiClient.get(`/mobile-api/page/${uuid}`);
```

---

## Migration Notes

### What Changed

- **Old Method:** `Authorization: Bearer <token>`
- **New Method:** `X-API-Key: <api_secret>`

### Required Changes

1. **Update all API requests** to use `X-API-Key` header instead of `Authorization: Bearer`
2. **Remove Bearer token logic** from your authentication code
3. **Update error handling** - 401 responses now indicate missing/invalid API key

### Testing

Test your implementation with:

```bash
# Should return 401 (no auth)
curl https://ws-ffci.ddev.site/mobile-api

# Should return 401 (wrong key)
curl -H "X-API-Key: wrong-key" https://ws-ffci.ddev.site/mobile-api

# Should return 200 with JSON data
curl -H "X-API-Key: 777359235aecc10fdfb144041dfdacfc80ca0751c7bed7b14c96f935456fc4ce" \
  https://ws-ffci.ddev.site/mobile-api
```

---

## Error Handling

### Common Errors

**401 Unauthorized:**
- Missing `X-API-Key` header
- Invalid API key value
- API key mismatch

**404 Not Found:**
- Invalid endpoint URL
- Page UUID doesn't exist

**Network Errors:**
- No internet connection
- Server unreachable
- Timeout

### Recommended Error Handling

```typescript
try {
  const data = await apiClient.getSiteData();
  // Handle success
} catch (error) {
  if (error.message.includes('401') || error.message.includes('Unauthorized')) {
    // Handle authentication error
    console.error('Authentication failed - check API key');
  } else if (error.message.includes('Network')) {
    // Handle network error
    console.error('Network error - check connection');
  } else {
    // Handle other errors
    console.error('API error:', error);
  }
}
```

---

## Security Best Practices

1. **Store API key securely** - Use environment variables or secure storage
2. **Never log API keys** - Avoid console.log with sensitive data
3. **Use HTTPS only** - Never make requests over HTTP
4. **Validate responses** - Always validate API response structure
5. **Handle errors gracefully** - Don't expose API keys in error messages

---

## Support

If you encounter issues:

1. Verify the API key is correct
2. Check that the `X-API-Key` header is being sent (use network inspector)
3. Test endpoints with curl to isolate client vs server issues
4. Check server logs for authentication failures

---

## Quick Reference

| Endpoint | Method | Auth Required | Description |
|----------|--------|----------------|-------------|
| `/mobile-api` | GET | Yes | Get menu + site data |
| `/mobile-api/menu` | GET | Yes | Get menu only |
| `/mobile-api/page/{uuid}` | GET | Yes | Get page data |
| `/mobile-api/kql` | GET/POST | Yes | Execute KQL query |

**All endpoints require:** `X-API-Key: 777359235aecc10fdfb144041dfdacfc80ca0751c7bed7b14c96f935456fc4ce`

