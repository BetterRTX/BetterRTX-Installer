import logging

# Set up logger for this file
logger = logging.getLogger(__name__)
from dataclasses import dataclass
import subprocess
import xml.etree.ElementTree as ET
import json
@dataclass
class MinecraftInstallation:
    name: str
    location: str
    is_preview: bool
    requires_iobit: bool = True

def getMinecraftInstallations():
    """
    Get a list of Minecraft installations (UWP/Bedrock/Preview).
    :return: A list of MinecraftInstallation objects.
    """
    installations = []
    try:
        # Get all Microsoft.Minecraft* packages with full package name
        result = subprocess.run(
            [
                'powershell',
                '-Command',
                'Get-AppxPackage -Name "Microsoft.Minecraft*" | Select-Object -Property Name,PackageFullName,InstallLocation | ConvertTo-Json'
            ],
            capture_output=True, text=True, check=True
        )
        logger.info(f"Result: {result.stdout}")
        # Parse the JSON output
        packages = json.loads(result.stdout)
        for package in packages:
            name = package.get('Name')
            package_full_name = package.get('PackageFullName')
            install_location = package.get('InstallLocation')

            if not name or not package_full_name or not install_location:
                logger.info(f"Skipping package due to missing fields: {package}")
                continue
            if "Java" in install_location:
                continue

            # Get manifest to extract FriendlyName
            try:
                manifest_result = subprocess.run(
                    [
                        'powershell', '-Command',
                        f'(Get-AppxPackageManifest -Package "{package_full_name}").Package.Properties.DisplayName'
                    ],
                    capture_output=True, text=True, check=True
                )
                friendly_name = manifest_result.stdout.strip()
                logger.info(f"Friendly Name: {friendly_name}")
            except Exception:
                friendly_name = name

            is_preview = "Beta" in install_location or "Preview" in friendly_name
            requires_iobit = True if "WindowsApps" in install_location else False
            installations.append(MinecraftInstallation(
                name=friendly_name,
                location=install_location,
                is_preview=is_preview,
                requires_iobit=requires_iobit
            ))

        return installations
    finally:
        pass


if __name__ == "__main__":
    installations = getMinecraftInstallations()
    for installation in installations:
        logger.info(f"Name: {installation.name}, Location: {installation.location}, Is Side Launcher: {installation.is_preview}, Requires IOBit: {installation.requires_iobit}")