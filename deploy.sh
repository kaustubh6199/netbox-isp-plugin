#!/bin/bash
#
# NetBox Fiber Plugin Installer
# This script helps deploy the NetBox Fiber plugin to a NetBox 3.x installation
#

set -e  # Exit on any error

# Display usage information
usage() {
    echo "Usage: $0 <netbox_root_directory>"
    echo ""
    echo "Example:"
    echo "  $0 /opt/netbox/netbox"
    echo ""
    echo "This script will:"
    echo "  1. Copy the plugin to NetBox's plugins directory"
    echo "  2. Run database migrations"
    echo "  3. Provide instructions for restarting services"
    exit 1
}

# Check if netbox_root_directory is provided
if [ -z "$1" ]; then
    echo "Error: NetBox root directory not provided."
    usage
fi

NETBOX_ROOT="$1"
PLUGINS_DIR="$NETBOX_ROOT/plugins"

# Verify NetBox root directory exists
if [ ! -d "$NETBOX_ROOT" ]; then
    echo "Error: NetBox root directory '$NETBOX_ROOT' does not exist."
    exit 1
fi

# Verify NetBox manage.py exists
if [ ! -f "$NETBOX_ROOT/manage.py" ]; then
    echo "Error: manage.py not found in '$NETBOX_ROOT'. Are you sure this is the NetBox root directory?"
    exit 1
fi

# Verify plugins directory exists, create if not
if [ ! -d "$PLUGINS_DIR" ]; then
    echo "Creating plugins directory at '$PLUGINS_DIR'"
    mkdir -p "$PLUGINS_DIR"
fi

# Copy plugin to NetBox plugins directory
echo "Copying NetBox Fiber plugin to '$PLUGINS_DIR'..."
cp -r netbox_fiber "$PLUGINS_DIR/"

# Change to NetBox directory and run migrations
echo "Running database migrations..."
cd "$NETBOX_ROOT"
python manage.py migrate

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Next steps:"
echo "1. Add 'netbox_fiber' to the PLUGINS list in your NetBox configuration:"
echo "   Edit $NETBOX_ROOT/netbox/configuration.py"
echo "   Add: PLUGINS = ['netbox_fiber', ...]"
echo ""
echo "2. Restart NetBox services:"
echo "   If using systemd:"
echo "     sudo systemctl restart netbox"
echo "     sudo systemctl restart netbox-rq"
echo "   If using supervisor:"
echo "     sudo supervisorctl restart netbox"
echo "     sudo supervisorctl restart netbox-rq"
echo ""
echo "3. Access the plugin via NetBox UI:"
echo "   Plugins → Fiber Enclosures / Optical Splitters / Fiber Connections"
echo ""
echo "For detailed configuration and usage, see README.md"
echo ""