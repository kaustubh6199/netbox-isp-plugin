# Solution: Fixing NetBox Fiber Plugin Installation on LXC Container

Based on your latest output, here's exactly what you need to do on your NetBox LXC container (at 192.168.1.166):

## Step-by-Step Fix Instructions

### 1. Connect to your NetBox LXC container
```bash
# From your local machine:
ssh root@192.168.1.166
# Or use your Proxmox VE console access
```

### 2. Run these commands EXACTLY as shown:
```bash
# Stop NetBox services
systemctl stop netbox
systemctl stop netbox-rq

# Go to NetBox directory
cd /opt/netbox/netbox

# COMPLETELY remove any existing plugin installation
rm -rf plugins/netbox_fiber

# Clone the FIXED version from GitHub
git clone https://github.com/kaustubh6199/netbox-isp-plugin.git temp_plugin

# Move the plugin to the correct location
mv temp_plugin/netbox_fiber plugins/
rmdir temp_plugin

# Set correct permissions (CRITICAL STEP)
chmod -R 755 plugins/netbox_fiber/
chown -R netbox:netbox plugins/netbox_fiber/

# Verify the __init__.py file is correct
cat plugins/netbox_fiber/__init__.py

# Run database migrations
/opt/netbox/venv/bin/python manage.py migrate

# Start services
systemctl start netbox
systemctl start netbox-rq

# Wait a moment then check status
sleep 5
echo "=== Service Status ==="
systemctl status netbox --no-pager
echo ""
systemctl status netbox-rq --no-pager
```

## Why This Will Work:

1. **Clean removal**: `rm -rf plugins/netbox_fiber` ensures no corrupted files remain
2. **Fresh clone**: Gets the latest version from GitHub with all fixes
3. **Proper naming**: Uses a temporary directory to avoid the "directory not empty" issue
4. **Correct permissions**: Essential for the netbox user to read the files
5. **Verification**: Shows the __init__.py content so you can confirm it's correct

## Expected __init__.py Content:
After running `cat plugins/netbox_fiber/__init__.py`, you should see:
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

## After Completion:
1. Try accessing your NetBox web interface at: `http://192.168.1.166`
2. Log in and navigate to: **Plugins → Fiber Enclosures**
3. You should see the plugin interface working correctly

## If You Still Have Issues:
Check the logs for specific errors:
```bash
journalctl -u netbox -f --since "1 minute ago"
journalctl -u netbox-rq -f --since "1 minute ago"
```

The key was ensuring a completely clean installation with proper permissions and using the fixed version from GitHub that includes the corrected `__init__.py` file with the required `config` variable.