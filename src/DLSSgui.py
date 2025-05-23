
# NOTE: This file is not used in the current version of the code. It is a placeholder for future implementations.

# Select all above the line and delete to use this file
# Select all below the line and uncomment to use this file
# ----------------------------------------------------------
# import logging

# # Set up logger for this file

# logger = logging.getLogger(__name__)


# import flet as ft
# import os
# from .api import BedrockGraphicsAPI
# from .minecraftInstallations import getMinecraftInstallations, MinecraftInstallation
# from .files import download_install_BetterRTX_Bins
# # from .DLSSgui import DLSSPage
# class DLSSPage:

#     def __init__(self, page: ft.Page):
#         self.page = page
#         self.page.title = "BetterRTX Installer"
#         logger.info("MainApp initialized")
#         self.page.bgcolor = "#121212"
#         # self.page.window_icon = "src/assets/favicon.ico"
#         self.page.window.icon = "./assets/favicon.ico"
#         # Remove invalid setters for page.height and page.width
#         self.page.window.width = 800
#         self.page.window.height = 480
#         self.page.window.minimizable = False
#         self.page.window.resizable = False
#         self.page.window.maximizable = False
#         self.page.window.max_width = 800
#         self.page.window.max_height = 480
#         self.page.window.center()
#         self.page.window.min_height = 480
#         self.page.window.min_width = 800
#         self.page.padding = 0
#         self.page.spacing = 0
#         self.status_text_ref = ft.Ref[ft.TextField]()

        

#         self.page.controls.clear()
#         # Show loading spinner
#         self.loading_container = ft.Column([
#             ft.ProgressRing(),
#             ft.Text("Loading available options...", color="white")
#         ], alignment="center", horizontal_alignment="center")
        
#         self.page.add(
#             ft.Row(
#                 [self.loading_container],
#                 alignment="center",
#                 vertical_alignment="center",
#                 expand=True
#             )
#         )
#         self.page.update()

#         self.api = BedrockGraphicsAPI()
#         self.installations = []
#         self.selected_installation = None
#         self.selected_preset = None
#         self.install_button_ref = ft.Ref[ft.Button]()
#         self.preset_dropdown_ref = ft.Ref[ft.Dropdown]()
#         self.instance_dropdown_ref = ft.Ref[ft.Dropdown]()
#         # Start loading data in a background thread
#         self.page.run_task(self.load_data)

#     async def load_data(self):
#         try:
#             # Load installations and preset options concurrently if needed
#             self.installations = getMinecraftInstallations()
#             # options = await self.api.list_packs_names()  # Blocking call

#             # Replace spinner with UI
#             self.page.controls.clear()
#             # self.build_ui(options)
#             self.build_ui(["DLSS", "XESS", "FSR"])
#             self.page.update()
#         except Exception as e:
#             logger.error(f"Loading error: {e}")


#     def build_ui(self, preset_options):
#         def make_options():
#             fmt_list = []
#             for pack in preset_options:
#                 fmt_list.append(ft.DropdownOption(
#                     text=pack,
#                     style=ft.ButtonStyle(
#                         bgcolor="#1e1e1e",
#                         color="white",
#                         padding=20,
#                         shape=ft.RoundedRectangleBorder(radius=0)
#                     )
#                 ))
#             return fmt_list

#         self.menu_bar = ft.MenuBar(
#             expand=True,
#             style=ft.MenuStyle(
#                 alignment=ft.alignment.top_left,
#                 bgcolor="#1e1e1e",
#                 mouse_cursor={
#                     ft.ControlState.HOVERED: ft.MouseCursor.WAIT,
#                     ft.ControlState.DEFAULT: ft.MouseCursor.ZOOM_OUT,
#                 },
#                 padding=0,
#                 elevation=0,
#                 shadow_color=ft.Colors.TRANSPARENT,
#             ),
#             controls=[
#                 ft.SubmenuButton(
#                     content=ft.Text("Setup", color="white"),
#                     style=ft.ButtonStyle(
#                         bgcolor={ft.ControlState.HOVERED: ft.Colors.ORANGE},
#                         shape=ft.RoundedRectangleBorder(radius=0),
#                     ),
#                     controls=[
                        
