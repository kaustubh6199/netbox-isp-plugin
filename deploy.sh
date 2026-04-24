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

# Remove trailing slash if present to avoid double slashes in paths
NETBOX_ROOT="${1%/}"
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

# Find NetBox virtual environment and Python interpreter
PYTHON_CMD=""

# Common NetBox virtual environment locations
VENV_PATHS=(
    "$NETBOX_ROOT/../venv"
    "$NETBOX_ROOT/venv"
    "/opt/netbox/venv"
    "/usr/local/netbox/venv"
    "$HOME/netbox/venv"
)

# Try to find the virtual environment
for venv_path in "${VENV_PATHS[@]}"; do
    if [ -f "$venv_path/bin/python" ] && [ -d "$venv_path" ]; then
        PYTHON_CMD="$venv_path/bin/python"
        echo "Found NetBox virtual environment at: $venv_path"
        break
    fi
done

# If not found in common locations, try to detect from manage.py shebang or fallback to system python
if [ -z "$PYTHON_CMD" ]; then
    # Check if manage.py has a shebang pointing to a specific python
    if [ -f "$NETBOX_ROOT/manage.py" ]; then
        SHEBANG=$(head -1 "$NETBOX_ROOT/manage.py" | grep -o 'python[^ ]*' || true)
        if [ -n "$SHEBANG" ] && [ -x "$(command -v $SHEBANG)" ]; then
            PYTHON_CMD=$(command -v $SHEBANG)
            echo "Using Python from manage.py shebang: $PYTHON_CMD"
        fi
    fi
fi

# Fallback to system python/python3 if still not found
if [ -z "$PYTHON_CMD" ]; then
    if command -v python &> /dev/null; then
        PYTHON_CMD="python"
    elif command -v python3 &> /dev/null; then
        PYTHON_CMD="python3"
    else
        echo "Error: Neither 'python' nor 'python3' command found. Please ensure Python is installed and in your PATH."
        exit 1
    fi
    echo "Using system Python: $PYTHON_CMD"
fi

# Change to NetBox directory and run migrations
echo "Running database migrations using '$PYTHON_CMD'..."
cd "$NETBOX_ROOT"
"$PYTHON_CMD" manage.py migrate

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