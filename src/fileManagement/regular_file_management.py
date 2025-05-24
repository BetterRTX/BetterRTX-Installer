import logging

# Set up logger for this file
logger = logging.getLogger(__name__)
import os
import subprocess
from src.fileManagement.filemgmt import FileManagement

class RegularFileManagement(FileManagement):
    """
    Class to manage regular file operations like delete, rename, move, and copy.
    This class is a placeholder for future implementations.
    """

    def __init__(self):
      pass

    def delete(self, file_path: str):
        """
        Delete a file or folder.
        :param file_path: Path to the file or folder to delete.
        """
        if os.path.exists(file_path):
            try:
                if os.path.isdir(file_path):
                    os.rmdir(file_path)
                else:
                    os.remove(file_path)
            except Exception as e:
                # raise RuntimeError(f"Failed to delete {file_path}: {e}")
                raise e
        else:
            raise FileNotFoundError(f"{file_path} does not exist.")
        return f"{file_path} deleted successfully."
    
    def rename(self, file_path: str, new_name: str):
        """
        Rename a file or folder.
        :param file_path: Path to the file or folder to rename.
        :param new_name: New name for the file or folder.
        """
        if os.path.exists(file_path):
            try:
                new_path = os.path.join(os.path.dirname(file_path), new_name)
                os.rename(file_path, new_path)
            except Exception as e:
                # raise RuntimeError(f"Failed to rename {file_path} to {new_name}: {e}")
                raise e
        else:
            raise FileNotFoundError(f"{file_path} does not exist.")
        return f"{file_path} renamed to {new_name} successfully."
    
    def move(self, file_path: str, new_path: str):
        """
        Move a file or folder.
        :param file_path: Path to the file or folder to move.
        :param new_path: New path for the file or folder.
        """
        if os.path.exists(file_path):
            try:
                os.rename(file_path, new_path)
            except Exception as e:
                # raise RuntimeError(f"Failed to move {file_path} to {new_path}: {e}")
                raise e
        else:
            raise FileNotFoundError(f"{file_path} does not exist.")
        return f"{file_path} moved to {new_path} successfully."

    def copy(self, file_path: str, new_path: str):
        """
        Copy a file or folder.
        :param file_path: Path to the file or folder to copy.
        :param new_path: New path for the copied file or folder.
        """
        if os.path.exists(file_path):
            try:
                if os.path.isdir(file_path):
                    subprocess.run(['xcopy', file_path, new_path, '/E', '/I'], check=True)
                else:
                    subprocess.run(['copy', file_path, new_path], check=True)
            except Exception as e:
                # raise RuntimeError(f"Failed to copy {file_path} to {new_path}: {e}")
                raise e
        else:
            raise FileNotFoundError(f"{file_path} does not exist.")
        return f"{file_path} copied to {new_path} successfully."
