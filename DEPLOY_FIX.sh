#!/bin/bash
# DEPLOY_FIX.sh - Definitive solution for installing NetBox Fiber plugin on LXC container
# Copy this script to your NetBox container and run it as root

echo "=== NetBox Fiber Plugin Definitive Installation Script ==="
echo "This script will fix the plugin installation on your NetBox LXC container"
echo ""

# Stop services
echo "Stopping NetBox services..."
systemctl stop netbox
systemctl stop netbox-rq
echo ""

# Go to NetBox directory
echo "Changing to NetBox directory..."
cd /opt/netbox/netbox || { 
    echo "ERROR: Cannot access /opt/netbox/netbox. Please check your NetBox installation path."
    exit 1
}
echo ""

# Remove any existing plugin installation COMPLETELY
echo "Removing any existing plugin installation..."
rm -rf plugins/netbox_fiber
echo ""

# Clone the plugin repository
echo "Cloning plugin repository from GitHub..."
git clone https://github.com/kaustubh6199/netbox-isp-plugin.git temp_plugin || {
    echo "ERROR: Failed to clone repository from GitHub"
    exit 1
}
echo ""

# Move the plugin to the correct location
echo "Installing plugin..."
mv temp_plugin/netbox_fiber plugins/ || {
    echo "ERROR: Failed to move plugin files"
    rm -rf temp_plugin
    exit 1
}
rmdir temp_plugin
echo ""

# Set proper permissions and ownership (CRITICAL FOR LXC CONTAINERS)
echo "Setting file permissions and ownership..."
chmod -R 755 plugins/netbox_fiber/
chown -R netbox:netbox plugins/netbox_fiber/
echo ""

# Verify the installation by checking the critical file
echo "Verifying plugin installation..."
if [ -f "plugins/netbox_fiber/__init__.py" ]; then
    echo "✓ __init__.py file exists"
    echo "Contents:"
    cat plugins/netbox_fiber/__init__.py
else
    echo "ERROR: __init__.py file not found!"
    exit 1
fi
echo ""

# Run database migrations
echo "Running database migrations..."
/opt/netbox/venv/bin/python manage.py migrate || {
    echo "ERROR: Database migration failed"
    exit 1
}
echo ""

# Start services
echo "Starting NetBox services..."
systemctl start netbox
systemctl start netbox-rq
echo ""

# Wait for services to start
echo "Waiting for services to start (10 seconds)..."
sleep 10
echo ""

# Check service status
echo "=== SERVICE STATUS ==="
echo "NetBox service:"
systemctl status netbox --no-pager
echo ""
echo "NetBox-RQ service:"
systemctl status netbox-rq --no-pager
echo ""

# Test Python import (the ultimate test)
echo "=== PLUGIN IMPORT TEST ==="
/opt/netbox/venv/bin/python -c "import netbox_fiber; print('✓ SUCCESS: Plugin imports correctly')" && echo "PLUGIN INSTALLATION VERIFIED!" || {
    echo "✗ ERROR: Plugin import failed"
    exit 1
}
echo ""

echo "=== INSTALLATION COMPLETE ==="
echo ""
echo "You should now be able to:"
echo "1. Access NetBox web interface at: http://$(hostname -I | awk '{print $1}')"
echo "2. Log in and navigate to: Plugins → Fiber Enclosures"
echo "3. Use the API at: http://$(hostname -I | awk '{print $1}')/api/plugins/netbox-fiber/"
echo ""
echo "If you still have issues, check the logs with:"
echo "  journalctl -u netbox -f"
echo "  journalctl -u netbox-rq -f"
echo ""