#!/bin/bash
# COMPLETE FIX SCRIPT FOR NETBOX FIBER PLUGIN
# Run this on your NetBox LXC container as root

echo "=== COMPLETE NETBOX FIBER PLUGIN FIX ==="
echo ""

# STOP SERVICES FIRST
echo "Stopping NetBox services..."
systemctl stop netbox
systemctl stop netbox-rq
echo ""

# NAVIGATE TO NETBOX DIRECTORY
cd /opt/netbox/netbox
echo "Current directory: $(pwd)"
echo ""

# COMPLETELY REMOVE EXISTING PLUGIN AND CLEAN UP
echo "Cleaning up existing plugin and temp files..."
rm -rf plugins/netbox_fiber
rm -rf temp_fix
rm -rf netbox-isp-plugin
echo ""

# CLONE THE FIXED VERSION FROM GITHUB
echo "Cloning plugin from GitHub..."
git clone https://github.com/kaustubh6199/netbox-isp-plugin.git temp_fix
echo ""

# MOVE PLUGIN TO CORRECT LOCATION
echo "Moving plugin to plugins directory..."
mv temp_fix/netbox_fiber plugins/
# Clean up the temp directory - use rm -rf to ensure it's removed
rm -rf temp_fix
echo ""

# SET PERMISSIONS ON BOTH THE PLUGIN DIRECTORY AND THE PLUGINS DIRECTORY
echo "Setting permissions (CRITICAL)..."
chmod -R 755 plugins/
chown -R netbox:netbox plugins/
echo ""

# ADDITIONAL VERIFICATION - LIST THE CONTENTS
echo "=== Verifying plugin installation ==="
ls -la plugins/
echo ""
ls -la plugins/netbox_fiber/
echo ""

# VERIFY THE __init__.py FILE IS CORRECT
echo "=== Verifying __init__.py content ==="
cat plugins/netbox_fiber/__init__.py
echo ""

# RUN DATABASE MIGRATIONS
echo "Running database migrations..."
/opt/netbox/venv/bin/python manage.py migrate
echo ""

# START SERVICES
echo "Starting NetBox services..."
systemctl start netbox
systemctl start netbox-rq
echo ""

# WAIT FOR SERVICES TO START
echo "Waiting for services to start (15 seconds)..."
sleep 15
echo ""

# CHECK SERVICE STATUS
echo "=== SERVICE STATUS ==="
echo "NetBox service:"
systemctl status netbox --no-pager
echo ""
echo "NetBox-RQ service:"
systemctl status netbox-rq --no-pager
echo ""

# TEST THE PLUGIN IMPORT
echo "=== PLUGIN IMPORT TEST ==="
/opt/netbox/venv/bin/python -c "import netbox_fiber; print('SUCCESS: Plugin imports correctly!')"
echo ""

echo "=== FIX COMPLETE ==="
echo ""
echo "Try accessing your NetBox at: http://192.168.1.166"
echo "Navigate to: Plugins → Fiber Enclosures"
echo ""
echo "If you still see errors, check the logs with:"
echo "  journalctl -u netbox -f --since '1 minute ago'"
echo "  journalctl -u netbox-rq -f --since '1 minute ago'"