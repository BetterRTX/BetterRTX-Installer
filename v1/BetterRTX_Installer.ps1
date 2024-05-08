<# The BetterRTX Installer is licensed under the GNU General Public License Version 3#>
param ($minecraftVersion, $filesLocation)
if ($True -eq (($null -ne $minecraftVersion) -and ($null -ne $filesLocation))) {
    Write-Host "Running Automated"
    # Automated Installation
    # Path: installer.ps1
    # Sets Up File, App, And URL Locations
    $iobu = "C:\Program Files (x86)\IObit\IObit Unlocker\IObitUnlocker.exe"
    $materialsLocation = Join-Path $installationLocation "data\renderer\materials";
    $tonemapping = Join-Path $materialsLocation "RTXPostFX.Tonemapping.material.bin";
    $rtxStub = Join-Path $materialsLocation "RTXStub.material.bin";
    $newTonemapping = Join-Path $filesLocation "RTXPostFX.Tonemapping.material.bin";
    $newStub = Join-Path $filesLocation "RTXStub.material.bin";
    Switch ($minecraftVersion) {
        $numeral1 {
            # Minecraft Bedrock Edition    
            $installationLocation = Get-AppxPackage -Name "Microsoft.MinecraftUWP*" | Select-Object -ExpandProperty InstallLocation;
            continue
        }
        $numeral2 {
            # Minecraft Preview Edition
            $installationLocation = Get-AppxPackage -Name "Microsoft.MinecraftWindowsBeta*" | Select-Object -ExpandProperty InstallLocation;
            continue
        }
        $numeral3 {
            # Minecraft Education
            $installationLocation = Get-AppxPackage -Name "Microsoft.MinecraftEducation*" | Select-Object -ExpandProperty InstallLocation;
            continue
        }
        $numeral4 {
            # Minecraft Education Preview
            $installationLocation = Get-AppxPackage -Name "Microsoft.MinecraftEducationPreview*" | Select-Object -ExpandProperty InstallLocation;
            continue
        }
    }

}
try {
    $config = Get-Content -Raw "config.json" -ErrorAction SilentlyContinue | ConvertFrom-Json -ErrorAction SilentlyContinue
    if ($null -eq $config) {
        throw
    }
}
catch {
    $configstr = '{ "dev":false, "url":"https://bedrock.graphics/api", "uninstall-rtxstub-endpoint":"https://bedrock.graphics/api/uninstall/rtxstub", "uninstall-rtxpostfx-endpoint":"https://bedrock.graphics/api/uninstall/rtxpostfx", "iobit-unlocker-location":"C:/Program Files (x86)/IObit/IObit Unlocker/IObitUnlocker.exe", "dlssURL":"https://bedrock.graphics/api/dlss"}' 
    $config = ConvertFrom-Json $configstr
}

$en_us = Data {
    ConvertFrom-StringData -StringData @'
logo1 =  \u200b_________________________________________________________________________
logo2 =  |    ____           _     _                   _____    _______  __   __   |
logo3 =  |   |  _ \\         | |   | |                 |  __ \\  |__   __| \\ \\ \/ \/   |
logo4 =  |   | |_) |   ___  | |_  | |_    ___   _ __  | |__) |    | |     \\ V \/    |
logo5 =  |   |  _ <   / _ \\ | __| | __|  / _ \\ | '__| |  _  /     | |      > <     |
logo6 =  |   | |_) | |  __/ | |_  | |_  |  __/ | |    | | \\ \\     | |     / . \\    |
logo7 =  |   |____\/   \\___|  \\__|  \\__|  \\___| |_|    |_|  \\_\\    |_|    \/_\/ \\_\\   |
logo8 =  |_____________________________QUICK INSTALLER_____________________________|
logo9 =                                                                         
logo10 =   \u200b_________________________________________________________________________
logo11 =  |                                                                         |
logo12 =  |         This is v1.1.3 of the Quick Installer for Minecraft RTX         |
logo12prerelease =  | This is v1.1.3 (Pre-release) of the Quick Installer for Minecraft RTX |
logo13 =  |            OFFICIAL BetterRTX INSTALLER | DO NOT DISTRIBUTE             |
logo14 =  |_________________________________________________________________________|

