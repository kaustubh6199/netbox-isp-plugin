#
# NetBox Fiber Plugin Installer (PowerShell)
# This script helps deploy the NetBox Fiber plugin to a NetBox 3.x installation on Windows
#

param(
    [Parameter(Mandatory=$true)]
    [string]$NetBoxRoot
)

# Set strict error handling
$ErrorActionPreference = 'Stop'

try {
    # Verify NetBox root directory exists
    if (-Not (Test-Path $NetBoxRoot)) {
        throw "NetBox root directory '$NetBoxRoot' does not exist."
    }

    # Verify NetBox manage.py exists
    $managePyPath = Join-Path $NetBoxRoot 'manage.py'
    if (-Not (Test-Path $managePyPath)) {
        throw "manage.py not found in '$NetBoxRoot'. Are you sure this is the NetBox root directory?"
    }

    # Define plugins directory
    $pluginsDir = Join-Path $NetBoxRoot 'plugins'
    if (-Not (Test-Path $pluginsDir)) {
        Write-Host "Creating plugins directory at '$pluginsDir'"
        New-Item -ItemType Directory -Path $pluginsDir | Out-Null
    }

    # Copy plugin to NetBox plugins directory
    $pluginSource = Join-Path $PSScriptRoot 'netbox_fiber'
    $pluginDest = Join-Path $pluginsDir 'netbox_fiber'
    Write-Host "Copying NetBox Fiber plugin to '$pluginDest'..."
    if (Test-Path $pluginDest) {
        Remove-Item -Recurse -Force $pluginDest
    }
    Copy-Item -Path $pluginSource -Destination $pluginDest -Recurse

    # Change to NetBox directory and run migrations
    Write-Host "Running database migrations..."
    Push-Location -Path $NetBoxRoot
    python manage.py migrate
    Pop-Location

    Write-Host ""
    Write-Host "=== Installation Complete ==="
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "1. Add 'netbox_fiber' to the PLUGINS list in your NetBox configuration:"
    Write-Host "   Edit $NetBoxRoot\netbox\configuration.py"
    Write-Host "   Add: PLUGINS = ['netbox_fiber', ...]"
    Write-Host ""
    Write-Host "2. Restart NetBox services:"
    Write-Host "   If using IIS Reset:"
    Write-Host "     iisreset"
    Write-Host "   If using a service:"
    Write-Host "     Restart-Service <service_name>"
    Write-Host "   (Consult your NetBox deployment documentation for the correct method)"
    Write-Host ""
    Write-Host "3. Access the plugin via NetBox UI:"
    Write-Host "   Plugins → Fiber Enclosures / Optical Splitters / Fiber Connections"
    Write-Host ""
    Write-Host "For detailed configuration and usage, see README.md"
    Write-Host ""
}
catch {
    Write-Error "Error: $_"
    exit 1
}