#!/bin/bash

RTXStubRef="https://bedrock.graphics/api"
tempdir="/tmp"

# Generic strings
InvalidSelection="Invalid Selection."
MissingBinary="was not found! Install it using your distribution's package manager."
SelectPrompt="Selection: "
ContinuePrompt="Continue with the installation (Y/N)?"

STUB="RTXStub.material.bin"
TONEMAP="RTXPostFX.Tonemapping.material.bin"

# Is Uninstalling?
UNINSTALLBIT=false

# Using concatenated strings preserves logo behavior inside the script

Logo=$(cat <<-END
 _________________________________________________________________________
|    ____           _     _                   _____    _______  __   __   |
|   |  _ \         | |   | |                 |  __ \  |__   __| \ \ / /   |
|   | |_) |   ___  | |_  | |_    ___   _ __  | |__) |    | |     \ V /    |
|   |  _ <   / _ \ | __| | __|  / _ \ | '__| |  _  /     | |      > <     |
|   | |_) | |  __/ | |_  | |_  |  __/ | |    | | \ \     | |     / . \    |
|   |____/   \___|  \__|  \__|  \___| |_|    |_|  \_\    |_|    /_/ \_\   |
|_____________________________QUICK INSTALLER_____________________________|


 _________________________________________________________________________
|                                                                         |
|      This is the Linux version of the Quick Installer for BetterRTX     |
|          (UN)OFFICIAL BetterRTX INSTALLER | DO NOT DISTRIBUTE           |
|_________________________________________________________________________|

END
)

# Fancier logo if the user has Noto fonts installed.

Logo_Fancy=$(cat <<-END
╭────────────────────────────────────────────────────────────────╮
│     ╭────╮      ╭─╮ ╭─╮             ╭─────╮╭───────╮╭─╮╭─╮     │
│     │ ╭╮ │      │ ╰╮│ ╰╮            │ ╭─╮ │╰──╮ ╭──╯│ ││ │     │
│     │ ╰╯ ╰╮╭───╮│ ╭╯│ ╭╯╭───╮╭╭──╮  │ ╰─╯╭╯   │ │   ╰╮╰╯╭╯     │
│     │ ╭─╮ ││ ─ ││ │ │ │ │ ─ ││ ╭─╯  │ ╭─╮╰╮   │ │   ╭╯╭╮╰╮     │
│     │ ╰─╯ ││  ─╮│ ╰╮│ ╰╮│  ─╮│ │    │ │ │ │   │ │   │ ││ │     │
│     ╰─────╯╰───╯╰──╯╰──╯╰───╯╰─╯    ╰─╯ ╰─╯   ╰─╯   ╰─╯╰─╯     │
╰───────────────────────╢QUICK INSTALLER╟────────────────────────╯

╭────────────────────────────────────────────────────────────────╮
│                                                                │
│ This is the Linux version of the Quick Installer for BetterRTX │
│     (UN)OFFICIAL BetterRTX INSTALLER | DO NOT DISTRIBUTE       │
│                                                                │
╰────────────────────────────────────────────────────────────────╯

END
)

# Linux doesn't support UWP Applications. Add a note telling the user where to obtain Minecraft Education.
QuickNote="NOTE: Linux does not support UWP Applications such as Minecraft, Windows 10 Edition. You must obtain a copy of x64 Minecraft Education from the Microsoft Store. (PREVIEW APP NOT SUPPORTED!)"
QuickNote2="Details for Minecraft Education on Linux is provided at https://wiki.archlinux.org/title/minecraft#Minecraft_Education"

# Linux doesn't support Store App Locations. Ask the user for a pre-defined installation path.
DefaultInstallLocation="/home/$USER/Games/Minecraft Education/"
GetInstallLocation="Enter absolute path for your x64 Minecraft Education installation ($DefaultInstallLocation): "

InvalidInstallLocation="Installation Location is not a valid x64 Minecraft Education installation!"
InvalidArchitecture="Your Minecraft Education installation architecture is not x64!"
InstallLocationReadOnly="The Install location specified is read-only."

# Driver specific
InstallNoteAMD="NOTE: For AMD Radeon Graphics cards, You'll require the proprietary driver stack in order for BetterRTX to function properly. Otherwise, you may use the Open source drivers patch for BetterRTX."
InstallNoteIntel="NOTE: BetterRTX is currently broken on Intel Arc Graphics using Open source drivers. You'll need to use the Open source drivers patch for BetterRTX."

