# FINAL SOLUTION: Installing NetBox Fiber Plugin on LXC Container

You're running NetBox in an LXC container on Proxmox VE at IP 192.168.1.166.
Follow these EXACT steps to fix the plugin installation:

## ✅ STEP-BY-STEP INSTRUCTIONS

### 1. Access your NetBox LXC container
```bash
# From your Proxmox host or any machine with network access:
ssh root@192.168.1.166
# OR use the Proxmox VE web console -> your container -> Console
```

### 2. Execute these commands IN ORDER:
```bash
# STOP SERVICES FIRST
systemctl stop netbox
systemctl stop netbox-rq

# NAVIGATE TO NETBOX DIRECTORY
cd /opt/netbox/netbox

# REMOVE ANY EXISTING PLUGIN (be thorough)
rm -rf plugins/netbox_fiber

# GET THE FIXED VERSION FROM GITHUB
git clone https://github.com/kaustubh6199/netbox-isp-plugin.git temp_fix

# INSTALL THE PLUGIN CORRECTLY
mv temp_fix/netbox_fiber plugins/
rmdir temp_fix

# SET PROPER PERMISSIONS (THIS IS CRITICAL)
chmod -R 755 plugins/netbox_fiber/
chown -R netbox:netbox plugins/netbox_fiber/

# VERIFY THE INSTALLATION IS CORRECT
echo "=== Verifying __init__.py ==="
cat plugins/netbox_fiber/__init__.py

# RUN DATABASE MIGRATIONS
/opt/netbox/venv/bin/python manage.py migrate

# START SERVICES
systemctl start netbox
systemctl start netbox-rq

# WAIT THEN CHECK STATUS
sleep 10
echo "=== NETBOX SERVICE STATUS ==="
systemctl status netbox --no-pager
echo ""
echo "=== NETBOX-RQ SERVICE STATUS ==="
systemctl status netbox-rq --no-pager
```

## ✅ VERIFY IT WORKED

After running the above commands:

1. **Open your web browser** and go to: http://192.168.1.166
2. You should see the NetBox login screen
3. Log in with your credentials
4. Navigate to: **Plugins → Fiber Enclosures**
5. You should see the Fiber Enclosures interface

## 🔍 WHY THIS WORKS

The issues we identified and fixed:
1. **Missing config variable** - Fixed in `__init__.py` with `config = NetBoxFiberConfig`
2. **File permissions** - Set to 755 and owned by netbox:netbox
3. **Clean installation** - Removed all old files before installing new ones
4. **Proper cloning** - Used a temporary directory to avoid "directory not empty" errors

## 📝 EXPECTED OUTPUT

When you run `cat plugins/netbox_fiber/__init__.py`, you should see:
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

## 🚨 IF YOU STILL HAVE ISSUES

Check the logs for specific error messages:
```bash
# Check NetBox service logs
journalctl -u netbox -f --since "2 minutes ago"

# Check NetBox-RQ service logs  
journalctl -u netbox-rq -f --since "2 minutes ago"
```

Most commonly, remaining issues are:
1. **Permission problems** - Re-run the chmod/chown commands
2. **Service not restarted** - Run `systemctl restart netbox netbox-rq`
3. **Browser cache** - Hard refresh (Ctrl+F5) or try incognito mode

## ✅ CONFIRMATION

Once working, you'll be able to:
- Access NetBox web interface at http://192.168.1.166
- See "Fiber Enclosures" under the Plugins menu
- Add, view, and manage fiber enclosures, optical splitters, and fiber connections
- Use the API at /api/plugins/netbox-fiber/

The plugin is now correctly installed and configured for your PON network management needs!