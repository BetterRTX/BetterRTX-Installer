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
logging.getLogger("flet").setLevel(logging.DEBUG)



# import flet as ft
from flet import Page, Text, Button, Dropdown, DropdownOption, Container, Row, Column, alignment, Colors, border, Ref, ProgressRing, MenuBar, SubmenuButton, MenuItemButton, ButtonStyle, RoundedRectangleBorder, TextField, MenuStyle, MouseCursor, ControlState, TextAlign, TextOverflow, Padding, Stack
import os
from api import BedrockGraphicsAPI
from minecraftInstallations import getMinecraftInstallations, MinecraftInstallation
from files import download_install_BetterRTX_Bins, install_dlss, uninstall_betterrtx, handle_drag_drop_files, uninstall_dlss
# from DLSSgui import DLSSPage
import flet_dropzone as ftd
from flet_dropzone.flet_dropzone import ListFiles, Dropzone
class MainApp:

    def __init__(self, page: Page, fileHandle: str = None):
        self.page = page
        self.page.title = "BetterRTX Installer"
        logger.info("MainApp initialized")
        self.page.bgcolor = "#121212"
        # self.page.window_icon = "src/assets/favicon.ico"
        self.page.window.icon = "assets/icon.ico"
        # Remove invalid setters for page.height and page.width
        self.page.window.width = 800
        self.page.window.height = 480
        self.page.window.minimizable = False
        self.page.window.resizable = False
        self.page.window.maximizable = False
        self.page.window.max_width = 800
        self.page.window.max_height = 480
        self.page.window.center()
        self.page.window.min_height = 480
        self.page.window.min_width = 800
        self.page.padding = 0
        self.page.spacing = 0
        self.status_text_ref = Ref[TextField]()
        self.status_text_startup_status = "Ready"
        self.status_text_startup_status_color = "white"
        self.filedrop_ref = Ref[Dropzone]()
        self.show_dropzone = False
        self.handle_file = fileHandle


        

        self.page.controls.clear()
        # Show loading spinner
        self.loading_container = Column([
            ProgressRing(),
            Text("Loading packages and presets...", color="white")
        ], alignment="center", horizontal_alignment="center")
        
        self.page.add(
            Row(
                [self.loading_container],
                alignment="center",
                vertical_alignment="center",
                expand=True
            )
        )
        self.page.update()

        self.api = BedrockGraphicsAPI()
        self.installations = []
        self.selected_installation = None
        self.selected_preset = None
        self.install_button_ref = Ref[Button]()
        self.preset_dropdown_ref = Ref[Dropdown]()
        self.instance_dropdown_ref = Ref[Dropdown]()
        # Start loading data in a background thread
        self.page.run_task(self.load_data)

    async def load_data(self):
        options = []
        try:
            # Load installations and preset options concurrently if needed
            self.installations = getMinecraftInstallations()
            if not self.handle_file:
                options = await self.api.list_packs_names()  # Blocking call
            else:
                options = ["Custom"]
        except Exception as e:
            self.status_text_startup_status = "Failed to get available presets from the API. Check your Internet Connection and restart the installer."
            self.status_text_startup_status_color = "red"
            logger.error(e)
        finally:
            # Replace spinner with UI
            self.page.controls.clear()
            self.build_ui(options)
            self.page.update()


    def build_ui(self, preset_options):
        def make_options():
            fmt_list = []
            for pack in preset_options:
                fmt_list.append(DropdownOption(
                    text=pack,
                    style=ButtonStyle(
                        bgcolor="#1e1e1e",
                        color="white",
                        padding=20,
                        shape=RoundedRectangleBorder(radius=0)
                    )
                ))
            return fmt_list
        def run_dlss_install():
            if self.selected_installation:
                installation = next((inst for inst in self.installations if inst.name == self.selected_installation), None)
                if installation:
                    logger.info(f"Installing DLSS to {installation.name}")
                    install_dlss(installation, text_info=self.status_text_ref)
                else:
                    logger.error("Installation not found")
                    self.status_text_ref.current.value = "Installation not found during DLSS install"
                    self.status_text_ref.current.color = "red"
                    self.status_text_ref.current.update()
        
        def run_dlss_uninstall():
            if self.selected_installation:
                installation = next((inst for inst in self.installations if inst.name == self.selected_installation), None)
                if installation:
                    logger.info(f"Uninstalling DLSS from {installation.name}")
                    uninstall_dlss(installation, text_info=self.status_text_ref)
                else:
                    logger.error("Installation not found")
                    self.status_text_ref.current.value = "Installation not found during DLSS uninstall"
                    self.status_text_ref.current.color = "red"
                    self.status_text_ref.current.update()

        def uninstall_betterrtx_menubtn():
            if self.selected_installation:
                installation = next((inst for inst in self.installations if inst.name == self.selected_installation), None)
                if installation:
                    logger.info(f"Uninstalling BetterRTX from {installation.name}")
                    uninstall_betterrtx(installation, text_info=self.status_text_ref)
                else:
                    logger.error("Installation not found")
                    self.status_text_ref.current.value = "Installation not found during BetterRTX uninstall"
                    self.status_text_ref.current.color = "red"
                    self.status_text_ref.current.update()
        self.menu_bar = MenuBar(
            expand=True,
            style=MenuStyle(
                alignment=alignment.top_left,
                bgcolor="#1e1e1e",
                mouse_cursor={
                    ControlState.HOVERED: MouseCursor.WAIT,
                    ControlState.DEFAULT: MouseCursor.ZOOM_OUT,
                },
                padding=0,
                elevation=0,
                shadow_color=Colors.TRANSPARENT,
            ),
            controls=[
                SubmenuButton(
                    content=Text("Setup", color="white"),
                    style=ButtonStyle(
                        bgcolor={ControlState.HOVERED: Colors.ORANGE},
                        shape=RoundedRectangleBorder(radius=0),
                    ),
                    controls=[
                        SubmenuButton(
                            content=Text("Launchers", color="white"),
                            style=ButtonStyle(
                                bgcolor={ControlState.HOVERED: Colors.ORANGE},
                                shape=RoundedRectangleBorder(radius=0),
                            ),
                            controls=[
                                MenuItemButton(
                                    content=Text("Download MC Launcher", color="white"),
                                    on_click=lambda e: os.startfile("https://github.com/MCMrARM/mc-w10-version-launcher"),
                                    style=ButtonStyle(
                                        bgcolor={ControlState.HOVERED: Colors.ORANGE},
                                        shape=RoundedRectangleBorder(radius=0),
                                    ),
                                ),
                                MenuItemButton(
                                    content=Text("Download Bedrock Launcher", color="white"),
                                    on_click=lambda e: os.startfile("https://github.com/BedrockLauncher/BedrockLauncher"),
                                    style=ButtonStyle(
                                        bgcolor={ControlState.HOVERED: Colors.ORANGE},
                                        shape=RoundedRectangleBorder(radius=0),
                                    ),
                                ),
                            ],
                        ),
                        # MenuItemButton(
                        #     content=Text("Backup", color="white"),
                        #     on_click=lambda e: logger.info("Menu Item 2 clicked"),
                        #     style=ButtonStyle(
                        #         bgcolor={ControlState.HOVERED: Colors.ORANGE},
                        #         shape=RoundedRectangleBorder(radius=0),
                        #     ),
                            
                        # ),
                        MenuItemButton(
                            content=Text("Uninstall", color={ControlState.DEFAULT: "white", ControlState.DISABLED: Colors.GREY_500}),
                            on_click=lambda e: uninstall_betterrtx_menubtn(),
                            style=ButtonStyle(
                                bgcolor={ControlState.HOVERED: Colors.ORANGE},
                                shape=RoundedRectangleBorder(radius=0),
                            ),
                            disabled=True
                        ),
                    ]
                ),
                SubmenuButton(
                    content=Text("Advanced", color="white"),
                    on_open=lambda e: logger.info("Menu clicked"),
                    on_close=lambda e: logger.info("Menu closed"),
                    on_hover=lambda e: logger.info("Menu hovered"),
                    style=ButtonStyle(
                        bgcolor={ControlState.HOVERED: Colors.ORANGE},
                        shape=RoundedRectangleBorder(radius=0),
                    ),
                    controls=[
                        MenuItemButton(
                            content=Text("Update DLSS", color={ControlState.DEFAULT: "white", ControlState.DISABLED: Colors.GREY_500}),
                            on_click=lambda e: run_dlss_install(),
                            style=ButtonStyle(
                                bgcolor={ControlState.HOVERED: Colors.ORANGE, ControlState.DEFAULT: "#1e1e1e", ControlState.DISABLED: "#232323"},
                                shape=RoundedRectangleBorder(radius=0),
                            ),
                            disabled=True
                        ),
                        MenuItemButton(
                            content=Text("Uninstall DLSS Update", color={ControlState.DEFAULT: "white", ControlState.DISABLED: Colors.GREY_500}),
                            on_click=lambda e: run_dlss_uninstall(),
                            style=ButtonStyle(
                                bgcolor={ControlState.HOVERED: Colors.ORANGE, ControlState.DEFAULT: "#1e1e1e", ControlState.DISABLED: "#232323"},
                                shape=RoundedRectangleBorder(radius=0),
                            ),
                            disabled=True
                        ),
                    ]
                ),
                SubmenuButton(
                    content=Text("Help", color="white"),
                    on_open=lambda e: logger.info("Menu clicked"),
                    on_close=lambda e: logger.info("Menu closed"),
                    on_hover=lambda e: logger.info("Menu hovered"),
                    style=ButtonStyle(
                        bgcolor={ControlState.HOVERED: Colors.ORANGE},
                        shape=RoundedRectangleBorder(radius=0),
                    ),
                    controls=[
                        MenuItemButton(
                            content=Text("Discord", color="white"),
                            on_click=lambda e: os.startfile("https://discord.com/invite/minecraft-rtx-691547840463241267"),
                            style=ButtonStyle(
                                bgcolor={ControlState.HOVERED: Colors.ORANGE},
                                shape=RoundedRectangleBorder(radius=0),
                            ),
                        ),
                        MenuItemButton(
                            content=Text("GitHub", color="white"),
                            on_click=lambda e: os.startfile("https://github.com/betterrtx/betterrtx-installer"),
                            style=ButtonStyle(
                                bgcolor={ControlState.HOVERED: Colors.ORANGE},
                                shape=RoundedRectangleBorder(radius=0),
                            ),
                        ),
                    ],
                    width=47
                ),
                MenuItemButton(
                    #                Re-Enable BetterRTX (SEE README)
                    content=Text("JSON Only Reinstallation (N/A, TBD)", color="white"),
                    on_click=lambda e: logger.info("Menu Item 4 clicked"),
                    on_hover=lambda e: logger.info("Menu Item 4 hovered"),
                    style=ButtonStyle(
                        bgcolor={ControlState.HOVERED: Colors.ORANGE},
                        shape=RoundedRectangleBorder(radius=0),
                    ),
                    disabled=True,
                    width=254
                ),
                # Container(
                #     content=Text(
                #         "Ready",
                #         color="white",
                #         size=15,
                #         weight="bold",
                #         # text_align=TextAlign.RIGHT,
                #         text_align=TextAlign.RIGHT,

                #         width=310,
                #         height=40,
                #     ),
                #     alignment=alignment.center_right,
                #     padding=0,
                #     # height=40,
                #     expand=False,
                #     margin=0,
                #     bgcolor=None,
                #     # Use alignment property for vertical centering in parent row
                #     # If not centered, try center_left or center_right
                # ),
                Container(
                    content=Text(
                        value=f"{self.status_text_startup_status}",
                        ref=self.status_text_ref,
                        color=f"{self.status_text_startup_status_color}",
                        size=12,
                        weight="bold",
                        text_align=TextAlign.RIGHT,
                        width=337,
                        max_lines=2,
                        overflow=TextOverflow.VISIBLE,
                        # height=40,  # REMOVE THIS LINE
                    ),
                    alignment=alignment.center,  # CHANGE THIS LINE
                    height=40,                      # ADD THIS LINE if not present
                    padding=5,
                    #radius
                    border_radius=5,
                    expand=False,
                    margin=0,
                    bgcolor="#353535",
                )
                
            ],
        )

        installation_dropdowns = []
        for install in self.installations:
            installation_dropdowns.append(DropdownOption(
                text=install.name,
                style=ButtonStyle(
                    bgcolor="#1e1e1e",
                    color="white",
                    padding=20,
                    shape=RoundedRectangleBorder(radius=0)
                )
            ))

        def on_instance_change(e):
            self.selected_installation = e.control.value
            self.update_install_button_state()
             

        self.instance_list = Dropdown(
            ref=self.instance_dropdown_ref,
            options=installation_dropdowns,
            value="",
            color="white",
            border_radius=5,
            bgcolor="#1e1e1e",
            border_color=Colors.TRANSPARENT,
            width=650,
            on_change=on_instance_change,
        )

        self.instance_list_container = Container(
            content=self.instance_list,
            bgcolor="#1e1e1e",
            padding=0
        )

        self.instance_card = Container(
            content=Column([
                Text("1. Select an Instance", size=32, weight="bold", color="white"),
                self.instance_list_container
            ], spacing=10),
            bgcolor=Colors.TRANSPARENT,
            border=border.all(4, "white"),
            border_radius=20,
            padding=20,
            margin=10,
            width=704,
            height=161,
        )

        def on_preset_change(e):
            self.selected_preset = e.control.value
            self.update_install_button_state()

        self.preset_dropdown = Dropdown(
            ref=self.preset_dropdown_ref,
            options=make_options() if self.handle_file is None else [
                DropdownOption(
                    text="Custom",
                    style=ButtonStyle(
                        bgcolor="#1e1e1e",
                        color="white",
                        padding=20,
                        shape=RoundedRectangleBorder(radius=0)
                    )
                )
            ],
            value="Custom" if self.handle_file else "",
            color="white",
            border_radius=5,
            bgcolor="#1e1e1e",
            width=250,
            on_change=on_preset_change,
            disabled=self.handle_file is not None,
        )

        self.preset_dropdown_container = Container(
            content=self.preset_dropdown,
            bgcolor="#1e1e1e",
            height=41,
            width=250,
            padding=0,
        )

        self.preset_card = Container(
            content=Column([
                Text("2. Select a Preset", size=28, weight="bold", color="white"),
                Container(
                    content=self.preset_dropdown_container,
                    alignment=alignment.center,
                    padding=Padding(0, 10, 0, 0),
                )
            ], spacing=0),
            bgcolor=Colors.TRANSPARENT,
            border=border.all(4, "white"),
            border_radius=20,
            padding=20,
            margin=10,
            width=323,
            height=161
        )
        def on_install_button_click(e):
            # Show a warning box
            # self.page.add(AlertDialog(
            #     title=Text("Note"),
            #     content=Text("You may see up to 10 IOBit Unlocker popups. This is normal. Please click yes to all of the permission dialogs."),
            #     actions=[
            #         TextButton("Cancel", on_click=lambda e: logger.info("Installation cancelled")),
            #         TextButton("Continue", on_click=lambda e: logger.info("Installation started"))
            #     ],
            #     modal=True,
            # ))
            # # self.page.dialog.open = True
            # self.page.update()
            if self.selected_preset == "Custom":
                if not self.handle_file:
                    self.status_text_ref.current.value = "No file handle provided for custom preset."
                    self.status_text_ref.current.color = "red"
                    self.status_text_ref.current.update()
                    return
                logger.info(f"Installing custom preset from file: {self.handle_file}")
                installation = next((inst for inst in self.installations if inst.name == self.selected_installation), None)
                if installation:
                    handle_drag_drop_files(installation, file_path=self.handle_file, text_info=self.status_text_ref)
            if self.selected_installation and self.selected_preset:
                installation = next((inst for inst in self.installations if inst.name == self.selected_installation), None)
                preset = next((p for p in self.api.bins if p.name == self.selected_preset), None)
                if installation and preset:
                    logger.info(f"Installing {preset.name} to {installation.name}")
                    download_install_BetterRTX_Bins(preset, installation, text_info=self.status_text_ref)
        print(f"Handle file: {self.handle_file}")
        self.selected_preset = "Custom" if self.handle_file else None
        self.install_button = Container(
            content=Row([
                Button(
                    ref=self.install_button_ref,
                    content=Text("Install", size=32, weight="bold"),
                    width=280,
                    height=114,
                    on_click=on_install_button_click,
                    style=ButtonStyle(
                        bgcolor={
                            ControlState.DEFAULT: "#1e1e1e",
                            ControlState.DISABLED: "#232323"
                        },
                        color={
                            ControlState.DEFAULT: "white",
                            ControlState.DISABLED: Colors.GREY_500
                        },
                        padding=0,
                        shape=RoundedRectangleBorder(radius=15)
                    ),
                    disabled=True
                )
            ], alignment="center", vertical_alignment="center"),
            bgcolor=Colors.TRANSPARENT,
            border=border.all(4, "white"),
            border_radius=20,
            padding=18,
            width=323,
            height=161
        )

        lower_row = Row([
            self.preset_card,
            self.install_button
        ], alignment="center", spacing=50)


        def on_dropzone_dropped(e: ListFiles):
            # Handle the dropped file
            print(f"File dropped: {e}")
            
            if not self.selected_installation:
                self.status_text_ref.current.value = "Please select an installation first."
                self.status_text_ref.current.color = "red"
                self.status_text_ref.current.update()
                return
            # get MinecraftInstallation object
            installation = next((inst for inst in self.installations if inst.name == self.selected_installation), None)
            if not installation:
                self.status_text_ref.current.value = "Installation not found."
                self.status_text_ref.current.color = "red"
                self.status_text_ref.current.update()
                return
            handle_drag_drop_files(installation, listFiles=e, text_info=self.status_text_ref)
            
            

        # All main UI content as a list
        main_content = [
            Row([
                self.menu_bar
            ], expand=False, alignment="start", vertical_alignment="start", spacing=0),
            Column(
                [
                    Container(),  # Top spacer (will expand)
                    Row([self.instance_card], alignment="center"),
                    lower_row,
                    Container(),  # Bottom spacer (will expand)
                ],
                expand=True,
                alignment="center",
                spacing=0,
            ),
        ]

        filedrop = Dropzone(
            ref=self.filedrop_ref,
            width=800,  # Cover the whole window
            height=480,
            visible=True,
            on_dropped=on_dropzone_dropped,
            content=Stack(main_content)
        )
        self.page.add(filedrop)
        # self.page.add(Stack(main_content))

    def update_install_button_state(self):
        # Check if both a preset and installation are selected (not empty or blank)
        preset = self.preset_dropdown_ref.current.value if self.preset_dropdown_ref.current else None
        instance = self.instance_dropdown_ref.current.value if self.instance_dropdown_ref.current else None
        btn = self.install_button_ref.current

        # Find the DLSS button in the menu bar (Advanced submenu, first item)
        advanced_submenu = None
        for ctrl in self.menu_bar.controls:
            if isinstance(ctrl, SubmenuButton) and hasattr(ctrl.content, 'value') and ctrl.content.value == "Advanced":
                advanced_submenu = ctrl
                break

        dlss_btn = None
        if advanced_submenu and advanced_submenu.controls:
            for item in advanced_submenu.controls:
                if isinstance(item, MenuItemButton) and hasattr(item.content, 'value') and "DLSS" in item.content.value:
                    dlss_btn = item
                    break
        dlss_uninstall_btn = None
        if advanced_submenu and advanced_submenu.controls:
            for item in advanced_submenu.controls:
                if isinstance(item, MenuItemButton) and hasattr(item.content, 'value') and "Uninstall DLSS Update" in item.content.value:
                    dlss_uninstall_btn = item
                    break

        uninstall_btn = None
        setup_submenu = None
        for ctrl in self.menu_bar.controls:
            if isinstance(ctrl, SubmenuButton) and hasattr(ctrl.content, 'value') and ctrl.content.value == "Setup":
                setup_submenu = ctrl
                break
        if self.menu_bar.controls:
            for item in setup_submenu.controls:
                if isinstance(item, MenuItemButton) and hasattr(item.content, 'value') and "Uninstall" in item.content.value:
                    uninstall_btn = item
                    break
        logger.info(f"Preset: {preset}, Instance: {instance}, Install Button: {btn}, DLSS Button: {dlss_btn}, Uninstall Button: {uninstall_btn}")
        if uninstall_btn:
            uninstall_btn.disabled = not (instance and instance.strip())
            uninstall_btn.update()

        if dlss_btn:
            dlss_btn.disabled = not (instance and instance.strip())
            dlss_btn.update()

        if btn:
            btn.disabled = not (preset and preset.strip() and instance and instance.strip())
            btn.update()

        if dlss_uninstall_btn:
            dlss_uninstall_btn.disabled = not (instance and instance.strip())
            dlss_uninstall_btn.update()

