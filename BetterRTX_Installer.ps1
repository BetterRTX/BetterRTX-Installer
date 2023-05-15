function InstallerLogo {
    Write-Host " _______________________________________________________________________"
    Write-Host "|   ____           _     _                   _____    _______  __   __  |"
    Write-Host "|  |  _ \         | |   | |                 |  __ \  |__   __| \ \ / /  |"
    Write-Host "|  | |_) |   ___  | |_  | |_    ___   _ __  | |__) |    | |     \ V /   |"
    Write-Host "|  |  _ <   / _ \ | __| | __|  / _ \ | '__| |  _  /     | |      > <    |"
    Write-Host "|  | |_) | |  __/ | |_  | |_  |  __/ | |    | | \ \     | |     / . \   |"
    Write-Host "|  |____/   \___|  \__|  \__|  \___| |_|    |_|  \_\    |_|    /_/ \_\  |"
    Write-Host "|_____________________________QUICK INSTALLER___________________________|"
    Write-Host "                                                                       "
    Write-Host " _______________________________________________________________________ "
    Write-Host "|                                                                       |"
    Write-Host "|        This is v1.0.0 of the Quick Installer for Minecraft RTX        |"
    Write-Host "|           OFFICIAL BetterRTX INSTALLER | DO NOT DISTRIBUTE            |"
    Write-Host "|_______________________________________________________________________|"
    Write-Host "       Made by @-jason#2112 and  @NotJohnnyTamale#6389 On Discord        "
}

# Path: installer.ps1
# Sets Up File, App, And URL Locations
$iobu = "C:\Program Files (x86)\IObit\IObit Unlocker\IObitUnlocker.exe"
$installationLocation = Get-AppxPackage -Name "Microsoft.MinecraftUWP*" | Select-Object -ExpandProperty InstallLocation;
$materialsLocation = Join-Path $installationLocation "data\renderer\materials";
$tonemapping = Join-Path $materialsLocation "RTXPostFX.Tonemapping.material.bin";
$rtxStub = Join-Path $materialsLocation "RTXStub.material.bin";
$newTonemapping = Join-Path $PWD "RTXPostFX.Tonemapping.material.bin";
$newStub = Join-Path $PWD "RTXStub.material.bin";
# downloading from server
$url = "https://average-visor-eel.cyclic.app/"

$uninstallStub = "https://average-visor-eel.cyclic.app/uninstall/rtxstub"
$uninstallTonemapping = "https://average-visor-eel.cyclic.app/uninstall/rtxpostfx"
InstallerLogo
Write-Host ""

