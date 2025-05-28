import logging
import time
from fileManagement.iobit_unlocker import IObitUnlocker
from fileManagement.regular_file_management import RegularFileManagement
from minecraftInstallations import MinecraftInstallation as MCI
import os
import json
from api import betterrtx_preset
import requests
# import flet as ft
from flet import Ref, TextField
from flet_dropzone.flet_dropzone import ListFiles, ControlEvent
import zipfile
import shutil
# Set up logger for this file
logger = logging.getLogger(__name__)
def download_install_BetterRTX_Bins(bin: betterrtx_preset, minecraftInstallation: MCI, text_info: Ref[TextField]=None):
    download_BetterRTX_Bins(bin, text_info)
    install_BetterRTX_Bins(minecraftInstallation, text_info)

def download_BetterRTX_Bins(bbin: betterrtx_preset, text_info: Ref[TextField]=None):
    """
    Download BetterRTX binaries to the temp/BetterRTX directory only.
    """
    def set_status(msg, level=logging.INFO, log: bool=True):
        if log:
            logger.log(level, msg)
        if text_info and hasattr(text_info, 'current') and text_info.current:
            text_info.current.color = "white" if level == logging.INFO else "red"
            text_info.current.value = msg
            text_info.current.update()
    set_status("Preparing download...")
    logger.info(f"Downloading BetterRTX binaries to temp directory")
    temp_dir = os.getenv("FLET_APP_STORAGE_TEMP", None)
    # temp_dir = os.path.join(tempfile.gettempdir(), "BetterRTX")
    os.makedirs(temp_dir, exist_ok=True)
    rtxstub_path = os.path.join(temp_dir, "RTXStub.BetterRTX.material.bin")
    tonemapping_path = os.path.join(temp_dir, "RTXPostFX.Tonemapping.BetterRTX.material.bin")
    bloom_path = os.path.join(temp_dir, "RTXPostFX.Bloom.BetterRTX.material.bin")

    # Clean up any existing files
    for path in [rtxstub_path, tonemapping_path, bloom_path]:
        try:
            os.remove(path)
        except Exception:
            pass

    def download_file(url, path, name=None):
        response = requests.get(url, timeout=30)
        if response.status_code == 200:
            with open(path, 'wb') as f:
                f.write(response.content)
        else:
            set_status(f"Failed to download {name}", level=logging.ERROR)
            raise RuntimeError(f"Failed to download {url}: {response.status_code}")

    set_status("Downloading RTXStub")
    download_file(bbin.rtxstub_url, rtxstub_path, "RTXStub")
    set_status("Downloading Tonemapping")
    download_file(bbin.tonemapping_url, tonemapping_path, "Tonemapping")
    set_status("Downloading Bloom", level=logging.INFO)
    download_file(bbin.bloom_url, bloom_path)
    logger.info(f"Downloaded BetterRTX binaries to {temp_dir}")
    set_status("Downloaded BetterRTX binaries to temp directory")