OpenSourcePatchCaveats=$(cat <<-END
WARNING: The open source drivers patch for BetterRTX Currently has some major caveats.
1) Broken Sun Azimuth.
2) No Rain puddles
3) Broken Entity emissives

END
)

# Install options

InstallOptions=$(cat <<-END



Choose Installation Method:
1) Install from Server (Recommended)
2) Install from Local Files (Advanced) (Assumes you have the latest files in the same directory as the installer)
3) Install the Open source drivers patch (For Mesa drivers) (NOT RECOMMENDED).
4) Uninstall BetterRTX

END
)

ReplacingStub="Replacing $STUB..."
ReplaceTonemap="Replacing $TONEMAP..."

# Download and Install prompts.

ServerList="Downloading Latest Version List from server..."
VersionPrompt="Select Version to install: "
DownloadingBins="Downloading Latest $STUB and $TONEMAP from server..."

StubFound="$STUB is present, Continuing..."
StubNotFound="$STUB is not present"
TonemappingFound="$TONEMAP is present, Continuing..."
TonemappingNotFound="$TONEMAP is not present, Exiting..."

ValidationFailed="is empty! Something probably went wrong while fetching files. Exiting..."

InstallPrompt=$(cat <<-END
Done :)
Thanks For Installing BetterRTX! If you have any issues, use the #betterrtx-help forum channel in the Minecraft RTX Server!
YOU STILL NEED AN RTX RESOURCE PACK FOR THIS TO WORK!

END
)

# Uninstall prompts

DownloadingVanilla="Downloading Latest Vanilla $STUB and $TONEMAP..."

