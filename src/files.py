import logging
import time
import tempfile
from .fileManagement.iobit_unlocker import IObitUnlocker
from .fileManagement.regular_file_management import RegularFileManagement
from .minecraftInstallations import MinecraftInstallation as MCI
import os
import json
from .api import betterrtx_preset
import requests
import flet as ft

# Set up logger for this file
logger = logging.getLogger(__name__)

def download_install_BetterRTX_Bins(bin: betterrtx_preset, MinecraftInstallation: MCI, text_info: ft.Ref[ft.TextField]=None):
    """
    Download BetterRTX binaries for the specified Minecraft installation.
    :param MinecraftInstallation: The Minecraft installation object.
    """
    def set_status(msg, level=logging.INFO, log: bool=True):
        if log:
            logger.log(level, msg)
        if text_info and hasattr(text_info, 'current') and text_info.current:
            text_info.current.color = "white" if level == logging.INFO else "red"
            text_info.current.value = msg
            text_info.current.update()
    set_status("Preparing installation...")
    if MinecraftInstallation.requires_iobit:
        unlocker = IObitUnlocker()
    else:
        regular_file_mgmt = RegularFileManagement()
    
    logger.info(f"Downloading BetterRTX binaries for {MinecraftInstallation.name} at {MinecraftInstallation.location}")

    # 1. Download the BetterRTX binaries from the specified URLs to a temporary location.
    temp_dir = os.path.join(tempfile.gettempdir(), "BetterRTX")
    logger.debug(f"Creating temporary directory at {temp_dir}")

  
    os.makedirs(temp_dir, exist_ok=True)
    logger.debug(f"{os.stat(temp_dir).st_mode}")
    rtxstub_path = os.path.join(temp_dir, "RTXStub.BetterRTX.material.bin")
    tonemapping_path = os.path.join(temp_dir, "RTXPostFX.Tonemapping.BetterRTX.material.bin")
    bloom_path = os.path.join(temp_dir, "RTXPostFX.Bloom.BetterRTX.material.bin")


    try: 
        os.remove(rtxstub_path)
    except Exception as e:
        logger.error(f"Failed to remove {rtxstub_path}: {e}")

    try:
        os.remove(tonemapping_path)
    except Exception as e:
        logger.error(f"Failed to remove {tonemapping_path}: {e}")
    try:
        os.remove(bloom_path)
    except Exception as e:
        logger.error(f"Failed to remove {bloom_path}: {e}")
    try: 
        os.remove(os.path.join(temp_dir, "materials.index.json"))
    except Exception as e:
        logger.error(f"Failed to remove {os.path.join(temp_dir, 'materials.index.json')}: {e}")

    try:
        os.remove(os.path.join(temp_dir, "backup.materials.index.json"))
    except Exception as e:
        logger.error(f"Failed to remove {os.path.join(temp_dir, 'backup.materials.index.json')}: {e}")
    # Download the files to their respective paths
    def download_file(url, path, name=None):
        response = requests.get(url, timeout=30)
        if response.status_code == 200:
            with open(path, 'wb') as f:
                f.write(response.content)
        else:
            set_status(f"Failed to download {name}", level=logging.ERROR)
            raise RuntimeError(f"Failed to download {url}: {response.status_code}")
    
    set_status("Downloading RTXStub")
    download_file(bin.rtxstub_url, rtxstub_path, "RTXStub")
    set_status("Downloading Tonemapping")
    download_file(bin.tonemapping_url, tonemapping_path, "Tonemapping")
    set_status("Downloading Bloom", level=logging.INFO)
    download_file(bin.bloom_url, bloom_path)
    logger.info(f"Downloaded BetterRTX binaries to {temp_dir}")
    set_status("Downloaded BetterRTX binaries")

    # 2. Copy the downloaded files to the Minecraft installation directory <installationlocation>/data/renderer/materials
    materials_dir = os.path.join(MinecraftInstallation.location, "data", "renderer", "materials")

    
    logger.debug(f"Materials directory at {materials_dir}")
    if MinecraftInstallation.requires_iobit:
        unlocker = IObitUnlocker()

        #if the materials already exists, delete it
        if os.path.exists(os.path.join(materials_dir, "RTXStub.BetterRTX.material.bin")):
            set_status("Removing existing BetterRTX binaries")
            unlocker.delete(os.path.join(materials_dir, "RTXStub.BetterRTX.material.bin"))
        if os.path.exists(os.path.join(materials_dir, "RTXPostFX.Tonemapping.BetterRTX.material.bin")):
            unlocker.delete(os.path.join(materials_dir, "RTXPostFX.Tonemapping.BetterRTX.material.bin"))
        if os.path.exists(os.path.join(materials_dir, "RTXPostFX.Bloom.BetterRTX.material.bin")):
            unlocker.delete(os.path.join(materials_dir, "RTXPostFX.Bloom.BetterRTX.material.bin"))
        set_status("Copying RTXStub to installation directory")
        try:
            unlocker.copy(rtxstub_path, materials_dir)
        except Exception as e:
            set_status("Error occurred when copying RTXStub to Minecraft Install", level=logging.WARNING)
            logger.error(f"Error occurred when copying RTXStub to Minecraft Install: {e}")
            return
        set_status("Copying Tonemapping to installation directory")
        try:
            unlocker.copy(tonemapping_path, materials_dir)
        except Exception as e:
            set_status("Error occurred when copying Tonemapping to Minecraft Install", level=logging.WARNING)
            logger.error(f"Error occurred when copying Tonemapping to Minecraft Install: {e}")
            return
        set_status("Copying Bloom to installation directory")
        try:
           unlocker.copy(bloom_path, materials_dir)
        except Exception as e:
            set_status("Error occurred when copying Bloom to Minecraft Install", level=logging.WARNING)
            logger.error(f"Error occurred when copying Bloom to Minecraft Install: {e}")
            return
    else:
        regular_file_mgmt = RegularFileManagement()
        set_status("Copying RTXStub to installation directory")
        try:
            regular_file_mgmt.copy(rtxstub_path, materials_dir)
        except Exception as e:
            set_status("Error occurred when copying RTXStub to Minecraft Install", level=logging.WARNING)
            logger.error(f"Error occurred when copying RTXStub to Minecraft Install: {e}")
            return
        set_status("Copying Tonemapping to installation directory")
        try:
            regular_file_mgmt.copy(tonemapping_path, materials_dir)
        except Exception as e:
            set_status("Error occurred when copying Tonemapping to Minecraft Install", level=logging.WARNING)
            logger.error(f"Error occurred when copying Tonemapping to Minecraft Install: {e}")
            return
        set_status("Copying Bloom to installation directory")
        try:
            regular_file_mgmt.copy(bloom_path, materials_dir)
        except Exception as e:
            set_status("Error occurred when copying Bloom to Minecraft Install", level=logging.WARNING)
            logger.error(f"Error occurred when copying Bloom to Minecraft Install: {e}")
            return
    logger.info(f"Copied BetterRTX binaries to {materials_dir}")
    set_status("Copied BetterRTX binaries to installation directory")

    # 3. Copy <installationlocation>/data/renderer/materials/materials.index.json to a temporary location.
    materials_index_path = os.path.join(materials_dir, "materials.index.json")
    temp_index_path = os.path.join(temp_dir, "materials.index.json")
    # make temp index path
    os.makedirs(os.path.dirname(temp_index_path), exist_ok=True)
    if MinecraftInstallation.requires_iobit:
        try:
            # set_status("Copying materials.index.json to temporary location")
            set_status("Creating Backup of materials.index.json")

            # copy materials from game directory to temp dir
            unlocker.copy(materials_index_path, temp_dir)
            time.sleep(.5)

            # rename materials.index.json to backup.materials.index.json in temp dir
            os.rename(os.path.join(temp_dir, "materials.index.json"), os.path.join(temp_dir, "backup.materials.index.json"))
            time.sleep(.5)
            unlocker.copy(os.path.join(temp_dir, "backup.materials.index.json"), materials_dir)
            time.sleep(.5)
            # rename backup.materials.index.json to materials.index.json in temp dir
            os.rename(os.path.join(temp_dir, "backup.materials.index.json"), os.path.join(temp_dir, "materials.index.json"))
            time.sleep(.5)
        except Exception as e:
            set_status("Error occurred when copying materials.index.json to temporary location", level=logging.WARNING)
            logger.error(f"Error occurred when copying materials.index.json to temporary location: {e}")
            return
    else:
        try:
            set_status("Copying materials.index.json to temporary location")
            regular_file_mgmt.copy(materials_index_path, temp_index_path)
            set_status("Renaming materials.index.json to backup.materials.index.json in game directory")
            regular_file_mgmt.rename(materials_index_path, "backup.materials.index.json")
        except Exception as e:
            set_status("Error occurred when copying materials.index.json to temporary location", level=logging.WARNING)
            logger.error(f"Error occurred when copying materials.index.json to temporary location: {e}")
            return

    logger.info(f"Copied materials.index.json to {temp_index_path}")
    set_status("Modifying temporary materials.index.json")
    # 4. Edit the existing rtxstub, tonemapping, and bloom paths in the materials.index.json file to point to a renamed version of the downloaded files in the installation directory.
    time.sleep(1) # bro just had to do so much work and deserves a break - and gets pissy if you don't let him
                    # to be specific, due likely to the python file trying to read the file while it is being written to by iobit unlocker, shit hits the fan.
    with open(temp_index_path, 'r', encoding='utf-8') as f:
        index_data = json.load(f)
        # Only change the path, not the name
        for item in index_data["materials"]:
            if item["name"] == "RTXPostFX.Bloom":
                item["path"] = "RTXPostFX.Bloom.BetterRTX"
            elif item["name"] == "RTXPostFX.ToneMapping":
                item["path"] = "RTXPostFX.Tonemapping.BetterRTX"
            elif item["name"] == "RTXStub":
                item["path"] = "RTXStub.BetterRTX"
    # Write the modified data back to the file
    with open(temp_index_path, 'w', encoding='utf-8') as f:
        json.dump(index_data, f, indent=3)

    logger.info("Modified materials.index.json to point to BetterRTX binaries")
    # 6. Rename the index.json file in the game directory to backup.materials.index.json
    # set_status("Renaming materials.index.json to backup.materials.index.json")
    # backup_index_path = os.path.join(materials_dir, "backup.materials.index.json")
    # if MinecraftInstallation.requires_iobit:
    #     unlocker.copy(materials_index_path, temp_dir)
    # else:
    #     regular_file_mgmt.rename(materials_index_path, backup_index_path)
    # logger.info(f"Renamed materials.index.json to {backup_index_path}")

    # 7. Copy the modified materials.index.json file to the game directory.
    set_status("Copying modified materials.index.json to installation directory")
    if MinecraftInstallation.requires_iobit:
        try:
            unlocker.delete(materials_index_path)
            unlocker.copy(temp_index_path, materials_dir)
        except Exception as e:
            set_status("Error occurred when copying modified materials.index.json to installation directory", level=logging.WARNING)
            logger.error(f"Error occurred when copying modified materials.index.json to installation directory: {e}")
            return
    else:
        try:
            regular_file_mgmt.copy(temp_index_path, materials_dir)
        except Exception as e:
            set_status("Error occurred when copying modified materials.index.json to installation directory", level=logging.WARNING)
            logger.error(f"Error occurred when copying modified materials.index.json to installation directory: {e}")
            return
    
    logger.info(f"Copied modified materials.index.json to {materials_dir}")
    set_status("Done")

