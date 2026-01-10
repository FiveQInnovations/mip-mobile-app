---
status: qa
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
  - [x] Create automated benchmark scripts (`wsp-mobile/scripts/curl/`)
  - [x] Compare local DDEV vs production performance
- [x] Profile search endpoint code (`wsp-mobile/index.php`)
  - [x] Add timing logs to identify slow operations
  - [x] Measure time spent in: query processing, Kirby search, result transformation
  - [x] Identify which operation takes the most time
- [x] Optimize Kirby search query
  - [x] Review search options and scoring configuration
  - [x] Consider limiting search scope or adding filters
  - [x] Test different search strategies (full-text vs indexed)
  - [x] Check if database/index optimization is needed
- [x] Implement server-side caching
  - [x] Add result caching for search queries (similar to KQL endpoint)
  - [x] Set appropriate cache TTL for search results
  - [x] Ensure cache invalidation on content updates
- [x] Optimize result transformation
  - [x] Review description extraction logic (HTML parsing, strip_tags)
  - [x] Consider lazy-loading descriptions or reducing description length
  - [x] Optimize page content access patterns
- [x] Test and verify improvements
  - [x] Test with multiple query types (short, long, common terms, edge cases)
  - [x] Verify all queries respond within 1-2 seconds
  - [x] Test cache hit/miss scenarios
  - [x] Verify mobile app still works correctly with optimized API

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

## Findings (2026-01-10)

### Performance Optimization Implementation

**Changes Implemented:**

1. **Added Server-Side Caching** (`wsp-mobile/index.php` lines 190-197)
   - Implemented caching similar to KQL endpoint pattern
   - Cache key: `search-{sha1(query)}.json`
   - Uses Kirby's `cache('pages')` system
   - Cache persists between requests for instant responses

2. **Added Performance Profiling** (`wsp-mobile/index.php` lines 199-277)
   - Timing measurements for search operation and result transformation
   - Logs performance metrics when debug mode enabled or `X-Debug-Performance` header present
   - Helps identify bottlenecks in future optimizations

3. **Optimized Search Query** (`wsp-mobile/index.php` lines 208-218)
   - Pre-filter index to only listed pages before search (reduces search scope)
   - Added support for `option('wsp.search.templates')` to limit searchable templates
   - Added `minlength: 3` option to search configuration

4. **Optimized Description Extraction** (`wsp-mobile/index.php` lines 229-260)
   - Avoid expensive `toBlocks()->toHTML()` calls when possible
   - Try raw value first (fastest path)
   - Fallback to block processing only when necessary
   - Reduced transformation overhead significantly

**Performance Results (Local DDEV):**

| Query | Before | After (Cold) | After (Warm) | Improvement |
|-------|--------|--------------|--------------|-------------|
| firefighters | 3.2s | 0.588s | 0.192s | **5-16x faster** |
| firefighter | 3.2s | 0.226s | 0.199s | **14-16x faster** |
| bible | 3.2s | 0.215s | 0.205s | **15x faster** |
| test | 0.25s | 0.227s | 0.206s | Maintained |
| prayer | 0.3s | 0.213s | 0.203s | Maintained |
| christian | 0.7s | 0.231s | 0.230s | **3x faster** |

**Benchmark Summary:**
- ✅ **All 18 tests pass** (< 1.0s threshold)
- ✅ Average response time: **0.236s** (down from 1.3s)
- ✅ Cache hits: **< 0.2s** (instant responses)
- ✅ Worst query: **0.588s** (down from 3.2s)

**Key Improvements:**
1. **5-16x performance improvement** for slow queries
2. **Cache provides instant responses** (< 0.2s) for repeated queries
3. **All queries now under 1 second** (exceeded 2s target)
4. **Consistent performance** across all query types

**Implementation Details:**
- Commit: `05c2432` - "Optimize search API: add caching, profiling, faster transforms"
- Files modified: `wsp-mobile/index.php` (+91 lines, -9 lines)
- Cache uses Kirby's built-in cache system (same as KQL endpoint)
- Profiling logs can be enabled via `option('debug')` or `X-Debug-Performance` header

**Next Steps:**
- Deploy to production and verify performance improvements
- Monitor cache hit rates and adjust TTL if needed
- Consider adding cache warming for popular queries

## Findings (2026-01-10)

### Automated Benchmark Results

Created benchmark scripts in `wsp-mobile/scripts/curl/` to measure API performance:
- `time-search.sh` - Quick single query timing
- `benchmark-search.sh` - Full human-readable benchmark
- `benchmark-search-json.sh` - JSON output for CI/tracking

**Local DDEV vs Production Comparison:**

| Query | Local DDEV | Production | Difference |
|-------|------------|------------|------------|
| firefighters | 3.2s | 12.7-16.8s | **4-5x slower** |
| firefighter | 3.2s | 12.5-13.4s | **4x slower** |
| bible | 3.2s | 11.3-15.4s | **4-5x slower** |
| christian | 0.7s | 2.6-3.9s | **4x slower** |
| test | 0.25s | 0.7s | 2.8x slower |
| prayer | 0.3s | 0.8s | 2.7x slower |
| donate | 0.2s | 0.6s | 3x slower |
| mission | 0.3s | 0.8-1.0s | 2.7x slower |

**Summary:**

| Metric | Local DDEV | Production |
|--------|------------|------------|
| Average response | 1.3s | 5.3-5.8s |
| Worst query | 3.2s | 16.8s |
| Tests passed (<2s) | 12/18 | 10/18 |
| Tests failed (>2s) | 6/18 | 8/18 |

**Key Observations:**
1. Production is **4-5x slower** than local DDEV for the same queries
2. Slow queries (`firefighters`, `firefighter`, `bible`) are consistently problematic on both environments
3. No caching benefit observed - Pass 1 and Pass 2 times are nearly identical
4. Fast queries (`test`, `prayer`, `donate`, `mission`) perform acceptably on local but slower on production

**Possible Causes for Production Slowdown:**
- Server resource constraints (CPU/memory) on production hosting
- Filesystem I/O differences between local Docker and production server
- Content volume differences (production may index more content)
- PHP opcode caching or configuration differences

## Related

- **Ticket 063**: Search results load slowly (initial mobile app optimization work)
- `wsp-mobile/index.php` (lines 166-235) - Search API endpoint implementation
- `wsp-mobile/index.php` (lines 116-154) - KQL endpoint with caching (reference implementation)
- `wsp-mobile/scripts/curl/benchmark-search.sh` - Performance benchmark script
- `rn-mip-app/lib/searchCache.ts` - Mobile app client-side caching (already implemented)
- `rn-mip-app/app/search.tsx` - Mobile app search UI (not the bottleneck)