#                 ft.SubmenuButton(
#                     content=ft.Text("Help", color="white"),
#                     on_open=lambda e: logger.info("Menu clicked"),
#                     on_close=lambda e: logger.info("Menu closed"),
#                     on_hover=lambda e: logger.info("Menu hovered"),
#                     style=ft.ButtonStyle(
#                         bgcolor={ft.ControlState.HOVERED: ft.Colors.ORANGE},
#                         shape=ft.RoundedRectangleBorder(radius=0),
#                     ),
#                     controls=[
#                         ft.MenuItemButton(
#                             content=ft.Text("Discord", color="white"),
#                             on_click=lambda e: os.startfile("https://discord.com/invite/minecraft-rtx-691547840463241267"),
#                             style=ft.ButtonStyle(
#                                 bgcolor={ft.ControlState.HOVERED: ft.Colors.ORANGE},
#                                 shape=ft.RoundedRectangleBorder(radius=0),
#                             ),
#                         ),
#                         ft.MenuItemButton(
#                             content=ft.Text("GitHub", color="white"),
#                             on_click=lambda e: os.startfile("https://github.com/betterrtx/betterrtx-installer"),
#                             style=ft.ButtonStyle(
#                                 bgcolor={ft.ControlState.HOVERED: ft.Colors.ORANGE},
#                                 shape=ft.RoundedRectangleBorder(radius=0),
#                             ),
#                         ),
#                     ]
#                 ),
#                 ft.Container(
#                     content=ft.Text(
#                         "Ready",
#                         ref=self.status_text_ref,
#                         color="white",
#                         size=12,
#                         weight="bold",
#                         text_align=ft.TextAlign.RIGHT,
#                         width=337,

#                         # height=40,  # REMOVE THIS LINE
#                     ),
#                     alignment=ft.alignment.center,  # CHANGE THIS LINE
#                     height=40,                      # ADD THIS LINE if not present
#                     padding=5,
#                     #radius
#                     border_radius=5,
#                     expand=False,
#                     margin=0,
#                     bgcolor="#353535",
#                 )
                
#             ],
#         )])

#         installation_dropdowns = []
#         for install in self.installations:
#             installation_dropdowns.append(ft.DropdownOption(
#                 text=install.name,
#                 style=ft.ButtonStyle(
#                     bgcolor="#1e1e1e",
#                     color="white",
#                     padding=20,
#                     shape=ft.RoundedRectangleBorder(radius=0)
#                 )
#             ))

#         def on_instance_change(e):
#             self.selected_installation = e.control.value
#             self.update_install_button_state()

#         self.instance_list = ft.Dropdown(
#             ref=self.instance_dropdown_ref,
#             options=installation_dropdowns,
#             value="",
#             color="white",
#             border_radius=5,
#             bgcolor="#1e1e1e",
#             border_color=ft.Colors.TRANSPARENT,
#             width=650,
#             on_change=on_instance_change
#         )

#         self.instance_list_container = ft.Container(
#             content=self.instance_list,
#             bgcolor="#1e1e1e",
#             padding=0
#         )

#         self.instance_card = ft.Container(
#             content=ft.Column([
#                 ft.Text("1. Select an Instance", size=32, weight="bold", color="white"),
#                 self.instance_list_container
#             ], spacing=10),
#             bgcolor=ft.Colors.TRANSPARENT,
#             border=ft.border.all(4, "white"),
#             border_radius=20,
#             padding=20,
#             margin=10,
#             width=704,
#             height=161,
#         )

#         def on_preset_change(e):
#             self.selected_preset = e.control.value
#             self.update_install_button_state()

#         self.preset_dropdown = ft.Dropdown(
#             ref=self.preset_dropdown_ref,
#             options=make_options(),
#             value=" ",
#             color="white",
#             border_radius=5,
#             bgcolor="#1e1e1e",
#             width=250,
#             on_change=on_preset_change
#         )