def install_BetterRTX_Bins(MinecraftInstallation: MCI, text_info: Ref[TextField]=None):
    """
    Copy BetterRTX binaries from temp/BetterRTX to the Minecraft installation directory.
    """
    def set_status(msg, level=logging.INFO, log: bool=True):
        if log:
            logger.log(level, msg)
        if text_info and hasattr(text_info, 'current') and text_info.current:
            text_info.current.color = "white" if level == logging.INFO else "red"
            text_info.current.value = msg
            text_info.current.update()
    set_status("Preparing installation...")
    logger.info(f"Installing BetterRTX binaries to {MinecraftInstallation.name} at {MinecraftInstallation.location}")

    temp_dir = os.getenv("FLET_APP_STORAGE_TEMP", None)
    # temp_dir = os.path.join(tempfile.gettempdir(), "BetterRTX")
    rtxstub_path = os.path.join(temp_dir, "RTXStub.BetterRTX.material.bin")
    tonemapping_path = os.path.join(temp_dir, "RTXPostFX.Tonemapping.BetterRTX.material.bin")
    bloom_path = os.path.join(temp_dir, "RTXPostFX.Bloom.BetterRTX.material.bin")

    materials_dir = os.path.join(MinecraftInstallation.location, "data", "renderer", "materials")
    os.makedirs(materials_dir, exist_ok=True)

    

    # 1. Copy the downloaded files to the Minecraft installation directory <installationlocation>/data/renderer/materials
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

    # 1. Download the DLSS zip from the specified URL to a temporary location.
    # temp_dir = os.path.join(tempfile.gettempdir(), "BetterRTX", "DLSS")
    temp_dir = os.getenv("FLET_APP_STORAGE_TEMP", None)
    temp_dir = os.path.join(temp_dir, "DLSS")
    os.makedirs(temp_dir, exist_ok=True)
    temp_zip_path = os.path.join(temp_dir, "nvngx_dlss.zip")
    temp_dll_path = os.path.join(temp_dir, "nvngx_dlss.dll")
    # Clean up any old files in temp
    if os.path.exists(temp_zip_path):
        os.remove(temp_zip_path)
    if os.path.exists(temp_dll_path):
        os.remove(temp_dll_path)

    dlss_api_download = requests.get("https://bedrock.graphics/api/dlss", timeout=30)
    if dlss_api_download.status_code != 200:
        set_status("Failed to fetch DLSS API info from bedrock.graphics", level=logging.ERROR)
        raise RuntimeError(f"Failed to fetch DLSS API info: {dlss_api_download.status_code}")
    dlss_zip_url = dlss_api_download.json()["latest"]
    dlss_zip_download = requests.get(dlss_zip_url, timeout=30)
    if dlss_zip_download.status_code != 200:
        set_status("Failed to download DLSS zip from bedrock.graphics", level=logging.ERROR)
        raise RuntimeError(f"Failed to download DLSS zip: {dlss_zip_download.status_code}")
    with open(temp_zip_path, 'wb') as f:
        f.write(dlss_zip_download.content)

    # Extract the DLL from the zip
    with zipfile.ZipFile(temp_zip_path, 'r') as zip_ref:
        found = False
        for name in zip_ref.namelist():
            if name.lower().endswith("nvngx_dlss.dll"):
                zip_ref.extract(name, temp_dir)
                extracted_path = os.path.join(temp_dir, name)
                if extracted_path != temp_dll_path:
                    shutil.move(extracted_path, temp_dll_path)
                found = True
                break
        if not found:
            set_status("DLSS zip does not contain nvngx_dlss.dll", level=logging.ERROR)
            raise RuntimeError("DLSS zip does not contain nvngx_dlss.dll")

    set_status("Downloaded and extracted DLSS binaries to temporary location", log=False)
    logger.info(f"Downloaded and extracted DLSS binaries to {temp_dir}")

    # 2. Delete the existing nvngx_dlss.dll and nvngx_dlss.zip file in the Minecraft installation directory
    dlss_dll_path = os.path.join(MinecraftInstallation.location, "nvngx_dlss.dll")
    try:
        set_status("Deleting existing DLSS files")
        if MinecraftInstallation.requires_iobit:
            unlocker.delete(dlss_dll_path)
        else:
            regular_file_mgmt.delete(dlss_dll_path)
    except Exception as e:
        set_status("Error occurred when deleting existing DLSS files in Minecraft Install", level=logging.WARNING, log=False)
        logger.error(f"Error occurred when deleting existing DLSS files in Minecraft Install: {e}")

    time.sleep(.25)
    try:
        set_status("Copying DLSS to installation directory")
        if MinecraftInstallation.requires_iobit:
            unlocker.copy(temp_dll_path, MinecraftInstallation.location)
            set_status("DLSS Update installed successfully", log=False)
        else:
            regular_file_mgmt.copy(temp_dll_path, MinecraftInstallation.location)
            set_status("DLSS Update installed successfully", log=False)
    except Exception as e:
        set_status("Error occurred when copying DLSS to Minecraft Install", level=logging.WARNING)
        logger.error(f"Error occurred when copying DLSS to Minecraft Install: {e}")

