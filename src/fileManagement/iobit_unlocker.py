
import logging
import subprocess


import os
import glob
from fileManagement.filemgmt import FileManagement

# Set up logger for this file
logger = logging.getLogger(__name__)

class IObitUnlocker(FileManagement):

    def __init__(self):
        self.startapp = self._get_startapp()
        logger.info(f"Startapp path: {self.startapp}")

    def _get_startapp(self):
        start_menu_paths = [
            os.path.expandvars(r'%APPDATA%\\Microsoft\\Windows\\Start Menu\\Programs'),
            os.path.expandvars(r'%PROGRAMDATA%\\Microsoft\\Windows\\Start Menu\\Programs')
        ]
        for base in start_menu_paths:
            pattern = os.path.join(base, '**', 'IObit Unlocker.lnk')
            matches = glob.glob(pattern, recursive=True)
            if matches:
                return matches[0]  # Return the first found shortcut path
        return None
    
    def _run_unlocker(self, command: str, paths: list, extra: list = None):
        """
        Run IObitUnlocker.exe with the given command, option, and paths.
        command: /None, /Delete, /Rename, /Move, /Copy
        option: /Normal or /Advanced
        paths: list of file/folder paths (strings)
        extra: for /Rename, /Move, /Copy, supply new names/paths as extra list
        """
        # exe_path = self.get_exe_path()
        exe_path = self.startapp
        logger.info(f"Executable path: {exe_path}")
        pathstr = " ".join([f"'{path}'" for path in paths])
        if not exe_path:
            raise FileNotFoundError("IObitUnlocker.exe not found.")
        # args = [exe_path, command, option]
        extrastr = " ".join([f"'{extra}'" for extra in extra]) if extra else ""
        args = f"powershell -Command & '{exe_path}' {command} {pathstr} {extrastr} /Wait"
        # args.extend(paths)
        # if extra:
        #     args.extend(extra)
        # args.append("/Wait")
        try:
            logger.info(f"Running command: {' '.join(args)}")
            result = subprocess.run(args, capture_output=True, text=True, check=False, creationflags=subprocess.CREATE_NO_WINDOW)
            return result
        except Exception as e:
            raise e

    def delete(self, file_path: str):
        """
        Delete a file or folder using IObit Unlocker.
        """
        result = self._run_unlocker("/Delete", [file_path])
        if result.returncode != 0:
            raise RuntimeError(f"Failed to delete {file_path}: {result.stderr}")
        return result.stdout
    
    def rename(self, file_path: str, new_name: str):
        """
        Rename a file or folder using IObit Unlocker.
        """
        result = self._run_unlocker("/Rename", [file_path], extra=[new_name])
        if result.returncode != 0:
            raise RuntimeError(f"Failed to rename {file_path} to {new_name}: {result.stderr}")
        return result.stdout
    
    def move(self, file_path: str, new_path: str):
        """
        Move a file or folder using IObit Unlocker.
        """
        result = self._run_unlocker("/Move", [file_path], extra=[new_path])
        if result.returncode != 0:
            raise RuntimeError(f"Failed to move {file_path} to {new_path}: {result.stderr}")
        return result.stdout
    
    def copy(self, file_path: str, new_path: str):
        """
        Copy a file or folder using IObit Unlocker.
        """
        result = self._run_unlocker("/Copy", [file_path], extra=[new_path])
        if result.returncode != 0:
            raise RuntimeError(f"Failed to copy {file_path} to {new_path}: {result.stderr}")
        return result.stdout
    
    def unlock(self, file_path: str):
        """
        Unlock a file or folder using IObit Unlocker.
        """
        result = self._run_unlocker("/Unlock", [file_path])
        if result.returncode != 0:
            raise RuntimeError(f"Failed to unlock {file_path}: {result.stderr}")
        return result.stdout
    
if __name__ == "__main__":
  logging.basicConfig(level=logging.INFO)
  IObitUnlocker = IObitUnlocker()
  logger.info(IObitUnlocker.startapp)
  IObitUnlocker.copy(["C:\\Users\\User\\Desktop\\test.txt"], "C:\\Users\\User\\Desktop\\test_copy.txt")