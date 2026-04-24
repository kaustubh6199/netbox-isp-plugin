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