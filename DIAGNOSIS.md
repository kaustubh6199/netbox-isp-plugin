# NetBox Fiber Plugin Installation Diagnostic Guide

If you're experiencing issues installing the NetBox Fiber plugin, follow this diagnostic checklist to identify and resolve the problem.

## Step 1: Verify File Transfer

### Check if plugin files were copied correctly
```bash
ls -la /opt/netbox/netbox/plugins/
```

Expected output:
```
total 4
drwxr-xr-x 3 root root 4096 Apr 25 01:00 .
drwxr-xr-x 3 root root 4096 Apr 25 00:56 ..
drwxr-xr-x 8 root root 4096 Apr 25 01:00 netbox_fiber
```

If you don't see `netbox_fiber` directory, the files weren't copied correctly.

### Check the plugin directory structure
```bash
ls -la /opt/netbox/netbox/plugins/netbox_fiber/
```

Expected output:
```
total 60
drwxr-xr-x 8 root root 4096 Apr 25 01:00 .
drwxr-xr-x 3 root root 4096 Apr 25 01:00 ..
-rw-r--r-- 1 root root  261 Apr 25 00:40 __init__.py
drwxr-xr-x 2 root root 4096 Apr 25 00:40 api
-rw-r--r-- 1 root root 9623 Apr 25 00:40 models.py
-rw-r--r-- 1 root root  873 Apr 25 00:40 navigation.py
-rw-r--r-- 1 root root  820 Apr 25 00:40 urls.py
-rw-r--r-- 1 root root 2101 Apr 25 00:40 views.py
drwxr-xr-x 2 root root 4096 Apr 25 00:40 templates
drwxr-xr-x 2 root root 4096 Apr 25 00:40 templates
```

If directories are missing, the copy was incomplete.

## Step 2: Verify __init__.py Content

### Check for the required config variable
```bash
cat /opt/netbox/netbox/plugins/netbox_fiber/__init__.py
```

Should contain:
```python
"""NetBox Fiber Plugin"""

from netbox.plugins import PluginConfig


class NetBoxFiberConfig(PluginConfig):
    name = "NetBox Fiber"
    version = "0.1.0"
    author = "Author Name"
    description = "Plugin for managing fiber enclosures, optical splitters, and fiber mappings in PON networks"
    base_url = "fiber"
    required_settings = []
    default_settings = {}


config = NetBoxFiberConfig
```

If you don't see the `config = NetBoxFiberConfig` line at the end, the __init__.py file is incorrect.

## Step 3: Check NetBox Configuration

### Verify plugin is in PLUGINS list
```bash
grep -n PLUGINS /opt/netbox/netbox/netbox/configuration.py
```

Should show something like:
```
PLUGINS = [
    'netbox_fiber',
    # ... other plugins
]
```

If you don't see `'netbox_fiber'` in the list, add it.

## Step 4: Check Python Import

### Test if Python can import the plugin
```bash
cd /opt/netbox/netbox
../venv/bin/python -c "import netbox_fiber; print('Import successful'); print(netbox_fiber.config)"
```

Should output:
```
Import successful
<netbox_fiber.NetBoxFiberConfig object at 0x...>
```

If you get `ModuleNotFoundError: No module named 'netbox_fiber'`, the plugin isn't in the Python path.

If you get `AttributeError: module 'netbox_fiber' has no attribute 'config'`, the __init__.py is missing the config variable.

## Step 5: Check File Permissions

### Verify the plugin files are readable
```bash
ls -la /opt/netbox/netbox/plugins/netbox_fiber/__init__.py
```

Should show read permissions for the user running NetBox (usually netbox or www-data):
```
-rw-r--r-- 1 netbox netbox 261 Apr 25 01:00 /opt/netbox/netbox/plugins/netbox_fiber/__init__.py
```

If permissions are wrong, fix them:
```bash
chmod 644 /opt/netbox/netbox/plugins/netbox_fiber/__init__.py
chown netbox:netbox /opt/netbox/netbox/plugins/netbox_fiber/__init__.py
```

## Step 6: Check Virtual Environment

### Verify you're using the correct Python
```bash
which python
```
or
```bash
../venv/bin/python --version
```

Should show Python 3.x and be pointing to your NetBox venv.

## Step 7: Check Django Settings

### Verify PLUGINS config is correct format
Check around line 870-890 in `/opt/netbox/netbox/netbox/settings.py` for the plugin loading section.

It should look like:
```python
PLUGINS = [
    'netbox_fiber',
    # ... other plugins
]
```

NOT:
```python
PLUGINS = [
    netbox_fiber,  # WRONG - missing quotes
    # ...
]
```

## Step 8: Clear Python Cache

Sometimes Python caches old imports. Clear the cache:
```bash
find /opt/netbox/netbox/plugins/netbox_fiber -name "*.pyc" -delete
find /opt/netbox/netbox/plugins/netbox_fiber -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
```

## Step 9: Restart Services

After making changes, always restart:
```bash
sudo systemctl restart netbox
sudo systemctl restart netbox-rq
```

## Step 10: Check Logs for Specific Errors

If still not working, check the logs:
```bash
sudo journalctl -u netbox -f --since "5 minutes ago"
```

Look for specific error messages that will point to the exact problem.

## Common Issues and Solutions

### Issue: "ModuleNotFoundError: No module named 'netbox_fiber'"
**Solution:** 
1. Verify plugin is in `/opt/netbox/netbox/plugins/netbox_fiber/`
2. Verify NetBox configuration includes `'netbox_fiber'` in PLUGINS list
3. Verify you're restarting the correct services

### Issue: "AttributeError: module 'netbox_fiber' has no attribute 'config'"
**Solution:**
1. Check that `__init__.py` ends with `config = NetBoxFiberConfig`
2. Verify the file was copied completely (not truncated)
3. Clear Python cache and restart services

### Issue: Still seeing maintenance error after restart
**Solution:**
1. Check logs for specific import errors
2. Verify all plugin files were copied (not just __init__.py)
3. Check file permissions
4. Verify no syntax errors in Python files

## Quick Verification Commands

Run these in order to diagnose the issue:

```bash
# 1. Check if plugin directory exists
ls -la /opt/netbox/netbox/plugins/ | grep netbox_fiber

# 2. Check __init__.py content
cat /opt/netbox/netbox/plugins/netbox_fiber/__init__.py | tail -5

# 3. Check if in PLUGINS
grep -A 3 -B 3 netbox_fiber /opt/netbox/netbox/netbox/configuration.py

# 4. Test Python import
cd /opt/netbox/netbox && ../venv/bin/python -c "import netbox_fiber; print('OK')"

# 5. Check service status
sudo systemctl status netbox
```

If you share the output of these commands, I can help you pinpoint the exact issue.