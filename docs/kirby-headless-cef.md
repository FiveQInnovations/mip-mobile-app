### Kirby Headless in `ws-cef-curriculum` — Overview and Prototype

This site runs Kirby as a headless CMS behind a JSON API, consumed by a separate React app in `sites/ws-cef-curriculum/curriculum-app`.

- **API base**: `/cef-api/...`
- **Auth**: JWT Bearer token
- **Data querying**: Kirby KQL via `/cef-api/kql`
- **Frontend**: React/Vite app calling the API with `KIRBY_PATH` set to the API base

## Key implementation points

- **KQL enabled** with sensitive classes blocked (example):
```php
// site/config/config.php
return [
  'kql' => [
    'classes' => [
      'blocked' => [
        'Kirby\\Cms\\User',
      ],
    ],
  ],
];
```

- **CORS configured** to support cross-origin fetching by the frontend:
```php
// site/config/config.php
return [
  'cors' => [
    'allowOrigin' => ['KIRBY_HEADLESS_ALLOW_ORIGIN' => '*'],
    'allowMethods' => ['KIRBY_HEADLESS_ALLOW_METHODS' => 'GET, POST, OPTIONS'],
    'allowHeaders' => ['KIRBY_HEADLESS_ALLOW_HEADERS' => '*'],
    'maxAge' => ['KIRBY_HEADLESS_MAX_AGE' => '7200'],
  ],
];
```

- **JSON API routes** (login, KQL, users, clubs, meetings, etc.) are provided by the curriculum plugin routes:
  - `fiveq-plugins/wsp-cef-curriculum/src/extensions/routes.php`
  - Example KQL route (simplified):
```php
[
  'pattern' => 'cef-api/kql',
  'method'  => 'GET|POST',
  'action'  => Api::createHandler(
    Api::authenticateFn($kirby),
    function (array $context, array $args) use (&$kirby) {
      $input = $kirby->request()->method() === 'POST'
        ? $kirby->request()->body()->toArray()
        : ($kirby->request()->query()->get('q')
          ? json_decode(base64_decode($kirby->request()->query()->get('q')), true)
          : $kirby->request()->query()->toArray());

      $data = Kirby\Kql\Kql::run($input);
      return Api::createResponse(200, $data);
    }
  ),
],
```

- **Frontend requests** prepend `KIRBY_PATH` and include the Bearer token:
```ts
// sites/ws-cef-curriculum/curriculum-app/src/ducks/common.ts
const resp = await fetch(process.env.KIRBY_PATH + path, {
  headers: { Authorization: 'Bearer ' + token, 'Content-Type': 'application/json' },
  ...opts,
});

export const kql = async (query: any) => {
  const b64 = btoa(JSON.stringify(query));
  return request('/kql?q=' + b64, { method: 'GET' });
};
```

## Run a local prototype

### 1) Start Kirby (backend)
- Use your standard local stack (DDEV recommended in this repo). Ensure KQL and the curriculum plugin are active.

### 2) Start the React app (frontend)
- Create `.env` in `sites/ws-cef-curriculum/curriculum-app`:
```env
KIRBY_PATH=http://localhost:8888/cef-api
```
- Then:
```bash
cd sites/ws-cef-curriculum/curriculum-app
npm install
npm run dev
```

### 3) Authenticate and query
- Login (get token):
```bash
curl -s -X POST http://localhost:8888/cef-api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"you@example.com","password":"yourpass"}'
```
- Run a KQL query with the token (replace `BASE64_JWT_TOKEN`):
```bash
Q=$(printf '%s' '{"query":"site","select":{"title":true}}' | base64)
curl -s "http://localhost:8888/cef-api/kql?q=$Q" \
  -H "Authorization: Bearer BASE64_JWT_TOKEN"
```

## Add your own endpoint (prototype)

Add a simple JSON route in the curriculum plugin routes file or a new plugin:
```php
[
  'pattern' => 'cef-api/hello',
  'method'  => 'GET',
  'auth'    => 'none',
  'action'  => fn () => Api::createResponse(200, ['message' => 'Hello from Kirby headless!']),
],
```
Test it:
```bash
curl -s http://localhost:8888/cef-api/hello
```

## Tips and security considerations

- **KIRBY_PATH**: Point it at the API base (include `/cef-api`) so frontend helpers can call "/kql" etc.
- **KQL locking**: Keep `Kirby\Cms\User` (and other sensitive classes) blocked.
- **CORS**: Ensure your allowed origins/methods/headers match your deployment.
- **Localization**: Send `X-Language` header to query different languages when `multilang()` is enabled.
- **Secrets**: Do not commit raw secrets in docs. Use environment variables or secret management in production.

## Selected endpoints

- `POST /cef-api/login` → returns `{ token: base64(jwt) }`
- `GET|POST /cef-api/kql` → KQL queries (Bearer token required)
- Users: `/cef-api/users/*` (get/me, add, update, delete, restore, etc.)
- Clubs: `/cef-api/clubs/*` (add/edit/delete, membership)
- Meetings: `/cef-api/meetings/*` (create/update/list/assignments)
- Public example: `GET /cef-api/party-club/:sessionId`
