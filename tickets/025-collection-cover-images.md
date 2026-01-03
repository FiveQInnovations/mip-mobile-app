---
status: backlog
area: rn-mip-app
created: 2026-01-02
---

# Collection Grid Cover Images

## Context
The current collection display only shows text titles. The spec requires a grid or list view with cover images, making collections visually appealing and helping users identify content quickly.

## Tasks
- [ ] Update collection grid to display cover image thumbnails
- [ ] Implement proper image sizing and aspect ratio handling
- [ ] Add placeholder/fallback for items without cover images
- [ ] Style grid layout for visual appeal
- [ ] Test on various screen sizes

## Notes
- Per spec: "Grid or list view of collection children" with "cover image, title"
- Currently TabScreen shows collection items as simple TouchableOpacity with text only
- Related to ticket 024 (Collection item metadata)