def install_dlss(MinecraftInstallation: MCI, text_info=None):
    """
    Install DLSS for the specified Minecraft installation.
    :param MinecraftInstallation: The Minecraft installation object.
    """
    def set_status(msg, level=logging.INFO, log: bool=True):
        # logger.info(msg)
        if log:
            logger.log(level, msg)
        if text_info and hasattr(text_info, 'current') and text_info.current:
            text_info.current.value = msg
            text_info.current.update()
    set_status("Preparing DLSS Update...")
    if MinecraftInstallation.requires_iobit:
        unlocker = IObitUnlocker()
    else:
        regular_file_mgmt = RegularFileManagement()
    
    logger.info(f"Installing DLSS for {MinecraftInstallation.name} at {MinecraftInstallation.location}")

    # 1. Download the DLSS binaries from the specified URLs to a temporary location.
    temp_dir = os.path.join(tempfile.gettempdir(), "BetterRTX")
    temp_dir = os.path.join(temp_dir, "DLSS")
    os.makedirs(temp_dir, exist_ok=True)
    if os.path.exists(os.path.join(temp_dir, "nvngx_dlss.dll")):
        os.remove(os.path.join(temp_dir, "nvngx_dlss.dll"))
    
    dlss_download = requests.get("https://bedrock.graphics/api/dlss", timeout=30)
    with open(os.path.join(temp_dir, "nvngx_dlss.dll"), 'wb') as f:
        if dlss_download.status_code != 200:
            set_status("Failed to download DLSS from bedrock.graphics", level=logging.ERROR)
            raise RuntimeError(f"Failed to download DLSS: {dlss_download.status_code}")
        f.write(dlss_download.content)
    set_status("Downloaded DLSS binaries to temporary location", log=False)
    logger.info(f"Downloaded DLSS binaries to {temp_dir}")

    # 2. Delete the existing nvngx_dlss.dll file in the Minecraft installation directory <installationlocation>/data/renderer/dlss
    dlss_path = os.path.join(MinecraftInstallation.location, "nvngx_dlss.dll")
    try:
        set_status("Deleting existing DLSS file")
        if MinecraftInstallation.requires_iobit:
            unlocker.delete(dlss_path)
        else:
            regular_file_mgmt.delete(dlss_path)
    except Exception as e:
        set_status("Error occurred when deleting existing DLSS file in Minecraft Install", level=logging.WARNING, log=False)
        logger.error(f"Error occurred when deleting existing DLSS file in Minecraft Install: {e}")

    
    try:
        set_status("Copying DLSS to installation directory")
        if MinecraftInstallation.requires_iobit:
            unlocker.copy(os.path.join(temp_dir, "nvngx_dlss.dll"), MinecraftInstallation.location)
        else:
            regular_file_mgmt.copy(os.path.join(temp_dir, "nvngx_dlss.dll"), MinecraftInstallation.location)
    except Exception as e:
        set_status("Error occurred when copying DLSS to Minecraft Install", level=logging.WARNING)
        logger.error(f"Error occurred when copying DLSS to Minecraft Install: {e}")

