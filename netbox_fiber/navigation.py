from netbox.navigation import MenuItem
from utilities.utils import get_plugin_config


class FiberMenuItems(MenuItem):
    """
    Custom menu items for the Fiber plugin.
    """
    link = 'plugins:netbox_fiber:enclosure_list'
    link_text = 'Fiber Enclosures'
    permissions = ['netbox_fiber.view_fiberenclosure']


class SplitterMenuItems(MenuItem):
    link = 'plugins:netbox_fiber:splitter_list'
    link_text = 'Optical Splitters'
    permissions = ['netbox_fiber.view_opticalsplitter']


class ConnectionMenuItems(MenuItem):
    link = 'plugins:netbox_fiber:connection_list'
    link_text = 'Fiber Connections'
    permissions = ['netbox_fiber.view_fiberconnection']


class FiberMapMenuItems(MenuItem):
    link = 'plugins:netbox_fiber:fiber_map'
    link_text = 'Fiber Map'
    permissions = ['netbox_fiber.view_fiberconnection']  # Or a new permission if needed