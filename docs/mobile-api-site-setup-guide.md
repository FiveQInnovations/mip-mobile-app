# Mobile API Site Setup Guide

Quick reference for adding mobile API configuration to the FFCI site.

## Reference Commits

- **7f68b189** - Add mobile configuration and user account (base mobile config)
- **c7887d3e** - change app tabs in Kirby settings (updated menu)
- **942c0c1f** - change mobile settings (final menu adjustments)

## Required Changes

### 1. Site Blueprint Configuration

**File:** `/Users/anthony/mip-mobile-app/sites/ws-ffci-copy/site/blueprints/site.yml`

**Change:** Add mobile tab reference

```yaml
title: Site
extends: site/tabs

tabs:
  taxonomies: tabs/global-taxonomies # collections
  mobile: tabs/mobile
```

**Reference:** `git show 7f68b189:site/blueprints/site.yml`

**Why:** Enables the "Mobile Settings" tab in Kirby Panel where mobile configuration fields are managed.

---

### 2. Site Content Configuration

**File:** `/Users/anthony/mip-mobile-app/sites/ws-ffci-copy/content/site.txt`

**Change:** Add mobile configuration fields at the end of the file

```yaml
----

Mobilehomepagetype: content

----

Mobilehomepagecontent: - page://nD0WLvWvzANPxq4m

----

Mobilehomepagecollection: - page://QIgwHryDboGM6Sw4

----

Mobileappname: FFCI

----

Mobilemainmenu:

- 
  page:
    - page://uezb3178BtP3oGuU
  label: Resources
  icon: [ ]
- 
  page:
    - page://pik8ysClOFGyllBY
  label: Chapters
  icon: [ ]
- 
  page:
    - page://xhZj4ejQ65bRhrJg
  label: About
  icon: [ ]
- 
  page:
    - page://3e56Ag4tc8SfnGAv
  label: Get Involved
  icon: [ ]

----

Mobilelogo: - file://xYEJWsj9KFipE9rA
```

**Reference:** 
- Base config: `git show 7f68b189:content/site.txt` (lines 79-120)
- Final menu: `git show c7887d3e:content/site.txt` (lines 95-120)

**Field Descriptions:**
- `Mobilehomepagetype`: Homepage type (`content`, `collection`, `navigation`, or `action-hub`)
- `Mobilehomepagecontent`: Page UUID for content-type homepage
- `Mobilehomepagecollection`: Page UUID for collection-type homepage
- `Mobileappname`: Display name for the mobile app
- `Mobilemainmenu`: Structure array of menu items (page UUID, label, optional icon)
- `Mobilelogo`: File UUID for the site logo

**Important:** Update the page UUIDs (`page://...`) and file UUID (`file://...`) to match actual pages/files in your site.

---

## Quick Apply Method

### Option 1: Cherry-pick (if repository structure matches)

```bash
cd /path/to/real-ffci-site
git cherry-pick 7f68b189 --no-commit
# Remove unwanted files (user accounts, etc.)
git reset HEAD storage/accounts/
git checkout -- storage/accounts/
git commit -m "Add mobile API configuration"
```

### Option 2: Manual Application

1. Copy the blueprint change to `site/blueprints/site.yml`
2. Copy the mobile configuration fields to `content/site.txt`
3. Update UUIDs to match your site's actual pages/files
4. Commit changes

---

## Verification

After applying changes:

1. **Check Kirby Panel:** Navigate to Site Settings → Mobile Settings tab
2. **Verify API Endpoint:** `GET /mobile-api` should return menu and site_data
3. **Test Menu:** `GET /mobile-api/menu` should return menu items
4. **Test Page:** `GET /mobile-api/page/{uuid}` should return page data

---

## Files NOT Needed

These changes from the commits are **not required** for the API:

- ❌ Styleguide page (`89fde602`)
- ❌ User account files (`storage/accounts/avjANFS0/`)
- ❌ `.cursorignore` and `.gitignore` updates
- ❌ `composer.lock` changes (unless dependencies actually changed)

