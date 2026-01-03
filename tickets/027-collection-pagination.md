---
status: backlog
area: rn-mip-app
phase: nice-to-have
created: 2026-01-02
---

# Collection Pagination

## Context
The spec requires pagination support for large collections. The API supports pagination with limit and page parameters. This prevents loading all items at once for collections with many items.

## Tasks
- [ ] Implement infinite scroll or "load more" pattern for collections
- [ ] Track current page and total items
- [ ] Fetch next page of items when user scrolls near bottom
- [ ] Append new items to existing list
- [ ] Show loading indicator when fetching more
- [ ] Handle end-of-list state

## Notes
- Per spec: "Pagination if API supports it"
- API example shows `"pagination": { "limit": 20, "page": 1 }`
- Consider using FlatList with onEndReached for infinite scroll
