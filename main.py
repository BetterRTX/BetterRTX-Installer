from src.main import MainApp
from flet import app, Page
# Run the app
def main(page: Page):
    MainApp(page)

app(target=main)