def uninstall_dlss(MinecraftInstallation: MCI, text_info=None):
    """
    Install DLSS for the specified Minecraft installation.
    :param MinecraftInstallation: The Minecraft installation object.
    """
    def set_status(msg, level=logging.INFO, log: bool=True):
        if log:
            logger.log(level, msg)
        if text_info and hasattr(text_info, 'current') and text_info.current:
            text_info.current.value = msg
            text_info.current.update()
    set_status("Preparing DLSS Update Uninstall...")
    if MinecraftInstallation.requires_iobit:
        unlocker = IObitUnlocker()
    else:
        regular_file_mgmt = RegularFileManagement()
    
    logger.info(f"Uninstalling DLSS for {MinecraftInstallation.name} at {MinecraftInstallation.location}")

    # 1. Download the DLSS zip from the specified URL to a temporary location.
    # temp_dir = os.path.join(tempfile.gettempdir(), "BetterRTX", "DLSS")
    temp_dir = os.getenv("FLET_APP_STORAGE_TEMP", None)
    temp_dir = os.path.join(temp_dir, "DLSS")
    os.makedirs(temp_dir, exist_ok=True)
    temp_zip_path = os.path.join(temp_dir, "nvngx_dlss.zip")
    temp_dll_path = os.path.join(temp_dir, "nvngx_dlss.dll")
    # Clean up any old files in temp
    if os.path.exists(temp_zip_path):
        os.remove(temp_zip_path)
    if os.path.exists(temp_dll_path):
        os.remove(temp_dll_path)

    dlss_api_download = requests.get("https://bedrock.graphics/api/dlss", timeout=30)
    if dlss_api_download.status_code != 200:
        set_status("Failed to fetch DLSS API info from bedrock.graphics", level=logging.ERROR)
        raise RuntimeError(f"Failed to fetch DLSS API info: {dlss_api_download.status_code}")
    dlss_zip_url = dlss_api_download.json()["default"]
    dlss_zip_download = requests.get(dlss_zip_url, timeout=30)
    if dlss_zip_download.status_code != 200:
        set_status("Failed to download DLSS zip from bedrock.graphics", level=logging.ERROR)
        raise RuntimeError(f"Failed to download DLSS zip: {dlss_zip_download.status_code}")
    with open(temp_zip_path, 'wb') as f:
        f.write(dlss_zip_download.content)

    # Extract the DLL from the zip
    with zipfile.ZipFile(temp_zip_path, 'r') as zip_ref:
        found = False
        for name in zip_ref.namelist():
            if name.lower().endswith("nvngx_dlss.dll"):
                zip_ref.extract(name, temp_dir)
                extracted_path = os.path.join(temp_dir, name)
                if extracted_path != temp_dll_path:
                    shutil.move(extracted_path, temp_dll_path)
                found = True
                break
        if not found:
            set_status("DLSS zip does not contain nvngx_dlss.dll", level=logging.ERROR)
            raise RuntimeError("DLSS zip does not contain nvngx_dlss.dll")

    set_status("Downloaded and extracted DLSS binaries to temporary location", log=False)
    logger.info(f"Downloaded and extracted DLSS binaries to {temp_dir}")

    # 2. Delete the existing nvngx_dlss.dll and nvngx_dlss.zip file in the Minecraft installation directory
    dlss_dll_path = os.path.join(MinecraftInstallation.location, "nvngx_dlss.dll")
    try:
        set_status("Deleting existing DLSS files")
        if MinecraftInstallation.requires_iobit:
            unlocker.delete(dlss_dll_path)
        else:
            regular_file_mgmt.delete(dlss_dll_path)
    except Exception as e:
        set_status("Error occurred when deleting existing DLSS files in Minecraft Install", level=logging.WARNING, log=False)
        logger.error(f"Error occurred when deleting existing DLSS files in Minecraft Install: {e}")

    time.sleep(.25)
    try:
        set_status("Copying DLSS to installation directory")
        if MinecraftInstallation.requires_iobit:
            unlocker.copy(temp_dll_path, MinecraftInstallation.location)
            set_status("DLSS Update uninstalled successfully", log=False)
        else:
            regular_file_mgmt.copy(temp_dll_path, MinecraftInstallation.location)
            set_status("DLSS Update uninstalled successfully", log=False)
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
    # temp_path = os.path.join(tempfile.gettempdir(), "BetterRTX")
    temp_path = os.getenv("FLET_APP_STORAGE_TEMP", None)
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
            return
    else:
        try:
            regular_file_mgmt.delete(rtxstub_path)
            regular_file_mgmt.delete(tonemapping_path)
            regular_file_mgmt.delete(bloom_path)
        except Exception as e:
            set_status("Error occurred when deleting BetterRTX binaries from Minecraft Install", level=logging.WARNING)
            logger.error(f"Error occurred when deleting BetterRTX binaries from Minecraft Install: {e}")
            return
    set_status("Done")

