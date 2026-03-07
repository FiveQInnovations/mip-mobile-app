---
status: backlog
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
