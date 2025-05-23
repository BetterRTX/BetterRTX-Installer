import logging

# Set up logger for this file
logger = logging.getLogger(__name__)

from requests import get
import asyncio
import time
from dataclasses import dataclass

@dataclass
class betterrtx_preset:
    name: str
    uuid: str
    rtxstub_url: str
    tonemapping_url: str
    bloom_url: str

class BedrockGraphicsAPI:
    """
    A class to interact with the Bedrock Graphics API.
    """
    def __init__(self):
        """
        Initializes the BedrockGraphicsAPI with a base URL.

        :param base_url: The base URL for the API.
        """
        self.base_url = "https://bedrock.graphics/api"
        self.response = get(self.base_url)
        # time.sleep(20)
        data = self.response.json()
        self.status = self.response.status_code
        self.bins = []
        for pack in data:
            material_bin_obj = betterrtx_preset(
                name=pack['name'],
                uuid=pack['uuid'],
                rtxstub_url=pack['stub'],
                tonemapping_url=pack['tonemapping'],
                bloom_url=pack['bloom']
            )
            self.bins.append(material_bin_obj)

    async def list_packs_names(self):
        """
        Lists all available packs.

        :return: A list of packs.
        """
        packs = []
        pack: betterrtx_preset
        for pack in self.bins:
            packs.append(pack.name)
        return packs
    
if __name__ == "__main__":
    api = BedrockGraphicsAPI()
    logger.info(asyncio.run(api.list_packs_names()))