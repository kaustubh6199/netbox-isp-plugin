#!/bin/bash
# This script should be RUN ON YOUR NETBOX LXC CONTAINER to fix the plugin installation

echo "=== NetBox Fiber Plugin Fix Script ==="
echo "Please run this script ON YOUR NETBOX LXC CONTAINER (as root or with sudo)"
echo ""

# Stop services first
echo "Stopping NetBox services..."
systemctl stop netbox
systemctl stop netbox-rq
echo ""

# Go to NetBox root
cd /opt/netbox/netbox || { echo "Error: Cannot access /opt/netbox/netbox"; exit 1; }

# Remove any existing incomplete plugin installation
echo "Removing any existing plugin installation..."
rm -rf plugins/netbox_fiber
echo ""

# Clone the latest version from GitHub (with the fixes)
echo "Downloading latest plugin from GitHub..."
git clone https://github.com/kaustubh6199/netbox-isp-plugin.git
if [ $? -ne 0 ]; then
    echo "Error: Failed to clone from GitHub. Trying alternative approach..."
    # If git fails, they may need to copy files manually
    echo "Please manually copy the netbox_fiber directory from the GitHub repository"
    echo "to /opt/netbox/netbox/plugins/"
    exit 1
fi

# Move the plugin to the correct location
echo "Installing plugin..."
mv netbox-isp-plugin/netbox_fiber plugins/
rmdir netbox-isp-plugin
echo ""

# Verify the installation
echo "Verifying installation..."
ls -la plugins/netbox_fiber/
echo ""

# Check the critical __init__.py file
echo "Checking __init__.py file:"
cat plugins/netbox_fiber/__init__.py
echo ""

# Set proper permissions
echo "Setting file permissions..."
chmod -R 755 plugins/netbox_fiber/
chown -R netbox:netbox plugins/netbox_fiber/
echo ""

# Run database migrations
echo "Running database migrations..."
/opt/netbox/venv/bin/python manage.py migrate
echo ""

# Start services
echo "Starting NetBox services..."
systemctl start netbox
systemctl start netbox-rq
echo ""

# Wait a moment then check status
echo "Checking service status (wait 10 seconds)..."
sleep 10
echo "NetBox service status:"
systemctl status netbox --no-pager
echo ""
echo "NetBox-RQ service status:"
systemctl status netbox-rq --no-pager
echo ""

# Test the import
echo "Testing plugin import..."
/opt/netbox/venv/bin/python -c "import netbox_fiber; print('SUCCESS: Plugin imports correctly')" && echo "✓ Installation verified!" || echo "✗ Import failed"

echo ""
echo "=== Fix Complete ==="
echo ""
echo "If successful, you should now be able to:"
echo "1. Access NetBox web interface at your container's IP address"
echo "2. Log in and navigate to: Plugins → Fiber Enclosures"
echo ""
echo "If you still have issues, check the logs with:"
echo "  journalctl -u netbox -f"
echo "  journalctl -u netbox-rq -f"