UninstallPrompt=$(cat <<-END
Done :(
We're Sorry to See You Go. If you have any suggestions or issues, create a message in the #betterrtx-help forum channel in the Minecraft RTX Server.

END
)

Links=$(cat <<-END
Invite Link: https://discord.gg/minecraft-rtx-691547840463241267
Help Channel Link: https://discord.com/channels/691547840463241267/1101280299427561523

END
)

function start {

    if _checkForNotoFonts; then
        echo "$Logo_Fancy"
    else
        echo "$Logo"
    fi

    echo "$InstallOptions"

    while true; do
         echo "$SelectPrompt"; read Selection
        if _installMethod $Selection; then
            break
        else
            continue
        fi
    done

    if [ "$UNINSTALLBIT" = false ]; then
        if _checkForAMD; then
            echo $InstallNoteAMD
        fi

        if _checkForIntel; then
            echo $InstallNoteIntel
        fi
    fi

    echo $QuickNote
    echo $QuickNote2

    while true; do
        echo $GetInstallLocation; read DefaultInstallLocation
        if _checkInstallLocation $DefaultInstallLocation; then
            break
        else
            continue
        fi
    done

    _validateFiles
    _moveFiles

    if [ "$UNINSTALLBIT" = false ]; then
        echo "$InstallPrompt"
    else
        echo "$UninstallPrompt"
    fi

    echo "$Links"
}

function cleanUp {
    if [[ -s "$tempdir/$STUB" ]]; then
        rm "$tempdir/$STUB"
    fi

    if [[ -s "$tempdir/$TONEMAP" ]]; then
        rm "$tempdir/$TONEMAP"
    fi
}

function _moveFiles {
    echo $ReplacingStub
    mv "$tempdir/$STUB" "$DefaultInstallLocation/data/renderer/materials/$STUB"

    echo $ReplaceTonemap
    mv "$tempdir/$TONEMAP" "$DefaultInstallLocation/data/renderer/materials/$TONEMAP"
}

function _validateFiles {
    if [[ ! -s "$tempdir/$STUB" ]]; then
        echo "$tempdir/$STUB $ValidationFailed"
        exit 127
    fi

    if [[ ! -s "$tempdir/$TONEMAP" ]]; then
        echo "$tempdir/$TONEMAP $ValidationFailed"
        exit 127
    fi
}

function _checkForNotoFonts {
    NOTOFONTS_DIR="/usr/share/fonts/noto"

    if [ -d "$NOTOFONTS_DIR" ]; then
        return
    else
        false
    fi
}

function _checkForBinary {
    # Non-UNIX Standard binaries.
    if [ -f $1 ]; then
        return
    else
        echo "$1 $MissingBinary"
        exit 127
    fi
}

function _checkForAMD {
    _checkForBinary "/bin/lspci"
    _checkForBinary "/bin/xargs"
    _checkForBinary "/bin/grep"

    VGAOUTPUT=$(lspci | grep ' VGA ' | cut -d" " -f 1 | xargs -i lspci -v -s {})

    # Wildcard
    if [[ $VGAOUTPUT == *"AMD"* ]]; then
        return
    else
        false
    fi
}

function _checkForIntel {
    VGAOUTPUT=$(lspci | grep ' VGA ' | cut -d" " -f 1 | xargs -i lspci -v -s {})

    # Wildcard
    if [[ $VGAOUTPUT == *"Intel"* ]]; then
        return
    else
        false
    fi
}

function _checkInstallLocation {
    FILEINFO=

    _checkForBinary "/bin/file"

    if [[ ! -s "$1/Minecraft.Windows.exe" ]]; then
        echo $InvalidInstallLocation
        false
    else
        FILEINFO=$(file "$1/Minecraft.Windows.exe")
        if [[ ! $FILEINFO == *"x86-64"* ]]; then
            echo $InvalidArchitecture
            false
        fi
        if [[ ! -w "$1/data/renderer/materials/$STUB" ]]; then
            echo $InstallLocationReadOnly
            false
        fi
    fi
    return
}

function _installMethod {
    if [ $1 -eq 1 ]; then
        __downloadFromServer
        return
    elif [ $1 -eq 2 ]; then
        __installFromLocal
        return
    elif [ $1 -eq 3 ]; then
        __installPatched
        return
    elif [ $1 -eq 4 ]; then
        __uninstall
        return
    else
        echo $InvalidSelection
        false;
    fi
}

function __downloadFromServer {
    LIST=
    LISTLENGTH=
    SELECTEDVERSION=

    _checkForBinary "/bin/curl"
    echo $ServerList
    LIST=$(curl -s $RTXStubRef)

    _checkForBinary "/bin/jq"
    LISTLENGTH=$(echo $LIST | jq length)

    Itteration=0
    echo $VersionPrompt
    while [ $Itteration -lt $LISTLENGTH ]; do
        echo "$((Itteration + 1))) $(echo $LIST | jq --slurp -r ".[0].[${Itteration}].name")"
        ((Itteration++))
    done


    while true; do
        echo $SelectPrompt; read Selection
        if [ ! $Selection -gt $LISTLENGTH ]; then
            # Fetch stub
            echo "$DownloadingBins"
            SELECTEDVERSION=$(echo $LIST | jq --slurp -r ".[0].[$((Selection - 1))].stub")
            curl -s $SELECTEDVERSION -L -o "$tempdir/$STUB"

            # Fetch Tonemapping
            SELECTEDVERSION=$(echo $LIST | jq --slurp -r ".[0].[$((Selection - 1))].tonemapping")
            curl -s $SELECTEDVERSION -L -o "$tempdir/$TONEMAP"
            break
        else
            echo $InvalidSelection
            continue
        fi
    done
}

function __installFromLocal {
    # Fetch Stub
    if [[ -s "$(pwd)/$STUB" ]]; then
        echo $StubFound
        cp "$(pwd)/$STUB" "$tempdir/$STUB"
    else
        echo $StubNotFound
        exit 127
    fi

    # Fetch Tonemapping
    if [[ -s "$(pwd)/$TONEMAP" ]]; then
        echo $TonemappingFound
        cp "$(pwd)/$TONEMAP" "$tempdir/$TONEMAP"
    else
        echo $TonemappingNotFound
        exit 127
    fi
}

function __installPatched {
    echo "$OpenSourcePatchCaveats"

    while true; do
        echo $ContinuePrompt; read Answer
        Answer=$(echo "$Answer" | tr '[:upper:]' '[:lower:]')
        if [[ $Answer == "y" ]]; then
            break
        elif [[ $Answer == "n" ]]; then
            exit 0
        else
            echo $InvalidSelection
            continue
        fi
    done

    echo "$DownloadingBins"
    curl -s "https://raw.githubusercontent.com/Weather-OS/BRTXOnLinux/main/RTXStub.material.bin" -L -o "$tempdir/$STUB"
    curl -s "https://bedrock.graphics/api/uninstall/rtxpostfx" -L -o "$tempdir/$TONEMAP"
}

function __uninstall {
    echo "$DownloadingVanilla"
    curl -s "https://bedrock.graphics/api/uninstall/rtxstub" -L -o "$tempdir/$STUB"
    curl -s "https://bedrock.graphics/api/uninstall/rtxpostfx" -L -o "$tempdir/$TONEMAP"
    UNINSTALLBIT=true
}

start
cleanUp
