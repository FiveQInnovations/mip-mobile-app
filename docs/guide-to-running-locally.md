Guide to Local Environment for MIP sites
===

This guide assumes Docker and DDEV are installed and configured on your system.

## Other notes

wst prefix = theme
wsp = plugin

## Setup MIP Site with DDEV

### First time setup for a new site
1. Clone the site repository
2. `cd` to the project directory
3. Configure DDEV:
   ```bash
   ddev config --docroot www --omit-containers db
   ```
4. Update the generated `.ddev/config.yaml` to use PHP 8.3+ if not already set

### Normal development workflow
1. `ddev auth ssh` (for accessing private repositories)
2. `ddev composer install`
3. `ddev npm install`
4. `ddev composer update`
5. `ddev exec gulp`
6. `ddev list` - click on the provided URL to launch the site

As a one-liner:
```bash
ddev auth ssh && ddev composer install && ddev npm install && ddev composer update && ddev exec gulp && ddev list
```

## Troubleshooting

### Permission denied from BitBucket
**Solution:** Run `ddev auth ssh` to authenticate with SSH keys

### DDEV Configuration Issues
- **Docroot Location**: Ensure docroot is set to `www` (contains `index.php`)
- **Project Type**: Should be `php`
- **PHP Version**: Ensure PHP 8.3+ is configured in `.ddev/config.yaml`

### Port Conflicts
If `ddev start` fails because something is running on port 80:
- Find what's using port 80: `sudo lsof -i :80`
- Stop the conflicting service or configure DDEV to use different ports

### SSH Host Key Issues
If you get "Remote Host Identification has changed" errors:
- `ddev ssh`
- `ssh-keygen -f "/home/.ssh-agent/known_hosts" -R "bitbucket.org"`
- Or delete `/home/.ssh-agent/known_hosts` entirely
- If forms do not load, then manually copy the js and css files from `site/plugins/wsp-forms/assets/form.js` to `www/media/plugins/wsp/forms/`
    - **`mkdir -p www/media/plugins/wsp/forms/`**
    - `cp site/plugins/wsp-forms/assets/form.css www/media/plugins/wsp/forms/`
    - `cp site/plugins/wsp-forms/assets/form.js www/media/plugins/wsp/forms/`
    - If connected to a real MIP server and not local then those commands are:
        - `cd /srv/site`
        - `sudo -u www-data  mkdir -p www/media/plugins/wsp/forms/`
        - `sudo -u www-data cp site/plugins/wsp-forms/assets/form.css www/media/plugins/wsp/forms/`
        - `sudo -u www-data cp site/plugins/wsp-forms/assets/form.js www/media/plugins/wsp/forms/`

### Browser Connection Issues
If browser tools or automated browsers can't connect to `https://your-site.ddev.site`:
- **Symptom:** Browser shows `chrome-error://chromewebdata/` or connection errors, even though `curl` and `ping` work
- **Cause:** Browser WebView may have SSL certificate handling issues or DDEV router not fully ready
- **Solution:** 
  1. Restart DDEV: `ddev restart`
  2. Wait a few seconds for router to fully initialize
  3. Try accessing via direct IP if domain still fails: `ddev describe` shows ports like `https://127.0.0.1:PORT`

### Page Content Not Updating
If you edit page content files (especially `Page-content` JSON fields) but changes don't appear:
- **Symptom:** Page still shows old content even after editing `content/*/default.txt` files, or you see JSON validation errors
- **Cause:** Kirby CMS caches page content and structure, OR the `Page-content:` JSON field has syntax errors
- **Solution:**
  1. **First, verify JSON is valid:** The `Page-content:` field contains JSON that must be valid. Validate it:
     ```bash
     ddev exec "php -r '\$content = file_get_contents(\"content/YOUR-PAGE/default.txt\"); preg_match(\"/Page-content: (.+?)\\\\n----/s\", \$content, \$matches); if(isset(\$matches[1])) { \$json = trim(\$matches[1]); \$decoded = json_decode(\$json, true); if(json_last_error() === JSON_ERROR_NONE) { echo \"JSON valid - \" . count(\$decoded) . \" sections\\n\"; } else { echo \"JSON Error: \" . json_last_error_msg() . \"\\n\"; exit(1); } }'"
     ```
  2. **If JSON is invalid:** Fix syntax errors (missing commas, quotes, brackets, etc.) in the `Page-content:` field
  3. **If JSON is valid but content still not showing:** Clear caches:
     - Clear Kirby cache: `ddev exec "rm -rf site/cache/*"`
     - Clear PHP opcache: `ddev exec "php -r 'if(function_exists(\"opcache_reset\")) opcache_reset();'"`
     - Restart DDEV: `ddev restart`

## Troubleshooting: File Sync Issues on Mac

If you encounter problems with file changes not syncing between your host and the DDEV container (for example, after editing plugins or site files), this may be due to Mutagen being enabled by default on Mac. To resolve this, you can disable Mutagen by setting the DDEV performance mode to `none`:

```sh
ddev stop
ddev config --performance-mode=none
ddev start
```

This will ensure that file changes are immediately reflected in your DDEV environment. (Tested on Mac.)