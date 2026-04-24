# NetBox Fiber Plugin

A NetBox plugin for managing fiber enclosures, optical splitters, and fiber mappings specifically designed for Passive Optical Network (PON) infrastructure.

## Features

- **Fiber Enclosure Management**: Track fiber enclosures with location, rack position, and port information
- **Optical Splitter Management**: Model optical splitters with configurable split ratios and wavelength specifications
- **Fiber Connection Tracking**: Document fiber connections between termination points with loss calculations
- **PON-Specific Fields**: Wavelength specifications for upstream/downstream/video, insertion loss, splitter classes
- **Fiber Map Visualization**: Visual representation of fiber infrastructure (basic implementation)
- **REST API**: Full API access for all models
- **Power Budget Calculations**: Calculate available power budget for fiber connections

## Requirements

- NetBox 3.0 or higher
- Python 3.8+
- Django 3.2+ (as required by NetBox)

## Installation

### 1. Install the Plugin

Copy the `netbox_fiber` directory to your NetBox installation's `plugins` directory:

```bash
# From your NetBox root directory
cp -r /path/to/netbox_fiber ./plugins/
```

### 2. Install Required Python Packages

The plugin requires no additional packages beyond what NetBox already uses. However, if you want to enhance the fiber map visualization in the future, you might consider:

```bash
# Optional: For enhanced visualization (future implementation)
pip install matplotlib networkx
```

### 3. Enable the Plugin

Edit your NetBox configuration file (`configuration.py` or `config.py`) to add the plugin to the `PLUGINS` list:

```python
PLUGINS = [
    'netbox_fiber',
    # ... other plugins
]
```

### 4. Configure Plugin Settings (Optional)

Add any plugin-specific settings to your configuration:

```python
PLUGINS_CONFIG = {
    'netbox_fiber': {
        # Example configuration options (add as needed)
        'default_attenuation': 0.35,  # dB/km for SMF
        'connector_loss': 0.5,        # dB per connector pair
    }
}
```

### 5. Run Database Migrations

After enabling the plugin, run the database migrations to create the required tables:

```bash
# From your NetBox root directory
python manage.py migrate
```

### 6. Restart Services

Restart your NetBox services (web server and background workers):

```bash
# Example for systemd
sudo systemctl restart netbox
sudo systemctl restart netbox-rq

# Or if using supervisor
sudo supervisorctl restart netbox
sudo supervisorctl restart netbox-rq
```

## Usage

### Accessing the Plugin

Once installed and enabled, you'll find the Fiber plugin in the NetBox sidebar under "Plugins":

- **Fiber Enclosures**: Manage fiber enclosure inventory
- **Optical Splitters**: Manage optical splitter components
- **Fiber Connections**: Track fiber connections between devices
- **Fiber Map**: Visualize your fiber infrastructure

### Adding Fiber Enclosures

1. Navigate to **Plugins → Fiber Enclosures**
2. Click "Add Fiber Enclosure"
3. Fill in the required fields:
   - Name
   - Site
   - Location (optional)
   - Rack (optional)
   - Position (U position in rack)
   - Height (in rack units)
   - Enclosure Type
   - Port Count
   - Maximum Split Ratio (optional)
4. Click "Save"

### Adding Optical Splitters

1. Navigate to **Plugins → Optical Splitters**
2. Click "Add Optical Splitter"
3. Fill in the required fields:
   - Name
   - Site
   - Location (optional)
   - Input Ports (typically 1 for PON)
   - Output Ports
   - Split Ratio (as a JSON array, e.g., `[50, 50]` for 1:2 splitter)
   - Wavelength specifications (upstream, downstream, video)
   - Insertion Loss
   - Splitter Class
   - Manufacturer and Part Number (optional)
4. Click "Save"

### Adding Fiber Connections

1. Navigate to **Plugins → Fiber Connections**
2. Click "Add Fiber Connection"
3. Select termination points A and B (can be devices, interfaces, etc.)
4. Specify:
   - Cable Type
   - Length (in meters)
   - Attenuation Coefficient (default 0.35 dB/km for SMF)
   - Installation Date (optional)
   - Notes (optional)
5. The connection loss will be calculated automatically
6. Click "Save"

### Using the Fiber Map

Navigate to **Plugins → Fiber Map** to view a basic visualization of your fiber infrastructure. This shows enclosures, splitters, and connections.

## API Access

The plugin provides a RESTful API at `/api/plugins/netbox-fiber/`:

- `/api/plugins/netbox-fiber/enclosures/` - Fiber enclosures
- `/api/plugins/netbox-fiber/splitters/` - Optical splitters
- `/api/plugins/netbox-fiber/connections/` - Fiber connections

Standard DRF endpoints are available for listing, creating, retrieving, updating, and deleting objects.

## PON-Specific Features

### Optical Splitter Configuration

For PON networks, configure splitters with appropriate split ratios:
- 1x2 splitter: `[50, 50]`
- 1x4 splitter: `[25, 25, 25, 25]`
- 1x8 splitter: `[12.5, 12.5, 12.5, 12.5, 12.5, 12.5, 12.5, 12.5]`
- 1x16 splitter: `[6.25, 6.25, ...]` (16 values)
- 1x32 splitter: `[3.125, 3.125, ...]` (32 values)
- 1x64 splitter: `[1.5625, 1.5625, ...]` (64 values)

### Wavelength Specifications

Configure wavelength ranges according to your PON standard:
- **GPON**: 
  - Upstream: 1260-1360 nm
  - Downstream: 1480-1500 nm
- **XG-PON**:
  - Upstream: 1260-1360 nm
  - Downstream: 1575-1580 nm
- **RF Overlay** (if used):
  - Video: 1550 nm (typically 1540-1560 nm)

## Customization

### Modifying Layout Data

Fiber enclosures include a `layout_data` JSON field for storing port positions and internal component layouts. This can be used for custom visualization tools.

Example layout data structure:
```json
{
  "ports": [
    {"id": 1, "label": "Port 1", "x": 10, "y": 20, "type": "LC"},
    {"id": 2, "label": "Port 2", "x": 10, "y": 40, "type": "LC"}
  ],
  "internal_components": [
    {"type": "splice_tray", "x": 50, "y": 30, "width": 40, "height": 20}
  ]
}
```

### Extending the Plugin

To extend the plugin functionality:
1. Override templates in your NetBox templates directory
2. Create custom views or API endpoints
3. Add additional fields through model inheritance (requires fork)

## Troubleshooting

### Plugin Not Showing Up

1. Verify the plugin directory is in the correct location (`NETBOX_ROOT/plugins/netbox_fiber`)
2. Check that `__init__.py` exists in the plugin directory
3. Confirm the plugin is listed in `PLUGINS` in your configuration
4. Check NetBox logs for import errors

### Database Migration Issues

1. Ensure you've run `python manage.py migrate` after enabling the plugin
2. Check for conflicting table names if you have other plugins
3. Verify database user has permissions to create tables

### Performance Concerns

The fiber map view currently limits queries to 100 objects of each type for performance. For larger deployments, consider implementing filtering or pagination in the map view.

## Support

For issues, questions, or contributions, please refer to the NetBox community resources or create an issue in the plugin repository.

## License

This plugin is released under the MIT License. See the [LICENSE](LICENSE) file for details.

---
*NetBox Fiber Plugin - Managing PON Infrastructure with NetBox*