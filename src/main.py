from mainGUI import MainApp
from flet import app, Page
import argparse
import traceback
# Run the app
def main(page: Page):
    page.window.width = 800
    page.window.height = 480
    page.window.minimizable = False
    page.window.resizable = False
    page.window.maximizable = False
    page.window.max_width = 800
    page.window.max_height = 480
    page.window.center()
    page.window.min_height = 480
    page.window.min_width = 800
    try:
        # Parse command line arguments
        parser = argparse.ArgumentParser(description="BetterRTX Installer")
        # add file handle i.e. when double clicking a .rtpack, a path will be passed in the installer. 
        parser.add_argument('file', nargs='?', type=str, help="Path to the .rtpack file to install")
        args = parser.parse_args()
        if args.file:
            print(f"File to install: {args.file}")
        file = args.file if args.file and args.file.endswith('.rtpack') else None

        MainApp(page, file)
    except Exception as e:
        traceback.print_exc()
        print(f"An error occurred: {e}")
        exit(1)
app(target=main)
