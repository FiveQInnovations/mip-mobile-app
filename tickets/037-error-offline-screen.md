---
status: backlog
area: rn-mip-app
created: 2026-01-02
---

# Error/Offline Screen Design

## Context
The spec requires a friendly error/offline screen with retry functionality. The current implementation shows basic error text, but needs a polished, user-friendly design.

## Tasks
- [ ] Design friendly error screen UI (icon, message, retry button)
- [ ] Create reusable ErrorScreen component
- [ ] Implement different messages for different error types (network, 404, etc.)
- [ ] Style consistently with app theme
- [ ] Add retry button with loading state
- [ ] Test on iOS and Android

## Notes
- Per spec: "Friendly error message, Retry button"
- Current implementation has basic error text in TabScreen and PageScreen
- Should feel polished and "app-like" not just developer error text
