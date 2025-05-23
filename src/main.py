import logging
import sys
# Set up logger for this file
logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.DEBUG)
handler = logging.StreamHandler(stream=sys.stdout)
handler.setLevel(level=logging.DEBUG)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)
# hide debug messages from flet
logging.getLogger("flet").setLevel(logging.INFO)
import flet as ft
from src.MainGUI import MainApp

def main(page: ft.Page):
    MainApp(page)

logger.info("test")
ft.app(target=main)