installerLocationChoice = Choose installation location:
installerLocationChoice1 = 1): Minecraft Bedrock Edition (Default)
installerLocationChoice2 = 2): Minecraft Preview Edition (Advanced) (Not Recommended as features can change before we can update BetterRTX for it)
installerLocationChoice3 = 3): Minecraft Education Edition (Windows Store) (Not Recommended as Education Edition will not be officially supported by BetterRTX)
installerLocationChoice4 = 4): Minecraft Education Preview Edition (Not Recommended as Education Edition will not be officially supported by BetterRTX)
installerLocationInvalid = Invalid Selection
installerLocationPrompt = Selection
installerLocationChoice1Numeral = 1
installerLocationChoice2Numeral = 2
installerLocationChoice3Numeral = 3
installerLocationChoice4Numeral = 4

checkingForIOBitUnlocker = Checking for IOBit Unlocker...
IOBitUnlockerCheckPass = IObit Unlocker is installed, Continuing...
IOBitUnlockerCheckFail = IObit Unlocker is not installed
IOBitUnlockerPleaseInstall = Please install IObit Unlocker and try again

checkingForMinecraft = Checking for Minecraft...
MinecraftCheckPass = Minecraft is installed, Continuing...
MinecraftCheckFail = Minecraft is not installed
MinecraftPleaseInstall = Please install Minecraft and try again

installationMethod = Choose installation method:
serverInstall = 1): Install from Server (Recommended)
localInstall = 2): Install from Local Files (Advanced) (Assumes you have the latest files in the same directory as the installer)
uninstall = 3): Uninstall BetterRTX
exit = 4): Exit
installationMethodInvalid = Invalid Selection
installationMethodPrompt = Selection
installationMethod1Numeral = 1
installationMethod2Numeral = 2
installationMethod3Numeral = 3
installationMethod4Numeral = 4
installSelectionKeyword = Select

downloadingFromServer = Downloading Latest Version List from server
versionSelect = Select the Preset to Install!
selectVersionPrompt = Select Version
downloadingBins = Downloading Latest RTXStub.material.bin and RTXPostFX.Tonemapping.material.bin from server
doneDownloading = Done Downloading. Continuing...

uninstalling = Uninstalling BetterRTX...
downloadingVanilla = Downloading Latest Vanilla RTXStub.material.bin and RTXPostFX.Tonemapping.material.bin

removingStub = Removing Old RTXStub.material.bin
removingTonemapping = Removing Old RTXPostFX.Tonemapping.material.bin
insertingVanillaStub = Inserting Vanilla RTXStub.material.bin
insertingVanillaTonemapping = Inserting Vanilla RTXPostFX.Tonemapping.material.bin

doneSadFace = Done :(
sorryToSeeYouGo = We're Sorry to See You Go. If you have any suggestions or issues, create a message in the #betterrtx-help forum channel in the Minecraft RTX Server.
installerOptionNotFound = Option Not Found. Restart the Program and try again. Exiting...
inviteLink = Invite Link: https://discord.gg/minecraft-rtx-691547840463241267
helpChannelLink = Help Channel Link: https://discord.com/channels/691547840463241267/1101280299427561523

stubFound = RTXStub.material.bin is present, Continuing...
stubNotFound = RTXStub.material.bin is not present
tonemappingFound = RTXPostFX.Tonemapping.material.bin is present, Continuing...
tonemappingNotFound = RTXPostFX.Tonemapping.material.bin is not present, Exiting...

insertingTonemapping = Inserting BetterRTX RTXPostFX.Tonemapping.material.bin
insertingStub = Inserting BetterRTX RTXStub.material.bin

doneHappyFace = Done :)
thanks = Thanks For Installing BetterRTX! If you have any issues, use the #betterrtx-help forum channel in the Minecraft RTX Server!
resourcePackNotice = YOU STILL NEED AN RTX RESOURCE PACK FOR THIS TO WORK!
'@
}
Import-LocalizedData -BaseDirectory (Join-Path -Path $PSScriptRoot -ChildPath Localized) -ErrorAction:SilentlyContinue -BindingVariable lang

