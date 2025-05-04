package iobit

import (
	"errors"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

var iobitPath string

// func FindIOBitUnlocker() {
// 	// try catch
// 	cmd := exec.Command("cmd", "/C", "dir /s /b C:\\Program Files\\IObit\\Unlocker\\Unlocker.exe")
// 	output, err := cmd.Output()
// 	if err != nil {
// 		log.Fatal(err)
// 	}
// 	log.Println(string(output))
// }


// Init - Find IObit Unlocker
func init() {
	// Get environment variable and build proper path
	programData := os.Getenv("ProgramData")
	if programData == "" {
			log.Println("ProgramData environment variable not found")
			return
	}
	
	// Build the correct path to the shortcut
	iobitLnkPath := filepath.Join(programData, "Microsoft", "Windows", "Start Menu", "Programs", "IObit Unlocker", "IObit Unlocker.lnk")
	
	// Check if the shortcut exists
	if _, err := os.Stat(iobitLnkPath); err == nil {
			// Use PowerShell to resolve the shortcut to the actual executable
			cmd := exec.Command("powershell", "-Command", 
					`(New-Object -ComObject WScript.Shell).CreateShortcut('`+iobitLnkPath+`').TargetPath`)
			output, err := cmd.Output()
			if err == nil && len(output) > 0 {
					iobitPath = strings.TrimSpace(string(output))
					log.Println("Found IObit Unlocker at:", iobitPath)
			} else {
					log.Println("Failed to resolve IObit Unlocker shortcut:", err)
			}
	} else {
			log.Println("IObit Unlocker not found in Start Menu:", err)
	}
}

func SetIObitUnlockerPath(path string) {
	iobitPath = path
}

func GetIObitUnlockerPath() string {
	return iobitPath
}

// Check if a file exists with detailed error handling
func fileExists(filePath string) (bool, error) {
	_, err := os.Stat(filePath)
	if err == nil {
			return true, nil
	}
	if errors.Is(err, os.ErrNotExist) {
			return false, nil
	}
	// File may or may not exist, but we got an error
	// (e.g., permission denied)
	return false, err
}

func Copy(currentFilePath string, newDirectoryPath string) error {
	// Check if IObit Unlocker exists
	if _, err := os.Stat(iobitPath); err != nil {
			return &IObitUnlockerNotFound{path: iobitPath}
	}

	// Check if CurrentFilePath is valid
	if _, err := os.Stat(currentFilePath); err != nil {
		return err
	}

	// Use PowerShell to execute IObit Unlocker with admin privileges
	psCmd := fmt.Sprintf(`Start-Process -FilePath "%s" -ArgumentList "/Copy", "%s", "%s" -Verb RunAs -Wait`, 
			iobitPath, currentFilePath, newDirectoryPath)
	
	cmd := exec.Command("powershell", "-Command", psCmd)
	
	// Connect to standard output to see any errors
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	
	if err := cmd.Run(); err != nil {
			fmt.Println("Failed to execute IObit Unlocker with elevation:", err)
			return err
	}
	
	return nil
}

// Delete - Delete a file using IObit Unlocker
func Delete(filePath string) error {
	// Check if IObit Unlocker exists
	if _, err := os.Stat(iobitPath); err != nil {
			return &IObitUnlockerNotFound{path: iobitPath}
	}
	
	// Check if filePath is valid
	if _, err := os.Stat(filePath); err != nil {
		return err
	}

	// Use PowerShell to execute IObit Unlocker with admin privileges
	psCmd := fmt.Sprintf(`Start-Process -FilePath "%s" -ArgumentList "/Delete", "%s" -Verb RunAs -Wait`, 
			iobitPath, filePath)
	
	cmd := exec.Command("powershell", "-Command", psCmd)
	
	// Connect to standard output to see any errors
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	
	if err := cmd.Run(); err != nil {
			fmt.Println("Failed to execute IObit Unlocker delete with elevation:", err)
			return err
	}
	
	return nil
}