#         self.preset_dropdown_container = ft.Container(
#             content=self.preset_dropdown,
#             bgcolor="#1e1e1e",
#             height=41,
#             width=250,
#             padding=0,
#         )

#         self.preset_card = ft.Container(
#             content=ft.Column([
#                 ft.Text("2. Select a Preset", size=28, weight="bold", color="white"),
#                 ft.Container(
#                     content=self.preset_dropdown_container,
#                     alignment=ft.alignment.center,
#                     padding=ft.Padding(0, 10, 0, 0),
#                 )
#             ], spacing=0),
#             bgcolor=ft.Colors.TRANSPARENT,
#             border=ft.border.all(4, "white"),
#             border_radius=20,
#             padding=20,
#             margin=10,
#             width=323,
#             height=161
#         )
#         def on_install_button_click(e):
#             # Show a warning box
#             self.page.add(ft.AlertDialog(
#                 title=ft.Text("Note"),
#                 content=ft.Text("You may see up to 10 IOBit Unlocker popups. This is normal. Please click yes to all of the permission dialogs."),
#                 actions=[
#                     ft.TextButton("Cancel", on_click=lambda e: logger.info("Installation cancelled")),
#                     ft.TextButton("Continue", on_click=lambda e: logger.info("Installation started"))
#                 ],
#                 modal=True,
#             ))
#             # self.page.dialog.open = True
#             self.page.update()
#             if self.selected_installation and self.selected_preset:
#                 installation = next((inst for inst in self.installations if inst.name == self.selected_installation), None)
#                 preset = next((p for p in self.api.bins if p.name == self.selected_preset), None)
#                 if installation and preset:
#                     logger.info(f"Installing {preset.name} to {installation.name}")
#                     download_install_BetterRTX_Bins(preset, installation, text_info=self.status_text_ref)

#         self.install_button = ft.Container(
#             content=ft.Row([
#                 ft.Button(
#                     ref=self.install_button_ref,
#                     content=ft.Text("Install", size=32, weight="bold"),
#                     width=280,
#                     height=114,
#                     on_click=on_install_button_click,
#                     style=ft.ButtonStyle(
#                         bgcolor={
#                             ft.ControlState.DEFAULT: "#1e1e1e",
#                             ft.ControlState.DISABLED: "#232323"
#                         },
#                         color={
#                             ft.ControlState.DEFAULT: "white",
#                             ft.ControlState.DISABLED: ft.Colors.GREY_500
#                         },
#                         padding=0,
#                         shape=ft.RoundedRectangleBorder(radius=15)
#                     ),
#                     disabled=True
#                 )
#             ], alignment="center", vertical_alignment="center"),
#             bgcolor=ft.Colors.TRANSPARENT,
#             border=ft.border.all(4, "white"),
#             border_radius=20,
#             padding=18,
#             width=323,
#             height=161
#         )

#         lower_row = ft.Row([
#             self.preset_card,
#             self.install_button
#         ], alignment="center", spacing=50)


#         # Wrap menu_bar in a Row with expand=True and zero padding/margin to make it touch the top and fill width
#         self.page.add(
#             ft.Row([
#                 self.menu_bar
#             ], expand=False, alignment="start", vertical_alignment="start", spacing=0),
#             ft.Column(
#                 [
#                     ft.Container(),  # Top spacer (will expand)
#                     ft.Row([self.instance_card], alignment="center"),
#                     lower_row,
#                     ft.Container(),  # Bottom spacer (will expand)
#                 ],
#                 expand=True,
#                 alignment="center",
#                 spacing=0
#             )
#         )

#     def update_install_button_state(self):
#         # Check if both a preset and installation are selected (not empty or blank)
#         preset = self.preset_dropdown_ref.current.value if self.preset_dropdown_ref.current else None
#         instance = self.instance_dropdown_ref.current.value if self.instance_dropdown_ref.current else None
#         btn = self.install_button_ref.current
#         if btn:
#             btn.disabled = not (preset and preset.strip() and instance and instance.strip())
#             btn.update()


# # # Run the app
# # def main(page: ft.Page):
# #     MainApp(page)

# # ft.app(target=main)
