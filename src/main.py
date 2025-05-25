from mainGUI import MainApp
from flet import app, Page
import argparse

# Parse command line arguments
parser = argparse.ArgumentParser(description="BetterRTX Installer")
# add file handle i.e. when double clicking a .rtpack, a path will be passed in the installer. 
# parser.add_argument('file', nargs='?', type=str, help="Path to the .rtpack file to install")
args = parser.parse_args()
# if args.file:
#     print(f"File to install: {args.file}")
file = None
# Run the app
def main(page: Page):
    MainApp(page, file)

app(target=main)
