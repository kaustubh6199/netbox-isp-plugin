#!/bin/bash
# This script should be RUN ON YOUR NETBOX VM to verify the plugin installation

echo "=== NetBox Fiber Plugin Verification Script ==="
echo "Please run this script ON YOUR NETBOX VM (at 192.168.1.166)"
echo ""

# Check 1: Verify we're on the right system
echo "1. Checking system information:"
hostname
echo ""

# Check 2: Verify NetBox root directory
echo "2. Checking NetBox installation:"
if [ -d "/opt/netbox/netbox" ]; then
    echo "   ✓ NetBox directory found at /opt/netbox/netbox"
else
    echo "   ✗ NetBox directory NOT found at /opt/netbox/netbox"
    echo "   Please check where NetBox is installed"
fi
echo ""

# Check 3: Verify plugin directory
echo "3. Checking plugin installation:"
if [ -d "/opt/netbox/netbox/plugins/netbox_fiber" ]; then
    echo "   ✓ Plugin directory found"
    
    # Check 3a: List plugin contents
    echo "   Plugin contents:"
    ls -la /opt/netbox/netbox/plugins/netbox_fiber/
    echo ""
    
    # Check 3b: Verify __init__.py
    if [ -f "/opt/netbox/netbox/plugins/netbox_fiber/__init__.py" ]; then
        echo "   ✓ __init__.py file exists"
        echo "   Contents of __init__.py:"
        cat /opt/netbox/netbox/plugins/netbox_fiber/__init__.py
        echo ""
    else
        echo "   ✗ __init__.py file MISSING"
    fi
else
    echo "   ✗ Plugin directory NOT found at /opt/netbox/netbox/plugins/netbox_fiber"
    echo "   The plugin needs to be copied here"
fi
echo ""

# Check 4: Verify NetBox configuration
echo "4. Checking NetBox configuration:"
if [ -f "/opt/netbox/netbox/netbox/configuration.py" ]; then
    echo "   ✓ Configuration file found"
    echo "   PLUGINS setting:"
    grep -A 2 -B 2 "PLUGINS" /opt/netbox/netbox/netbox/configuration.py
else
    echo "   ✗ Configuration file NOT found"
fi
echo ""

# Check 5: Test Python import (THE CRITICAL TEST)
echo "5. Testing Python import (using NetBox's virtual environment):"
if [ -x "/opt/netbox/venv/bin/python" ]; then
    echo "   Using Python: /opt/netbox/venv/bin/python"
    /opt/netbox/venv/bin/python -c "
import sys
print('Python path:', sys.path[0])
try:
    import netbox_fiber
    print('✓ SUCCESS: netbox_fiber imported successfully')
    print('Plugin config:', netbox_fiber.config)
except Exception as e:
    print('✗ FAILED: Could not import netbox_fiber')
    print('Error:', e)
    print('Error type:', type(e).__name__)
"
else
    echo "   ✗ NetBox virtual environment Python not found at /opt/netbox/venv/bin/python"
fi
echo ""

# Check 6: Service status
echo "6. Checking service status:"
echo "   NetBox service:"
systemctl status netbox --no-pager -l
echo ""
echo "   NetBox-RQ service:"
systemctl status netbox-rq --no-pager -l
echo ""

# Check 7: Recent logs for errors
echo "7. Checking recent NetBox logs for errors:"
echo "   (Last 10 lines from netbox service)"
journalctl -u netbox -n 10 --no-pager
echo ""
echo "   (Last 10 lines from netbox-rq service)"
journalctl -u netbox-rq -n 10 --no-pager
echo ""

echo "=== Verification Complete ==="
echo ""
echo "If the Python import test (step 5) shows '✓ SUCCESS', then the plugin is correctly installed."
echo "If it shows '✗ FAILED', please share the error output above for further diagnosis."
echo ""
echo "To access NetBox web interface, try: http://$(hostname -I | awk '{print $1}')"
echo "Then log in and navigate to: Plugins → Fiber Enclosures"