def uninstall_betterrtx(MinecraftInstallation: MCI, text_info=None):
    """
    Uninstall BetterRTX for the specified Minecraft installation.
    :param MinecraftInstallation: The Minecraft installation object.
    """
    def set_status(msg, level=logging.INFO, log: bool=True):
        # logger.info(msg)
        if log:
            logger.log(level, msg)
        if text_info and hasattr(text_info, 'current') and text_info.current:
            text_info.current.value = msg
            text_info.current.update()
    set_status("Preparing uninstallation...")
    if MinecraftInstallation.requires_iobit:
        unlocker = IObitUnlocker()
    else:
        regular_file_mgmt = RegularFileManagement()
    
    logger.info(f"Uninstalling BetterRTX for {MinecraftInstallation.name} at {MinecraftInstallation.location}")

    # 1. Copy the materials.index.json file from the installation directory <installationlocation>/data/renderer/materials to a temporary location.
    materials_dir = os.path.join(MinecraftInstallation.location, "data", "renderer", "materials")
    rtxstub_path = os.path.join(materials_dir, "RTXStub.BetterRTX.material.bin")
    tonemapping_path = os.path.join(materials_dir, "RTXPostFX.Tonemapping.BetterRTX.material.bin")
    bloom_path = os.path.join(materials_dir, "RTXPostFX.Bloom.BetterRTX.material.bin")
    temp_path = os.path.join(tempfile.gettempdir(), "BetterRTX")
    temp_index_path = os.path.join(temp_path, "materials.index.json")

    if os.path.exists(temp_index_path):
        try:
            os.remove(temp_index_path)
        except Exception as e:
            logger.error(f"Failed to remove {temp_index_path}: {e}")
    
    set_status("Copying materials.index.json to temporary location")
    # if MinecraftInstallation.requires_iobit:
    #     try:
    #         unlocker.copy(os.path.join(materials_dir, "backup.materials.index.json"), temp_path)
    #     except Exception as e:
    #         set_status("Error occurred when copying materials.index.json to temporary location", level=logging.WARNING)
    #         logger.error(f"Error occurred when copying materials.index.json to temporary location: {e}")
    #         return
    # else:
    #     try:
    #         regular_file_mgmt.copy(os.path.join(materials_dir, "backup.materials.index.json"), temp_path)
    #     except Exception as e:
    #         set_status("Error occurred when copying materials.index.json to temporary location", level=logging.WARNING)
    #         logger.error(f"Error occurred when copying materials.index.json to temporary location: {e}")
    #         return
    if MinecraftInstallation.requires_iobit:
        try:
            unlocker.copy(os.path.join(materials_dir, "materials.index.json"), temp_path)
        except Exception as e:
            set_status("Error occurred when copying materials.index.json to temporary location", level=logging.WARNING)
            logger.error(f"Error occurred when copying materials.index.json to temporary location: {e}")
            return
    else:
        try:
            regular_file_mgmt.copy(os.path.join(materials_dir, "materials.index.json"), temp_path)
        except Exception as e:
            set_status("Error occurred when copying materials.index.json to temporary location", level=logging.WARNING)
            logger.error(f"Error occurred when copying materials.index.json to temporary location: {e}")
            return
    time.sleep(1) # bro just had to do so much work and deserves a break - and gets pissy if you don't let him
    # 2. Edit existing materials.index.json file to point to the original files.
    set_status("Modifying materials.index.json")
    # check if the file exists
    if not os.path.exists(temp_index_path):
        set_status("Error: materials.index.json file not found in temporary location", level=logging.ERROR)
        logger.error(f"Error: materials.index.json file not found in temporary location: {temp_index_path}")
        return
    with open(temp_index_path, 'r', encoding='utf-8') as f:
        index_data = json.load(f)
        # Only change the path, not the name
        for item in index_data["materials"]:
            if item["name"] == "RTXPostFX.Bloom":
                item["path"] = "RTXPostFX.Bloom"
            elif item["name"] == "RTXPostFX.ToneMapping":
                item["path"] = "RTXPostFX.Tonemapping"
            elif item["name"] == "RTXStub":
                item["path"] = "RTXStub"
    # Write the modified data back to the file
    with open(temp_index_path, 'w', encoding='utf-8') as f:
        json.dump(index_data, f, indent=3)
    
    # 3. Delete the existing materials.index.json file in the installation directory <installationlocation>/data/renderer/materials
    materials_index_path = os.path.join(materials_dir, "materials.index.json")
    set_status("Deleting existing materials.index.json file")
    time.sleep(3)
    if MinecraftInstallation.requires_iobit:
        try:
            unlocker.delete(materials_index_path)
        except Exception as e:
            set_status("Error occurred when deleting existing materials.index.json file in Minecraft Install", level=logging.WARNING)
            logger.error(f"Error occurred when deleting existing materials.index.json file in Minecraft Install: {e}")
    else:
        try:
            regular_file_mgmt.delete(materials_index_path)
        except Exception as e:
            set_status("Error occurred when deleting existing materials.index.json file in Minecraft Install", level=logging.WARNING)
            logger.error(f"Error occurred when deleting existing materials.index.json file in Minecraft Install: {e}")
    # 4. Copy the modified materials.index.json file to the installation directory <installationlocation>/data/renderer/materials
    set_status("Copying modified materials.index.json to installation directory")
    if MinecraftInstallation.requires_iobit:
        try:
            unlocker.copy(temp_index_path, materials_dir)
        except Exception as e:
            set_status("Error occurred when copying modified materials.index.json to installation directory", level=logging.WARNING)
            logger.error(f"Error occurred when copying modified materials.index.json to installation directory: {e}")
            return
    else:
        try:
            regular_file_mgmt.copy(temp_index_path, materials_dir)
        except Exception as e:
            set_status("Error occurred when copying modified materials.index.json to installation directory", level=logging.WARNING)
            logger.error(f"Error occurred when copying modified materials.index.json to installation directory: {e}")
            return
        
    # 5. Delete the existing RTXStub, Tonemapping, and Bloom files in the Minecraft installation directory <installationlocation>/data/renderer/materials
    set_status("Deleting BetterRTX binaries from installation directory")
    if MinecraftInstallation.requires_iobit:
        try:
            unlocker.delete(rtxstub_path)
            unlocker.delete(tonemapping_path)
            unlocker.delete(bloom_path)
        except Exception as e:
            set_status("Error occurred when deleting BetterRTX binaries from Minecraft Install", level=logging.WARNING)
            logger.error(f"Error occurred when deleting BetterRTX binaries from Minecraft Install: {e}")
    else:
        try:
            regular_file_mgmt.delete(rtxstub_path)
            regular_file_mgmt.delete(tonemapping_path)
            regular_file_mgmt.delete(bloom_path)
        except Exception as e:
            set_status("Error occurred when deleting BetterRTX binaries from Minecraft Install", level=logging.WARNING)
            logger.error(f"Error occurred when deleting BetterRTX binaries from Minecraft Install: {e}")