<#
for each in en_us, if its not in $lang, add it
#>
foreach ($key in $en_us.Keys) {
    if ($null -eq $lang.$key) {
        $lang.$key = $en_us.$key
    }
}

#$ProgressPreference = 'SilentlyContinue'
$ProgressPreference = 'Continue'
Clear-Host
function InstallerLogo {
    Write-Host $lang.logo1
    Write-Host $lang.logo2
    Write-Host $lang.logo3
    Write-Host $lang.logo4
    Write-Host $lang.logo5
    Write-Host $lang.logo6
    Write-Host $lang.logo7
    Write-Host $lang.logo8
    Write-Host $lang.logo9
    Write-Host $lang.logo10
    Write-Host $lang.logo11
    Write-Host $lang.logo12
    #Write-Host $lang.logo12prerelease
    Write-Host $lang.logo13
    Write-Host $lang.logo14
}
Clear-Host
InstallerLogo
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host $lang.installerLocationChoice
Write-Host $lang.installerLocationChoice1
Write-Host $lang.installerLocationChoice2
Write-Host $lang.installerLocationChoice3
Write-Host $lang.installerLocationChoice4
$numeral1 = [int]$lang.installerLocationChoice1Numeral
$numeral2 = [int]$lang.installerLocationChoice2Numeral
$numeral3 = [int]$lang.installerLocationChoice3Numeral
$numeral4 = [int]$lang.installerLocationChoice4Numeral

$location = Read-Host -Prompt $lang.installerLocationPrompt
Switch ($location) {
    $numeral1 {
        # Minecraft Bedrock Edition    
        $installationLocation = Get-AppxPackage -Name "Microsoft.MinecraftUWP*" | Select-Object -ExpandProperty InstallLocation;
        continue
    }
    $numeral2 {
        # Minecraft Preview Edition
        $installationLocation = Get-AppxPackage -Name "Microsoft.MinecraftWindowsBeta*" | Select-Object -ExpandProperty InstallLocation;
        continue
    }
    $numeral3 {
        # Minecraft Preview Edition
        $installationLocation = Get-AppxPackage -Name "Microsoft.MinecraftEducation" | Select-Object -ExpandProperty InstallLocation;
        continue
    }
    $numeral4 {
        # Minecraft Preview Edition
        $installationLocation = Get-AppxPackage -Name "Microsoft.MinecraftEducationPreview" | Select-Object -ExpandProperty InstallLocation;
        continue
    }
    default {
        Write-Error $lang.installerLocationInvalid
        Start-Sleep -Seconds 5
        exit
    }
}
Clear-Host
# Path: installer.ps1
# Sets Up File, App, And URL Locations
$iobu = "C:\Program Files (x86)\IObit\IObit Unlocker\IObitUnlocker.exe"
$materialsLocation = Join-Path $installationLocation "data\renderer\materials";
$tonemapping = Join-Path $materialsLocation "RTXPostFX.Tonemapping.material.bin";
$manifestLocation = Join-Path $installationLocation "AppxManifest.xml"
$rtxStub = Join-Path $materialsLocation "RTXStub.material.bin";
$newTonemapping = Join-Path $PSScriptRoot "RTXPostFX.Tonemapping.material.bin";
$newStub = Join-Path $PSScriptRoot "RTXStub.material.bin";
# downloading from server
$url = $config.url #"https://average-visor-eel.cyclic.app/"

$uninstallStub = $config."uninstall-rtxstub-endpoint"#"https://average-visor-eel.cyclic.app/uninstall/rtxstub"
$uninstallTonemapping = $config."uninstall-rtxpostfx-endpoint" #"https://average-visor-eel.cyclic.app/uninstall/rtxpostfx"
InstallerLogo
Write-Host ""

# checks for IOBit Unlocker
Write-Host $lang.checkingForIObitUnlocker
if (([System.IO.File]::Exists($iobu))) {
    Write-Host $lang.IOBitUnlockerCheckPass
}
else {
    Write-Error $lang.IOBitUnlockerCheckFail
    Write-Error $lang.IOBitUnlockerPleaseInstall
    Write-Host "https://www.iobit.com/en/iobit-unlocker.php"
    Start-Sleep -Seconds 10
    exit
}