# def install_materials(MinecraftInstallation: MCI, text_info=None):
#     """
#     Install materials for the specified Minecraft installation.
#     :param MinecraftInstallation: The Minecraft installation object.
#     """
#     def set_status(msg, level=logging.INFO, log: bool=True):
#         # logger.info(msg)
#         if log:
#             logger.log(level, msg)
#         if text_info and hasattr(text_info, 'current') and text_info.current:
#             text_info.current.value = msg
#             text_info.current.update()
#     set_status("Preparing materials installation...")
#     logger.info(f"Installing materials for {MinecraftInstallation.name} at {MinecraftInstallation.location}")
#     set_status("Done")

#     """
#     Install a single material for the specified Minecraft installation.
#     :param MinecraftInstallation: The Minecraft installation object.
#     :param material_path: The path to the material file to install.
#     """
#     def set_status(msg, level=logging.INFO, log: bool=True):
#         # logger.info(msg)
#         if log:
#             logger.log(level, msg)
#         if text_info and hasattr(text_info, 'current') and text_info.current:
#             text_info.current.value = msg
#             text_info.current.update()
#     set_status("Preparing single material installation...")
#     logger.info(f"Installing single material {material_path} for {MinecraftInstallation.name} at {MinecraftInstallation.location}")

#     set_status("Done")


