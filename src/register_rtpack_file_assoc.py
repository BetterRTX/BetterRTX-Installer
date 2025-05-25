# import sys
# import os
# import winreg
# import ctypes

# def register_rtpack_file_association():
#     # Path to your executable
#     exe_path = os.path.abspath(sys.argv[0])
#     # Use .exe if running from a script
#     if exe_path.endswith(".py"):
#         exe_path = exe_path.replace(".py", ".exe")
#     # Registry root
#     root = winreg.HKEY_CLASSES_ROOT
#     # 1. Associate .rtpack with a ProgID
#     with winreg.CreateKey(root, ".rtpack") as key:
#         winreg.SetValue(key, "", winreg.REG_SZ, "BetterRTX.rtpack")
#     # 2. Define the ProgID and open command
#     with winreg.CreateKey(root, "BetterRTX.rtpack") as key:
#         winreg.SetValue(key, "", winreg.REG_SZ, "BetterRTX RT Pack")
#         with winreg.CreateKey(key, "DefaultIcon") as icon_key:
#             winreg.SetValue(icon_key, "", winreg.REG_SZ, exe_path + ",0")
#         with winreg.CreateKey(key, r"shell\open\command") as cmd_key:
#             winreg.SetValue(cmd_key, "", winreg.REG_SZ, f'"{exe_path}" "%1"')
#     print("Registered .rtpack file association.")

# # Optional: Check for admin rights and re-run as admin if needed
# def is_admin():
#     try:
#         return ctypes.windll.shell32.IsUserAnAdmin()
#     except:
#         return False

# if __name__ == "__main__":
#     if not is_admin():
#         # Relaunch as admin
#         ctypes.windll.shell32.ShellExecuteW(
#             None, "runas", sys.executable, f'"{os.path.abspath(__file__)}"', None, 1
#         )
#         sys.exit()
#         register_rtpack_file_association()