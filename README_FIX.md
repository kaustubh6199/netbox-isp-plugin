# QUICK FIX FOR NETBOX FIBER PLUGIN ON LXC CONTAINER

If you're seeing "ModuleNotFoundError: No module named 'netbox_fiber" after attempting to install the plugin, follow these EXACT steps on your NetBox LXC container (at 192.168.1.166):

## 📋 COPY-PASTE THESE COMMANDS

```bash
# 1. CONNECT TO YOUR NETBOX LXC CONTAINER
# (Use Proxmox VE console or SSH: ssh root@192.168.1.166)

# 2. RUN THESE EXACT COMMANDS IN ORDER:
systemctl stop netbox
systemctl stop netbox-rq
cd /opt/netbox/netbox
rm -rf plugins/netbox_fiber
git clone https://github.com/kaustubh6199/netbox-isp-plugin.git temp_fix
mv temp_fix/netbox_fiber plugins/
rmdir temp_fix
chmod -R 755 plugins/netbox_fiber/
chown -R netbox:netbox plugins/netbox_fiber/
cat plugins/netbox_fiber/__init__.py
/opt/netbox/venv/bin/python manage.py migrate
systemctl start netbox
systemctl start netbox-rq
sleep 10
systemctl status netbox
systemctl status netbox-rq
```

## ✅ WHAT TO LOOK FOR

After running the above commands:

1. **The `__init__.py` content should show:**
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

2. **Both services should be active (running):**
   ```
   ● netbox.service - NetBox WSGI Service
      Loaded: loaded (/etc/systemd/system/netbox.service; enabled; preset: enabled)
      Active: active (running) since ...
   
   ● netbox-rq.service - NetBox Request Queue Worker
      Loaded: loaded (/etc/systemd/system/netbox-rq.service; enabled; preset: enabled)
      Active: active (running) since ...
   ```

3. **You should be able to access:** http://192.168.1.166
   - Log in to NetBox
   - Go to: Plugins → Fiber Enclosures

## 🔍 TROUBLESHOOTING

If you still see errors, check the logs:
```bash
journalctl -u netbox -f --since "1 minute ago"
journalctl -u netbox-rq -f --since "1 minute ago"
```

Most common remaining issues:
- **Permissions not set correctly** - Re-run: `chmod -R 755 plugins/netbox_fiber/ && chown -R netbox:netbox plugins/netbox_fiber/`
- **Services not restarted** - Run: `systemctl restart netbox netbox-rq`
- **Browser cache issue** - Hard refresh (Ctrl+F5) or try incognito mode

## ✅ CONFIRMATION

Once working, you'll be able to manage:
- Fiber Enclosures (with site/location/rack assignment)
- Optical Splitters (with JSON split ratios, wavelength specs)
- Fiber Connections (with automatic loss calculation)
- All accessible via Plugins menu in NetBox UI

The plugin is now correctly installed for your PON network management needs!