def handle_drag_drop_files(MinecraftInstallation: MCI, listFiles: ListFiles = None, file_path: str = None, text_info=None):
    """
    Handle drag and drop of files.
    :param MinecraftInstallation: The Minecraft installation object.
    :param files: List of files dropped.
    """
    def set_status(msg, level=logging.INFO, log: bool=True):
        # logger.info(msg)
        if log:
            logger.log(level, msg)
        if text_info and hasattr(text_info, 'current') and text_info.current:
            text_info.current.value = msg
            text_info.current.update()
    set_status("Preparing drag and drop...")
    filePathList = []
    if not listFiles and not file_path:
        set_status("No files were dropped.", level=logging.ERROR)
        return
    elif listFiles and file_path:
        set_status("Both ListFiles and file_path were provided. Please provide only one.", level=logging.ERROR)
        return
    elif not listFiles and file_path:
        # If only file_path is provided, convert it to a ListFiles object
        filePathList = [file_path]  # Assuming file_path is a single file path string
    elif listFiles and not file_path:
        filePathList = listFiles.files
    logger.info(f"Handling drag and drop files for {MinecraftInstallation.name} at {MinecraftInstallation.location}")

    # Enforce file count and type rules
    if len(filePathList) == 1:
        file = filePathList[0]
        if not (file.endswith(".zip") or file.endswith(".rtpack")):
            set_status("You must drag and drop a single .zip or .rtpack file.", level=logging.ERROR)
            return
    elif len(filePathList) == 3:
        # Must be exactly the three required .material.bin files
        required_names = {
            "RTXStub.material.bin",
            "RTXPostFX.Bloom.material.bin",
            "RTXPostFX.Tonemapping.material.bin"
        }
        dropped_names = {os.path.basename(f) for f in filePathList}
        if dropped_names != required_names:
            set_status("You must drag and drop exactly these 3 files: RTXStub.material.bin, RTXPostFX.Bloom.material.bin, and RTXPostFX.Tonemapping.material.bin.", level=logging.ERROR)
            return
    else:
        set_status("You must drag and drop either a single .zip/.rtpack or exactly 3 required .material.bin files.", level=logging.ERROR)
        return
    
    for file in filePathList:
        if not file.endswith(".material.bin") and not file.endswith(".zip") and not file.endswith(".rtpack"):
            set_status("File is not a zip, rtpack, or material.bin file", level=logging.ERROR)
            return
        
        if file.endswith(".rtpack") or file.endswith(".zip"):
            set_status("Copying rtpack to temporary location")
            # temp_dir = os.path.join(tempfile.gettempdir(), "BetterRTX")
            temp_dir = os.getenv("FLET_APP_STORAGE_TEMP", None)
            os.makedirs(temp_dir, exist_ok=True)
            temp_rtpack_dir = os.path.join(temp_dir, "pack")
            # delete tempdir contents if it exists
            if os.path.exists(temp_rtpack_dir):
                for item in os.listdir(temp_rtpack_dir):
                    item_path = os.path.join(temp_rtpack_dir, item)
                    if os.path.isfile(item_path):
                        os.remove(item_path)
                    elif os.path.isdir(item_path):
                        shutil.rmtree(item_path)

            os.makedirs(temp_dir, exist_ok=True)
            
            temp_path = os.path.join(temp_dir, "packToInstall.zip")
            if os.path.exists(temp_path):
                os.remove(temp_path)
            with open(temp_path, 'wb') as f:
                with open(file, 'rb') as f2:
                    f.write(f2.read())
            set_status("Unzipping rtpack")
            with zipfile.ZipFile(temp_path, 'r') as zip_ref:
                zip_ref.extractall(temp_rtpack_dir)
            # recurse for all RTXPostFX.Tonemapping.material.bin files, RTXPostFX.Bloom.material.bin files, and RTXStub.material.bin files
            all_bin_file_paths = []
            for root, dirs, files in os.walk(temp_rtpack_dir):
                for file in files:
                    if file.endswith(".material.bin"):
                        all_bin_file_paths.append(os.path.join(root, file))
            if not all_bin_file_paths:
                set_status("No material.bin files found in rtpack", level=logging.ERROR)
                return
            # remove non RTXPostFX.Tonemapping.material.bin, RTXPostFX.Bloom.material.bin, and RTXStub.material.bin files
            filtered_bin_file_paths = []
            for bin_file in all_bin_file_paths:
                if "RTXPostFX.Tonemapping.material.bin" in bin_file or "RTXPostFX.Bloom.material.bin" in bin_file or "RTXStub.material.bin" in bin_file:
                    filtered_bin_file_paths.append(bin_file)
            if not filtered_bin_file_paths:
                set_status("No valid material.bin files found in rtpack", level=logging.ERROR)
                return
            # copy the filtered_bin_file_paths to the temp_dir directory where name.material.bin is now name.BetterRTX.material.bin
            for bin_file in filtered_bin_file_paths:
                base = os.path.basename(bin_file)
                new_base = base.replace(".material.bin", ".BetterRTX.material.bin")
                new_path = os.path.join(temp_dir, new_base)
                if os.path.exists(new_path):
                    os.remove(new_path)
                # os.rename(bin_file, new_path)
                shutil.move(bin_file, new_path)
            set_status("Installing BetterRTX binaries from rtpack")
            install_BetterRTX_Bins(MinecraftInstallation, text_info)
            return
        elif file.endswith(".material.bin"):
            set_status("Copying material.bin to temporary location")
            # temp_dir = os.path.join(tempfile.gettempdir(), "BetterRTX")
            temp_dir = os.getenv("FLET_APP_STORAGE_TEMP", None)
            os.makedirs(temp_dir, exist_ok=True)
            base = os.path.basename(file)
            new_base = base.replace(".material.bin", ".BetterRTX.material.bin")
            temp_path = os.path.join(temp_dir, new_base)
            print(f"Deleting existing temp file at {temp_path} with name {os.path.basename(file)}")
            if os.path.exists(temp_path):
                os.remove(temp_path)
            with open(temp_path, 'wb') as f:
                with open(file, 'rb') as f2:
                    f.write(f2.read())
            set_status("Installing BetterRTX binaries from material.bin")
    install_BetterRTX_Bins(MinecraftInstallation, text_info)
