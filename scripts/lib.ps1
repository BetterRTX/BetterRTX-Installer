$comMojang = "$env:LOCALAPPDATA\Packages\Microsoft.MinecraftUWP_8wekyb3d8bbwe\LocalState\games\com.mojang"
$previewComMojang = "$env:LOCALAPPDATA\Packages\Microsoft.MinecraftWindowsBeta_8wekyb3d8bbwe\LocalState\games\com.mojang"

# $root = "$env:USERPROFILE\BetterRTX"
$root = ".\BetterRTX"
$comMojangBackup = "$root\backup\comMojang.zip"
$previewComMojangBackup = "$root\backup\previewComMojang.zip"

function WriteSettings {
    $settings = @{
        # Default path is user profile
        "SideloadInstallPath" = "$root\MinecraftRTX"
    }
    $settings | ConvertTo-Json | Out-File -FilePath "$root\settings.json"
}

function ReadSettings {
    $settings = Get-Content -Raw -Path "$root\settings.json" | ConvertFrom-Json
    return $settings
}

function GetMinecraftLocations {
    $minecraftLocations = @()

    Get-AppxPackage -Name "Microsoft.Minecraft*" | Select-Object -ExpandProperty InstallLocation | ForEach-Object {
        $minecraftLocations += @{
            path       = $_
            sideloaded = $_.StartsWith($root)
        }
    }

    return $minecraftLocations
}

function BackupMinecraft {
    if (-not (Test-Path "$root\backup")) {
        New-Item -ItemType Directory -Force -Path "$root\backup"
    }

    $dest = $comMojangBackup
    $ProgressBar.Visible = $true
    $ProgressBar.Value = 0

    Get-AppxPackage -Name "Microsoft.Minecraft*" | Select-Object -ExpandProperty Name | ForEach-Object {
        Write-Host "Backing up $($_)"
        $ProgressBar.Value += 25

        if ($_.Contains("Beta")) {
            $comMojang = $previewComMojang
            $dest = $previewComMojangBackup
        }

        Compress-Archive -Path $comMojang -DestinationPath $dest -Force
    }

    $ProgressBar.Value = 100

    return $dest
}

function RestoreMinecraft {
    $src = $comMojangBackup
    $ProgressBar.Visible = $true
    $ProgressBar.Value = 0

    if (-not (Test-Path $src) && -not (Test-Path $previewComMojangBackup)) {
        Write-Host "No backup found"
        return
    }

    Get-AppxPackage -Name "Microsoft.Minecraft*" | Select-Object -ExpandProperty Name | ForEach-Object {
        Write-Host "Restoring $($_)"
        $ProgressBar.Value += 25

        if ($_.Contains("Beta")) {
            $comMojang = $previewComMojang
            $src = "$root\backup\previewComMojang.zip"
        }

        Expand-Archive -Path $src -DestinationPath $comMojang -Force
    }

    $ProgressBar.Value = 100

    return $comMojang
}

function GetMinecraftProcessID {
    $processID = (Get-Process -Name "Minecraft.Windows" -ErrorAction SilentlyContinue).Id

    if ($null -eq $processID) {
        Write-Host "Minecraft RTX is not running. Attempting to launch Minecraft"
        Start-Process "minecraft:"
        Start-Sleep -Seconds 10
        $processID = (Get-Process -Name "Minecraft.Windows" -ErrorAction SilentlyContinue).Id
    }

    return $processID
}

function DumpMinecraft($dest = "$root\MinecraftRTX") {
    if (-not (Test-Path "$root")) {
        New-Item -ItemType Directory -Force -Path "$root"
        New-Item -ItemType Directory -Force -Path "$root\backup"
        New-Item -ItemType Directory -Force -Path "$root\bin"
    }

    if (-not (Test-Path "$root\bin")) {
        Invoke-WebRequest -Uri "https://github.com/Wunkolo/UWPDumper/releases/download/latest/UWPDumper.zip" -OutFile "$root\bin\UWPDumper.zip"
        Expand-Archive -Path "$root\bin\UWPDumper.zip" -DestinationPath "$root\bin\UWPDumper" -Force
    }

    $processID = GetMinecraftProcessID

    $architecture = "x86"

    if ([System.Environment]::Is64BitOperatingSystem) {
        $architecture = "x64"
    }

    $dumper = "$root\bin\UWPDumper\$architecture\UWPInjector.exe"

    # Dump the UWP
    & "$dumper -p $processID -d $dest"

    return $dest
}

function SideloadMinecraft {
    Add-AppxPackage -Path "$root\MinecraftRTX\AppxManifest.xml" -Register
}

function StartSideloadedMinecraft {
    Invoke-CommandInDesktopPackage -PackageFamilyName "Microsoft.MinecraftWindowsBeta_8wekyb3d8bbwe" -AppId "Microsoft.MinecraftWindowsBeta" -Command "$root\MinecraftRTX\Minecraft.Windows.exe"
}

function GetMinecraftSubpacks($dest = "$root\MinecraftRTX") {
    $subpacks = @()

    $manifest = Get-Content -Raw -Path "$dest\BetterRTX\manifest.json" | ConvertFrom-Json

    $manifest.subpacks | ForEach-Object {
        $subpacks += @{
            name        = $_.name
            folder_name = $_.folder_name
            memory_tier = $_.memory_tier
        }
    }

    return $subpacks
}

