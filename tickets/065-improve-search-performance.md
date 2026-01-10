---
status: in-progress
area: wsp-mobile
phase: core
created: 2026-01-20
---

# Optimize Search API Endpoint Performance

## Context

The mobile API search endpoint (`/mobile-api/search`) has critical performance issues. Direct API testing reveals server-side processing takes 8-11 seconds for certain queries like "firefighters", making the mobile app search experience unusable. This is an **API-side performance problem**, not a mobile app issue.

**Current state:**
- API endpoint takes 8-11 seconds to process "firefighters" query (server processing time)
- Some queries are fast (0.5s) while others are slow (8-11s) - query-specific performance issue
- Network overhead is minimal (< 0.3s) - DNS, TLS, connection are fast
- Mobile app correctly makes requests; delay is entirely server-side
- Search endpoint implemented in `wsp-mobile/index.php` using Kirby's `site()->index()->search()`

**Target:**
- API endpoint should respond within 1-2 seconds for all queries
- Consistent performance regardless of query complexity or result count

## Goals

1. **Profile API Endpoint**: Identify exactly where time is spent in the search endpoint code
2. **Optimize Search Query**: Improve Kirby search performance for slow queries
3. **Add Caching**: Implement server-side caching for search results
4. **Optimize Result Processing**: Reduce time spent transforming results
5. **Verify Performance**: Ensure all queries respond within 1-2 seconds

## Tasks

- [x] Benchmark API endpoint performance
  - [x] Test API endpoint directly with curl to isolate server vs client
  - [x] Measure server processing time for various queries
  - [x] Document findings: 8-11s for "firefighters", 0.5s for "test"
- [ ] Profile search endpoint code (`wsp-mobile/index.php`)
  - [ ] Add timing logs to identify slow operations
  - [ ] Measure time spent in: query processing, Kirby search, result transformation
  - [ ] Identify which operation takes the most time
- [ ] Optimize Kirby search query
  - [ ] Review search options and scoring configuration
  - [ ] Consider limiting search scope or adding filters
  - [ ] Test different search strategies (full-text vs indexed)
  - [ ] Check if database/index optimization is needed
- [ ] Implement server-side caching
  - [ ] Add result caching for search queries (similar to KQL endpoint)
  - [ ] Set appropriate cache TTL for search results
  - [ ] Ensure cache invalidation on content updates
- [ ] Optimize result transformation
  - [ ] Review description extraction logic (HTML parsing, strip_tags)
  - [ ] Consider lazy-loading descriptions or reducing description length
  - [ ] Optimize page content access patterns
- [ ] Test and verify improvements
  - [ ] Test with multiple query types (short, long, common terms, edge cases)
  - [ ] Verify all queries respond within 1-2 seconds
  - [ ] Test cache hit/miss scenarios
  - [ ] Verify mobile app still works correctly with optimized API

## Findings (2026-01-20)

### API Endpoint Performance Analysis

Direct curl tests to `https://ffci.fiveq.dev/mobile-api/search` confirm the bottleneck is **server-side processing**:

**Performance Test Results:**
- **"firefighters" query (first request)**: 11.04s total
  - DNS lookup: 0.052s ✅
  - Connection: 0.102s ✅
  - TLS handshake: 0.266s ✅
  - **Server processing (time to first byte)**: 11.04s ⚠️ **BOTTLENECK**
- **"firefighters" query (second request)**: 8.07s total
  - Server processing: 8.07s ⚠️ (no caching benefit observed)
- **"test" query**: 0.49s total ✅
  - Server processing: 0.49s (fast)

**Root Cause Analysis:**
1. ✅ **Network overhead is minimal** - DNS, connection, TLS total < 0.3s
2. ⚠️ **Server-side processing is the bottleneck** - 8-11 seconds for "firefighters" query
3. ⚠️ **Query-specific performance issue** - Some queries fast (0.5s), others slow (8-11s)
4. ⚠️ **No server-side caching** - Second request still takes 8s (should be cached)
5. ✅ **Mobile app is not the issue** - App correctly makes requests; delay is entirely API-side

**API Implementation Location:**
- Endpoint: `wsp-mobile/index.php` (lines 166-235)
- Uses Kirby's `$kirby->site()->index()->search()` method
- Processes up to 50 results, extracts descriptions from HTML content
- No caching implemented (unlike KQL endpoint which has caching)

**Performance Targets:**
- Current: 8-11 seconds for slow queries
- Target: 1-2 seconds for all queries
- Improvement needed: 4-5x faster

## Related

- **Ticket 063**: Search results load slowly (initial mobile app optimization work)
- `wsp-mobile/index.php` (lines 166-235) - Search API endpoint implementation
- `wsp-mobile/index.php` (lines 116-154) - KQL endpoint with caching (reference implementation)
- `rn-mip-app/lib/searchCache.ts` - Mobile app client-side caching (already implemented)
- `rn-mip-app/app/search.tsx` - Mobile app search UI (not the bottleneck)
