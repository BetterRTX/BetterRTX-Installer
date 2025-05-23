import logging
import time
# Set up logger for this file
logger = logging.getLogger(__name__)
import tempfile
from .fileManagement.iobit_unlocker import IObitUnlocker
from .fileManagement.regular_file_management import RegularFileManagement
from .minecraftInstallations import MinecraftInstallation
import os
import json
from .api import betterrtx_preset
import requests
from flet import Text

def download_install_BetterRTX_Bins(bin: betterrtx_preset, MinecraftInstallation: MinecraftInstallation, text_info=None):
    """
    Download BetterRTX binaries for the specified Minecraft installation.
    :param MinecraftInstallation: The Minecraft installation object.
    """
    def set_status(msg):
        logger.info(msg)
        if text_info and hasattr(text_info, 'current') and text_info.current:
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
    def download_file(url, path):
        response = requests.get(url, timeout=30)
        if response.status_code == 200:
            with open(path, 'wb') as f:
                f.write(response.content)
        else:
            raise RuntimeError(f"Failed to download {url}: {response.status_code}")
    
    set_status("Downloading RTXStub")
    download_file(bin.rtxstub_url, rtxstub_path)
    set_status("Downloading Tonemapping")
    download_file(bin.tonemapping_url, tonemapping_path)
    set_status("Downloading Bloom")
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
        unlocker.copy(rtxstub_path, materials_dir)
        set_status("Copying Tonemapping to installation directory")
        unlocker.copy(tonemapping_path, materials_dir)
        set_status("Copying Bloom to installation directory")
        unlocker.copy(bloom_path, materials_dir)
    else:
        regular_file_mgmt = RegularFileManagement()
        set_status("Copying RTXStub to installation directory")
        regular_file_mgmt.copy(rtxstub_path, materials_dir)
        set_status("Copying Tonemapping to installation directory")
        regular_file_mgmt.copy(tonemapping_path, materials_dir)
        set_status("Copying Bloom to installation directory")
        regular_file_mgmt.copy(bloom_path, materials_dir)
    logger.info(f"Copied BetterRTX binaries to {materials_dir}")
    set_status("Copied BetterRTX binaries to installation directory")

    # 3. Copy <installationlocation>/data/renderer/materials/materials.index.json to a temporary location.
    materials_index_path = os.path.join(materials_dir, "materials.index.json")
    temp_index_path = os.path.join(temp_dir, "materials.index.json")
    # make temp index path
    os.makedirs(os.path.dirname(temp_index_path), exist_ok=True)
    if MinecraftInstallation.requires_iobit:
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
        # print(os.system("dir"))0
        # materials_temp_index_path = os.path.join(temp_dir, "materials.index.json")
        # os.rename(backup_temp_index_path, materials_temp_index_path)
    else:
        set_status("Copying materials.index.json to temporary location")
        regular_file_mgmt.copy(materials_index_path, temp_index_path)
        set_status("Renaming materials.index.json to backup.materials.index.json in game directory")
        regular_file_mgmt.rename(materials_index_path, "backup.materials.index.json")

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

    logger.info(f"Modified materials.index.json to point to BetterRTX binaries")
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
        unlocker.delete(materials_index_path)
        unlocker.copy(temp_index_path, materials_dir)
    else:
        regular_file_mgmt.copy(temp_index_path, materials_dir)
    logger.info(f"Copied modified materials.index.json to {materials_dir}")
    
    set_status("Done")
