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

## Troubleshooting: File Sync Issues on Mac

If you encounter problems with file changes not syncing between your host and the DDEV container (for example, after editing plugins or site files), this may be due to Mutagen being enabled by default on Mac. To resolve this, you can disable Mutagen by setting the DDEV performance mode to `none`:

```sh
ddev stop
ddev config --performance-mode=none
ddev start
```

This will ensure that file changes are immediately reflected in your DDEV environment. (Tested on Mac.)