# checks for IOBit Unlocker
Write-Host "Checking for IObit Unlocker"
if (([System.IO.File]::Exists($iobu))){
    Write-Host "IObit Unlocker is installed, Continuing..."
} else {
    Write-Error "IObit Unlocker is not installed"
    Write-Error "Please install IObit Unlocker and try again"
    Write-Host "https://www.iobit.com/en/iobit-unlocker.php"
    Start-Sleep -Seconds 10
    exit
}
# checks for minecraft
Write-Host "Checking to see if Minecraft is installed"
if (-not(Test-Path -Path `"$installationLocation`" -PathType Container)){
    Write-Host "Minecraft is installed, Continuing..." 
} else {
    Write-Error "Minecraft is not installed"
    Write-Error "Please install Minecraft and try again"
    Write-Host "https://www.microsoft.com/en-us/p/minecraft-for-windows-10/9nblggh2jhxj"
    Start-Sleep -Seconds 10
    exit
}

# Shows the user the BetterRTX Quick Installer prompt
Start-Sleep -Seconds 2
Clear-Host
InstallerLogo
Write-Host ""



Write-Host ""
Write-Host ""
Write-Host "Choose installation method:"
Write-Host "1): Install from Server (Recommended)"
Write-Host "2): Install from Local Files (Advanced) (Assumes you have the latest files in the same directory as the installer)"
Write-Host "3): Uninstall BetterRTX"
Write-Host "4): Exit"
$selection = Read-Host -Prompt "Selection"

Clear-Host
InstallerLogo
Write-Host ""
Switch ($selection)
{
    1 { # Install from Server
        $releases = Invoke-WebRequest -URI $url -UseBasicParsing | ConvertFrom-Json;
        $i = 1
        foreach ($release in $releases)
        {
            $version = $release
            Write-Host "$($i)):  $($version.name)"
            $i++
        }
        $selectVersion = Read-Host -Prompt "Select Version"
        $version = $releases[$SelectVersion - 1]
        $newStubUrl = $version.stub
        $newToneMappingUrl = $version.tonemapping
        Write-Host ""
        Write-Host "Downloading Latest RTXStub.material.bin and RTXPostFX.Tonemapping.material.bin from server"
        Invoke-WebRequest -URI $newStubUrl -OutFile $newStub -UseBasicParsing;
        Invoke-WebRequest -URI $newToneMappingUrl -OutFile $newTonemapping -UseBasicParsing;
        Write-Host "Done Downloading. Continuing..."
        Write-Host ""
        continue
    }
    2 { # Install from Local Files
        continue
    }
    3 { # Uninstall
        Write-Host "Uninstalling BetterRTX"
        Write-Host "Downloading Latest Vanilla RTXStub.material.bin and RTXPostFX.Tonemapping.material.bin"
        Invoke-WebRequest -URI $uninstallStub -OutFile $newStub -UseBasicParsing;
        Invoke-WebRequest -URI $uninstallTonemapping -OutFile $newTonemapping -UseBasicParsing;
        if ([System.IO.File]::Exists($rtxStub)) {
            Write-Host "Removing Old RTXStub.material.bin" 
            Start-Process -FilePath $iobu -ArgumentList "/Delete `"$rtxStub`"" -Wait
        }
        if ([System.IO.File]::Exists($tonemapping)) {
            Write-Host "Removing Old RTXPostFX.Tonemapping.material.bin" 
            Start-Process -FilePath $iobu -ArgumentList "/Delete `"$tonemapping`"" -Wait
        }
        Write-Host "Inserting Vanilla RTXStub.material.bin"
        Start-Process -FilePath $iobu -ArgumentList "/Copy `"$newStub`" `"$materialsLocation`"" -Wait
        Write-Host "Inserting Vanilla RTXPostFX.Tonemapping.material.bin" 
        Start-Process -FilePath $iobu -ArgumentList "/Copy `"$newTonemapping`" `"$materialsLocation`"" -Wait
        Write-Host ""
        Write-Host "Done :("
        Write-Host "_______________________________________________________________________"
        Write-Host ""
        Write-Host ""
        Write-Host "We're Sorry to See You Go. If you have any suggestions or issues, create a message in the #betterrtx-help forum channel in the Minecraft RTX Server."
        Write-Host "Invite Link: https://discord.gg/minecraft-rtx-691547840463241267"
        Write-Host "Channel Link: https://discord.com/channels/691547840463241267/1101280299427561523"
        Start-Sleep -Seconds 10
        exit
    }
    4 {exit} # Quits the Installer
    default { # If the user enters an invalid option
        Write-Host "Option Not Found. Restart the Program and try again. Exiting..."
        Start-Sleep -Seconds 5
        exit
    }
}
# Checks to see if the user has a RTXStub.material.bin
if ([System.IO.File]::Exists($newStub)){
    Write-Host "RTXStub.material.bin is present, Continuing..."    
} else {
    Write-Host "RTXStub.material.bin is not present"
    Start-Sleep -Seconds 10
    exit
}
# Checks to see if the user has a RTXPostFX.Tonemapping.material.bin
if ([System.IO.File]::Exists($newTonemapping)){
    Write-Host "RTXPostFX.Tonemapping.material.bin is present, Continuing..." 
} else {
    Write-Host "RTXPostFX.Tonemapping.material.bin is not present"
    Start-Sleep -Seconds 10
    exit
}
Write-Host ""
Write-Host ""
# Installs BetterRTX
if ([System.IO.File]::Exists($rtxStub)) {
    Write-Host "Removing Old RTXStub.material.bin" 
    Start-Process -FilePath $iobu -ArgumentList "/Delete `"$rtxStub`"" -Wait
}
if ([System.IO.File]::Exists($tonemapping)) {
    Write-Host "Removing Old RTXPostFX.Tonemapping.material.bin" 
    Start-Process -FilePath $iobu -ArgumentList "/Delete `"$tonemapping`"" -Wait
}
Write-Host "Inserting BetterRTX RTXStub.material.bin"
Start-Process -FilePath $iobu -ArgumentList "/Copy `"$newStub`" `"$materialsLocation`"" -Wait
Write-Host "Inserting BetterRTX RTXPostFX.Tonemapping.material.bin" 
Start-Process -FilePath $iobu -ArgumentList "/Copy `"$newTonemapping`" `"$materialsLocation`"" -Wait

Write-Host ""
Write-Host "Done!"
Write-Host "_______________________________________________________________________"
Write-Host ""
Write-Host ""
Write-Host "Thanks For Installing BetterRTX! If you have any issues, use the #betterrtx-help forum channel in the Minecraft RTX Server!"
Write-Host "Invite Link: https://discord.gg/minecraft-rtx-691547840463241267"
Write-Host "Channel Link: https://discord.com/channels/691547840463241267/1101280299427561523"

# Waits for the user to be able to read the message before leaving
Start-Sleep -Seconds 10
exit