Clear-Host
InstallerLogo
Write-Host ""
# checks for minecraft
Write-Host $lang.checkingForMinecraft

if ($null -eq $installationLocation) {
    # make error shorter by only showing error message
    Write-Error $lang.minecraftCheckFail -Category ObjectNotFound
    Write-Error $lang.minecraftPleaseInstall -Category ObjectNotFound
    Write-Host "https://www.microsoft.com/en-us/p/minecraft-for-windows-10/9nblggh2jhxj"
    Start-Sleep -Seconds 10
    exit
}
if (-not(Test-Path -Path `"$installationLocation`" -PathType Container)) {
    Write-Host $lang.minecraftCheckPass
}
else {
    Write-Error $lang.minecraftCheckFail
    Write-Error $lang.minecraftPleaseInstall
    Write-Host "https://www.microsoft.com/en-us/p/minecraft-for-windows-10/9nblggh2jhxj"
    Start-Sleep -Seconds 10
    exit
}
Clear-Host
InstallerLogo
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host $lang.installationMethod
Write-Host $lang.serverInstall
Write-Host $lang.localInstall
Write-Host $lang.uninstall
Write-Host $lang.exit
$selection = Read-Host -Prompt $lang.installSelectionKeyword
$installationMethod1Numeral = [int]$lang.installationMethod1Numeral
$installationMethod2Numeral = [int]$lang.installationMethod2Numeral
$installationMethod3Numeral = [int]$lang.installationMethod3Numeral
$installationMethod4Numeral = [int]$lang.installationMethod4Numeral
Clear-Host
InstallerLogo
Write-Host ""
Switch ($selection) {
    $installationMethod1Numeral {
        # Install from Server

        Write-Host $lang.downloadingFromServer
        $releases = Invoke-WebRequest -URI $url -UseBasicParsing | ConvertFrom-Json;
        Write-Host $lang.versionSelect
        $i = 1
        foreach ($release in $releases) {
            $version = $release
            Write-Host "$($i)):  $($version.name)"
            $i++
        }
        $selectVersion = Read-Host -Prompt $lang.selectVersionPrompt
        $version = $releases[$SelectVersion - 1]
        $newStubUrl = $version.stub
        $newToneMappingUrl = $version.tonemapping

        #   TODO: Host a separate CDN for older tonemappings.
        #         Currently, the default tonemapper is used for all variations of BetterRTX

        $oldToneMappingUrl = "https://cdn.discordapp.com/attachments/1111388664468086836/1148375947129663528/RTXPostFX.Tonemapping.material.bin?ex=663c9db1&is=663b4c31&hm=afb0a9f03211f6ce9ed004207410a2543b32437be06d8c9dbc1b12b95f49ebe1&"

        Write-Host ""
        Write-Host $lang.downloadingBins
        Invoke-WebRequest -URI $newStubUrl -OutFile $newStub -UseBasicParsing;

        # Install an older tonemapping for older Minecraft Versions
        [xml]$minecraftManifest = Get-Content -Path $manifestLocation
        $installationVersion = $minecraftManifest.Package.Identity.Version.Substring(0, 7).Split(".")
        $releaseVer = [int]$installationVersion[0]
        $majorVer = [int]$installationVersion[1]
        $minorVer = [int]$installationVersion[2]
        if ($majorVer -eq 20) {
            if ($minorVer -ge 80) {
                Invoke-WebRequest -URI $oldToneMappingUrl -OutFile $newTonemapping -UseBasicParsing;
            } else {
                Invoke-WebRequest -URI $newToneMappingUrl -OutFile $newTonemapping -UseBasicParsing;
            }
        } else if ($majorVer -lt 20) {
            Invoke-WebRequest -URI $oldToneMappingUrl -OutFile $newTonemapping -UseBasicParsing;
        } else if ($majorVer -gt 20) {
            Invoke-WebRequest -URI $newToneMappingUrl -OutFile $newTonemapping -UseBasicParsing;
        } else {
            # Something went wrong. Fallback to newToneMappingUrl
            Invoke-WebRequest -URI $newToneMappingUrl -OutFile $newTonemapping -UseBasicParsing;
        }
        
        Write-Host $lang.doneDownloading
        Write-Host ""
        continue
    }
    $installationMethod2Numeral {
        # Install from Local Files
        continue
    }
    $installationMethod3Numeral {
        # Uninstall
        Write-Host $lang.uninstalling
        Write-Host $lang.downloadingvanilla
        Invoke-WebRequest -URI $uninstallStub -OutFile $newStub -UseBasicParsing;
        Invoke-WebRequest -URI $uninstallTonemapping -OutFile $newTonemapping -UseBasicParsing;
        if ([System.IO.File]::Exists($rtxStub)) {
            Write-Host $lang.removingStub
            Start-Process -FilePath $iobu -ArgumentList "/Delete `"$rtxStub`"" -Wait
        }
        if ([System.IO.File]::Exists($tonemapping)) {
            Write-Host $lang.removingTonemapping
            Start-Process -FilePath $iobu -ArgumentList "/Delete `"$tonemapping`"" -Wait
        }
        Write-Host $lang.insertingVanillaStub
        Start-Process -FilePath $iobu -ArgumentList "/Copy `"$newStub`" `"$materialsLocation`"" -Wait
        Write-Host $lang.insertingVanillaTonemapping 
        Start-Process -FilePath $iobu -ArgumentList "/Copy `"$newTonemapping`" `"$materialsLocation`"" -Wait
        Remove-Item $newTonemapping
        Remove-Item $newStub
        Write-Host ""
        Write-Host $lang.doneSadFace
        Write-Host "_______________________________________________________________________"
        Write-Host ""
        Write-Host ""
        Write-Host $lang.sorryToSeeYouGo
        Write-Host $lang.inviteLink
        Write-Host $lang.helpChannellink
        Start-Sleep -Seconds 10
        exit
    }
    $installationMethod4Numeral { exit } # Quits the Installer
    default {
        # If the user enters an invalid option
        Write-Error $lang.installerOptionNotFound
        Start-Sleep -Seconds 5
        exit
    }
}
# Checks to see if the user has a RTXStub.material.bin
if ([System.IO.File]::Exists($newStub)) {
    Write-Host $lang.stubFound
}
else {
    Write-Error $lang.stubNotFound
    Start-Sleep -Seconds 10
    exit
}
# Checks to see if the user has a RTXPostFX.Tonemapping.material.bin
if ([System.IO.File]::Exists($newTonemapping)) {
    Write-Host $lang.tonemappingFound
}
else {
    Write-Error $lang.tonemappingNotFound
    Start-Sleep -Seconds 10
    exit
}
Write-Host ""
Write-Host ""
# Installs BetterRTX
if ([System.IO.File]::Exists($rtxStub)) {
    Write-Host $lang.removingStub
    Start-Process -FilePath $iobu -ArgumentList "/Delete `"$rtxStub`"" -Wait
}
if ([System.IO.File]::Exists($tonemapping)) {
    Write-Host $lang.removingTonemapping
    Start-Process -FilePath $iobu -ArgumentList "/Delete `"$tonemapping`"" -Wait
}
Write-Host $lang.insertingStub
Start-Process -FilePath $iobu -ArgumentList "/Copy `"$newStub`" `"$materialsLocation`"" -Wait
Write-Host $lang.insertingTonemapping
Start-Process -FilePath $iobu -ArgumentList "/Copy `"$newTonemapping`" `"$materialsLocation`"" -Wait
if (-not($selection -eq 2)) {
    Remove-Item $newTonemapping
    Remove-Item $newStub
}
Start-Sleep -Seconds 3
Clear-Host
InstallerLogo
Write-Host ""



Write-Host ""
Write-Host $lang.doneHappyFace
Write-Host "_______________________________________________________________________"
Write-Host ""
Write-Host ""
Write-Host $lang.thanks
Write-Host $lang.resourcePackNotice
Write-Host $lang.inviteLink
Write-Host $lang.helpChannelLink
# Waits for the user to be able to read the message before leaving
Start-Sleep -Seconds 10
exit
