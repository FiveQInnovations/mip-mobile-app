---
status: done
area: ios-mip-app
phase: core
created: 2026-03-06
---

# Fix iOS Crash: homepage_featured Returns Numeric-Keyed Object

## Context

The `wsp-mobile` API returns `homepage_featured` as a JSON object with numeric
string keys (`{"0": {...}, "1": {...}}`) instead of a proper JSON array. This
happens when PHP's `json_encode` receives a non-zero-indexed array — it
serializes it as an object rather than an array.

The Android app was hitting this crash and was fixed in commit
`Fix homepage_featured JSON parsing crash (Android)` by adding a
`FlexibleListAdapter` that handles both array and numeric-keyed-object formats.

The iOS app has the same vulnerability: `SiteMeta.homepageFeatured` is declared
as `[HomepageFeatured]?` and Swift's `JSONDecoder` will throw a type mismatch
error if it encounters an object where it expects an array.

## Goals

1. Add a custom `init(from:)` on `SiteMeta` (or a custom `KeyedDecodingContainer`
   extension) that handles `homepage_featured` as either an array or a
   numeric-keyed object
2. Ensure the fix is silent — if decoding fails for `homepage_featured`, treat it
   as `nil` rather than crashing the whole site data load

## Acceptance Criteria

- [ ] App loads home screen without error when `homepage_featured` is a
      numeric-keyed JSON object
- [ ] Featured cards still render correctly
- [ ] If `homepage_featured` is a proper array, behavior is unchanged
- [ ] If `homepage_featured` is null or missing, behavior is unchanged

## Notes

- The Android fix is in `android-mip-app/.../FlexibleListAdapter.kt` — the same
  logic applies: parse the object keys as integers, sort them, and extract values
  as an ordered list
- Swift equivalent: custom `init(from decoder: Decoder)` on `SiteMeta` that
  catches the `DecodingError.typeMismatch` for `homepageFeatured` and falls back
  to decoding as `[String: HomepageFeatured]`, then sorts by key

## References

- Android fix: `android-mip-app/app/src/main/java/com/fiveq/ffci/data/api/FlexibleListAdapter.kt`
- iOS model: `ios-mip-app/FFCI/API/ApiModels.swift` (`SiteMeta` struct)
- iOS API client: `ios-mip-app/FFCI/API/MipApiClient.swift`
- Related Android ticket: `tickets/230-android-config-infrastructure-complete.md`

---

## Research Findings (Scouted)

### Cross-Platform Reference (Android)
- `android-mip-app/app/src/main/java/com/fiveq/ffci/data/api/FlexibleListAdapter.kt`:
  - `fromJson()` (`L37-L65`) accepts `null`, array, or object (`BEGIN_OBJECT`) and returns `null` for unsupported token types.
  - Object branch (`L49-L63`) parses keys with `toIntOrNull()`, sorts numerically, and returns ordered values.
- `android-mip-app/app/src/main/java/com/fiveq/ffci/data/api/ApiModels.kt`:
  - `SiteMeta.homepageFeatured` is annotated with `@FlexibleList` (`L41-L47`).
- `android-mip-app/app/src/main/java/com/fiveq/ffci/data/api/MipApiClient.kt`:
  - `FlexibleListAdapterFactory` is registered in Moshi builder (`L31-L34`), so handling is automatic at decode time.

### Current Implementation Analysis
- `ios-mip-app/FFCI/API/ApiModels.swift`:
  - `SiteMeta.homepageFeatured` is currently typed as `[HomepageFeatured]?` (`L65-L78`) with synthesized `Codable`.
  - There is no custom `init(from:)` in this file, so type mismatch at `homepage_featured` throws during whole `SiteData` decode.
- `ios-mip-app/FFCI/API/MipApiClient.swift`:
  - `getSiteData()` decodes `SiteData` directly with `JSONDecoder` (`L55-L80`) and rethrows decoding failures as `ApiError.decodingError` (`L81-L84`).
- `ios-mip-app/FFCI/ContentView.swift`:
  - Decode failure bubbles to `AppState.loadSiteData()` (`L39-L57`), which sets `error` and shows `ErrorView` instead of home content (`L20-L23`).
- `ios-mip-app/FFCI/Views/HomeView.swift`:
  - Rendering already safely handles `homepageFeatured == nil` / empty (`L33-L35`, `L46`), so no UI logic change is required.

### Implementation Plan
1. Add custom `init(from:)` to `SiteMeta` in `ios-mip-app/FFCI/API/ApiModels.swift`.
2. Decode `title`, `social`, `logo`, and `homepageQuickTasks` as today.
3. Decode `homepageFeatured` with a soft-fail strategy:
   - Missing key -> `nil`
   - Explicit `null` -> `nil`
   - Proper array -> decode `[HomepageFeatured]`
   - Numeric-keyed object -> decode dictionary, convert keys to `Int`, sort ascending, map values to array
   - Malformed payload/value -> return `nil` (do not throw)
4. Keep `MipApiClient.getSiteData()` unchanged; fix belongs in model decoding layer.
5. Verify with iOS flow `ios-mip-app/maestro/flows/homepage-loads-ios.yaml` and a payload check covering array/object/null/missing/malformed.

### Code Locations

| File | Purpose |
|------|---------|
| `ios-mip-app/FFCI/API/ApiModels.swift` | **Primary change** in `SiteMeta` block (`L65-L79`): add custom decoding + soft fallback for `homepage_featured` |
| `ios-mip-app/FFCI/API/MipApiClient.swift` | **No change needed**: already surfaces decoder output; behavior fixed by model decoder |
| `ios-mip-app/FFCI/ContentView.swift` | **No change needed**: shows why decode failure currently blocks app load |
| `ios-mip-app/FFCI/Views/HomeView.swift` | **No change needed**: already tolerant of `homepageFeatured == nil` |
| `android-mip-app/app/src/main/java/com/fiveq/ffci/data/api/FlexibleListAdapter.kt` | Reference behavior to mirror in Swift |

### Variables/Data Reference
- iOS model field: `SiteMeta.homepageFeatured` (`homepage_featured` JSON key).
- Supported incoming shapes:
  - Array: `"homepage_featured": [ {...}, {...} ]`
  - Numeric-keyed object: `"homepage_featured": { "0": {...}, "2": {...} }`
  - Null/missing: `"homepage_featured": null` or key omitted
- Soft-fail target:
  - If payload is malformed (wrong type, invalid object/value decode), set `homepageFeatured = nil` and continue decoding `SiteMeta`.

### Estimated Complexity
- **Low-Medium**: confined to one model decode path, but requires careful custom decoding to guarantee no throw for malformed `homepage_featured` while preserving existing behavior for valid array/null/missing payloads.
