# True scope additions in `docs/mobile-app-specification.md` (vs job posting)

Baseline assumed: job post = "brochure-style RN app" pulling content from Kirby CMS via GraphQL, video library, brochure pages, basic contact forms, daily Teamwork updates, Loom demos, Maestro tests.

## True scope additions (not mere clarifications)

- **Multi-site reusable template requirement**: one codebase that can be launched for future MIP sites with *config only* (no additional coding), including documented "Adding a New Site" process.
- **Full release pipeline scope**: EAS Build + EAS Submit + **EAS Update (OTA)** + required documentation so others can ship updates.
- **Server/backend work**: install/configure Kirby plugins (KQL + headless bearer auth), bearer token management, blocked classes, Panel blueprint/mobile settings, and query validation.

## Plain English explanation for project manager

The original job posting described building one mobile app for one ministry. The detailed spec turns this into building a **reusable mobile app "factory"** that Five Q can use to launch apps for *any* MIP site (like our Kirby CMS websites) without hiring a developer each time.

### What this adds beyond the original job:

1. **Future-proof "template" system**: Instead of just building an app, you also create all the tools and documentation so that launching a new ministry's app becomes a quick configuration task (like copying a template and filling in settings) rather than a full development project.

2. **Complete publishing pipeline**: The contractor doesn't just build the app - they set up the entire automated system for releasing updates to app stores, including the ability to push bug fixes to users' phones without going through app store review (OTA updates).

3. **Server setup and configuration**: The contractor handles the technical backend setup on our Kirby CMS sites - installing the right plugins, setting up secure API access, and configuring how the mobile app connects to pull content. This ensures the websites are properly prepared to serve mobile app data.
