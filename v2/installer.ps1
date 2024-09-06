#!/usr/bin/env pwsh
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$BRTX_DIR = "$env:LOCALAPPDATA\graphics.bedrock"

$T = Data {
    # Default
    ConvertFrom-StringData -StringData @'
    package_name = BetterRTX
    browse = Browse...
    install = Install
    install_instance = Install to Instance
    install_pack = Install Preset
    install_custom = Custom
    uninstall = Uninstall
    uninstalled = Uninstalled
    copying = Copying
    downloading = Downloading
    deleting = Deleting
    success = Success
    error = Error
    error_invalid_file_type = Invalid file type. Please select a .mcpack file.
    error_no_installations_selected = Please select at least one Minecraft installation.
    error_copy_failed = Unable to copy to Minecraft installation.
    setup = Setup
    download = Download
    launchers = Launchers
    launch = Launch
    help = Help
    backup = Backup
    backup_instance_location = Select backup location for instance
    create_initial_backup = Creating initial backup
'@
}
$translationFilename = "installer.psd1"
$localeDir = Join-Path -Path $BRTX_DIR -ChildPath "Localized"
$localizedDataPath = Join-Path -Path $localeDir -ChildPath "$PsUICulture\$translationFilename"

if (-not (Test-Path $localizedDataPath)) {
    $localizedData = "https://raw.githubusercontent.com/BetterRTX/BetterRTX-Installer/main/v2/Localized/$PsUICulture/${translationFilename}"
    try {
        Invoke-WebRequest -Uri $localizedData -OutFile $localizedDataPath
    }
    catch {
        if ($_ -like "*404*") {
            Write-Host "Language `"$PsUICulture`" currently not available." -ForegroundColor Yellow
            Write-Host "(Translation contributions welcome! https://github.com/BetterRTX/BetterRTX-Installer/blob/main/CONTRIBUTING.md)" -ForegroundColor Magenta
        }
        else {
            Write-Host "Failed to download locale $PsUICulture data: $_"
        }

        # Fallback to local data during development/translation
        if ($PSScriptRoot -ne $null) {
            $localLocaleDir = Join-Path -Path $PSScriptRoot -ChildPath "Localized"

            if (Test-Path $localLocaleDir) {
                Clear-Host
                $localeDir = $localLocaleDir
                Write-Debug "Using translations in `"$localeDir`""
            }
        }
    }
}

Import-LocalizedData -BaseDirectory $localeDir -ErrorAction:SilentlyContinue -BindingVariable T -FileName $translationFilename
Clear-Host

$hasSideloaded = (Get-AppxPackage -Name "Microsoft.Minecraft*" | Where-Object { $_.InstallLocation -notlike "C:\Program Files\WindowsApps\*" }).Count -gt 0
$ioBit = Get-StartApps | Where-Object { $_.Name -eq "IObit Unlocker" }

# Whether to copy all materials at once or in a loop
$doSinglePass = $args -contains "-singlePass"

$dataSrc = @()

foreach ($mc in (Get-AppxPackage -Name "Microsoft.Minecraft*")) {
    if ($mc.InstallLocation -like "Java*") {
        continue
    }

    $dataSrc += [PSCustomObject]@{
        FriendlyName    = (Get-AppxPackageManifest -Package $mc).Package.Properties.DisplayName
        InstallLocation = $mc.InstallLocation
        Preview         = ($mc.InstallLocation -like "*Beta*" -or $mc.FriendlyName -like "*Preview*")
    }
}

# Based on https://gist.github.com/ABUCKY0/31b0b5b8691858930fccffa06da39b46
function IoBitGetExe() {
    if ($null -eq $ioBit) {
        return $null
    }

    $guid = ($ioBit.AppID -split "\\")[0].TrimStart("{").TrimEnd("}")

    $KnownFolders = @{
        '3DObjects'             = '31C0DD25-9439-4F12-BF41-7FF4EDA38722';
        'AddNewPrograms'        = 'de61d971-5ebc-4f02-a3a9-6c82895e5c04';
        'AdminTools'            = '724EF170-A42D-4FEF-9F26-B60E846FBA4F';
        'AppUpdates'            = 'a305ce99-f527-492b-8b1a-7e76fa98d6e4';
        'CDBurning'             = '9E52AB10-F80D-49DF-ACB8-4330F5687855';
        'ChangeRemovePrograms'  = 'df7266ac-9274-4867-8d55-3bd661de872d';
        'CommonAdminTools'      = 'D0384E7D-BAC3-4797-8F14-CBA229B392B5';
        'CommonOEMLinks'        = 'C1BAE2D0-10DF-4334-BEDD-7AA20B227A9D';
        'CommonPrograms'        = '0139D44E-6AFE-49F2-8690-3DAFCAE6FFB8';
        'CommonStartMenu'       = 'A4115719-D62E-491D-AA7C-E74B8BE3B067';
        'CommonStartup'         = '82A5EA35-D9CD-47C5-9629-E15D2F714E6E';
        'CommonTemplates'       = 'B94237E7-57AC-4347-9151-B08C6C32D1F7';
        'ComputerFolder'        = '0AC0837C-BBF8-452A-850D-79D08E667CA7';
        'ConflictFolder'        = '4bfefb45-347d-4006-a5be-ac0cb0567192';
        'ConnectionsFolder'     = '6F0CD92B-2E97-45D1-88FF-B0D186B8DEDD';
        'Contacts'              = '56784854-C6CB-462b-8169-88E350ACB882';
        'ControlPanelFolder'    = '82A74AEB-AEB4-465C-A014-D097EE346D63';
        'Cookies'               = '2B0F765D-C0E9-4171-908E-08A611B84FF6';
        'Desktop'               = 'B4BFCC3A-DB2C-424C-B029-7FE99A87C641';
        'Documents'             = 'FDD39AD0-238F-46AF-ADB4-6C85480369C7';
        'Downloads'             = '374DE290-123F-4565-9164-39C4925E467B';
        'Favorites'             = '1777F761-68AD-4D8A-87BD-30B759FA33DD';
        'Fonts'                 = 'FD228CB7-AE11-4AE3-864C-16F3910AB8FE';
        'Games'                 = 'CAC52C1A-B53D-4edc-92D7-6B2E8AC19434';
        'GameTasks'             = '054FAE61-4DD8-4787-80B6-090220C4B700';
        'History'               = 'D9DC8A3B-B784-432E-A781-5A1130A75963';
        'InternetCache'         = '352481E8-33BE-4251-BA85-6007CAEDCF9D';
        'InternetFolder'        = '4D9F7874-4E0C-4904-967B-40B0D20C3E4B';
        'Links'                 = 'bfb9d5e0-c6a9-404c-b2b2-ae6db6af4968';
        'LocalAppData'          = 'F1B32785-6FBA-4FCF-9D55-7B8E7F157091';
        'LocalAppDataLow'       = 'A520A1A4-1780-4FF6-BD18-167343C5AF16';
        'LocalizedResourcesDir' = '2A00375E-224C-49DE-B8D1-440DF7EF3DDC';
        'Music'                 = '4BD8D571-6D19-48D3-BE97-422220080E43';
        'NetHood'               = 'C5ABBF53-E17F-4121-8900-86626FC2C973';
        'NetworkFolder'         = 'D20BEEC4-5CA8-4905-AE3B-BF251EA09B53';
        'OriginalImages'        = '2C36C0AA-5812-4b87-BFD0-4CD0DFB19B39';
        'PhotoAlbums'           = '69D2CF90-FC33-4FB7-9A0C-EBB0F0FCB43C';
        'Pictures'              = '33E28130-4E1E-4676-835A-98395C3BC3BB';
        'Playlists'             = 'DE92C1C7-837F-4F69-A3BB-86E631204A23';
        'PrintersFolder'        = '76FC4E2D-D6AD-4519-A663-37BD56068185';
        'PrintHood'             = '9274BD8D-CFD1-41C3-B35E-B13F55A758F4';
        'Profile'               = '5E6C858F-0E22-4760-9AFE-EA3317B67173';
        'ProgramData'           = '62AB5D82-FDC1-4DC3-A9DD-070D1D495D97';
        'ProgramFiles'          = '905e63b6-c1bf-494e-b29c-65b732d3d21a';
        'ProgramFilesX64'       = '6D809377-6AF0-444b-8957-A3773F02200E';
        'ProgramFilesX86'       = '7C5A40EF-A0FB-4BFC-874A-C0F2E0B9FA8E';
        'ProgramFilesCommon'    = 'F7F1ED05-9F6D-47A2-AAAE-29D317C6F066';
        'ProgramFilesCommonX64' = '6365D5A7-0F0D-45E5-87F6-0DA56B6A4F7D';
        'ProgramFilesCommonX86' = 'DE974D24-D9C6-4D3E-BF91-F4455120B917';
        'Programs'              = 'A77F5D77-2E2B-44C3-A6A2-ABA601054A51';
        'Public'                = 'DFDF76A2-C82A-4D63-906A-5644AC457385';
        'PublicDesktop'         = 'C4AA340D-F20F-4863-AFEF-F87EF2E6BA25';
        'PublicDocuments'       = 'ED4824AF-DCE4-45A8-81E2-FC7965083634';
        'PublicDownloads'       = '3D644C9B-1FB8-4f30-9B45-F670235F79C0';
        'PublicGameTasks'       = 'DEBF2536-E1A8-4c59-B6A2-414586476AEA';
        'PublicMusic'           = '3214FAB5-9757-4298-BB61-92A9DEAA44FF';
        'PublicPictures'        = 'B6EBFB86-6907-413C-9AF7-4FC2ABF07CC5';
        'PublicVideos'          = '2400183A-6185-49FB-A2D8-4A392A602BA3';
        'QuickLaunch'           = '52a4f021-7b75-48a9-9f6b-4b87a210bc8f';
        'Recent'                = 'AE50C081-EBD2-438A-8655-8A092E34987A';
        'RecycleBinFolder'      = 'B7534046-3ECB-4C18-BE4E-64CD4CB7D6AC';
        'ResourceDir'           = '8AD10C31-2ADB-4296-A8F7-E4701232C972';
        'RoamingAppData'        = '3EB685DB-65F9-4CF6-A03A-E3EF65729F3D';
        'SampleMusic'           = 'B250C668-F57D-4EE1-A63C-290EE7D1AA1F';
        'SamplePictures'        = 'C4900540-2379-4C75-844B-64E6FAF8716B';
        'SamplePlaylists'       = '15CA69B3-30EE-49C1-ACE1-6B5EC372AFB5';
        'SampleVideos'          = '859EAD94-2E85-48AD-A71A-0969CB56A6CD';
        'SavedGames'            = '4C5C32FF-BB9D-43b0-B5B4-2D72E54EAAA4';
        'SavedSearches'         = '7d1d3a04-debb-4115-95cf-2f29da2920da';
        'SEARCH_CSC'            = 'ee32e446-31ca-4aba-814f-a5ebd2fd6d5e';
        'SEARCH_MAPI'           = '98ec0e18-2098-4d44-8644-66979315a281';
        'SearchHome'            = '190337d1-b8ca-4121-a639-6d472d16972a';
        'SendTo'                = '8983036C-27C0-404B-8F08-102D10DCFD74';
        'SidebarDefaultParts'   = '7B396E54-9EC5-4300-BE0A-2482EBAE1A26';
        'SidebarParts'          = 'A75D362E-50FC-4fb7-AC2C-A8BEAA314493';
        'StartMenu'             = '625B53C3-AB48-4EC1-BA1F-A1EF4146FC19';
        'Startup'               = 'B97D20BB-F46A-4C97-BA10-5E3608430854';
        'SyncManagerFolder'     = '43668BF8-C14E-49B2-97C9-747784D784B7';
        'SyncResultsFolder'     = '289a9a43-be44-4057-a41b-587a76d7e7f9';
        'SyncSetupFolder'       = '0F214138-B1D3-4a90-BBA9-27CBC0C5389A';
        'System'                = '1AC14E77-02E7-4E5D-B744-2EB1AE5198B7';
        'SystemX86'             = 'D65231B0-B2F1-4857-A4CE-A8E7C6EA7D27';
        'Templates'             = 'A63293E8-664E-48DB-A079-DF759E0509F7';
        'TreeProperties'        = '5b3749ad-b49f-49c1-83eb-15370fbd4882';
        'UserProfiles'          = '0762D272-C50A-4BB0-A382-697DCD729B80';
        'UsersFiles'            = 'f3ce0f7c-4901-4acc-8648-d5d44b04ef8f';
        'Videos'                = '18989B1D-99B5-455B-841C-AB7C74E4DDFC';
        'Windows'               = 'F38BF404-1D43-42F2-9305-67DE0B28FC23';
    }

    $key = $KnownFolders.GetEnumerator() | Where-Object { $_.Value -eq $guid } | Select-Object -ExpandProperty Key

    if ($null -eq $key) {
        return $ioBit.AppID
    }

    $folder = [Environment]::GetFolderPath($key)

    # Find IObitUnlocker.exe in $folder
    $ioBitLocation = Get-ChildItem -Path $folder -Recurse -Filter "IObitUnlocker.exe" -ErrorAction SilentlyContinue | Select-Object -First 1

    if ($null -ne $ioBitLocation) {
        return $ioBitLocation.FullName
    }

    # Fallback to StartApps
    return $ioBit.AppID
}

$ioBitExe = IoBitGetExe

function Backup-InitialShaderFiles() {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Location,
        [Parameter(Mandatory = $false)]
        [string[]]$Materials = @(
            "RTXStub.material.bin",
            "RTXPostFX.Tonemapping.material.bin"
        ),
        [Parameter(Mandatory = $false)]
        [string]$BackupDir = "$BRTX_DIR\backup"
    )

    $mcSrc = "$Location\data\renderer\materials"

    if (-not (Test-Path $BackupDir)) {
        New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    }

    foreach ($file in $Materials) {
        $src = "$mcSrc\$file"
        $dest = "$BackupDir\$file"

        if (Test-Path $src) {
            Copy-Item -Path $src -Destination $dest -Force -ErrorAction Stop
        }
    }
}

function Backup-ShaderFiles() {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Location,
        [Parameter(Mandatory = $false)]
        [string[]]$Materials = @(
            "RTXStub.material.bin",
            "RTXPostFX.Tonemapping.material.bin"
        ),
        [Parameter(Mandatory = $false)]
        [string]$BackupDir = "$BRTX_DIR\backup"
    )

    Backup-InitialShaderFiles -Location $Location -Materials $Materials -BackupDir $BackupDir

    # Get base name of location
    $instance = ($Location -split "\\")[-1].Replace(" ", "_")

    # Convert backup dir to zip archive
    $zipFilename = "betterrtx_backup_" + ($instance) + (Get-Date -Format "yyyy-MM-dd_HH-mm") + ".zip"

    # Prompt user for output directory
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = $T.backup_instance_location + " `"$instance`""

    if ($dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
        return $false
    }

    $zip = Join-Path -Path $dialog.SelectedPath -ChildPath $zipFilename

    if (Test-Path $zip) {
        Remove-Item -Path $zip -Force
    }

    Compress-Archive -Path $BackupDir -DestinationPath $zip -Force
    
    Remove-Item -Path $BackupDir -Force -Recurse

    # Rename it to .mcpack so it can be used with the installer again
    Rename-Item -Path $zip -NewName ($zip -replace ".zip", ".mcpack") -Force

    return $true
}

function Copy-ShaderFiles() {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Location,
        [Parameter(Mandatory = $true)]
        [string[]]$Materials
    )

    $mcDest = "$Location\data\renderer\materials"

    $isSideloaded = $Location -notlike "C:\Program Files\WindowsApps\*"
    
    $StatusLabel.Visible = $false

    if ($isSideloaded) {
        $StatusLabel.Text = $T.copying
        $StatusLabel.ForeColor = 'Blue'
        $StatusLabel.Visible = $true
        Copy-Item -Path $Materials -Destination $mcDest -Force -ErrorAction Stop
        return $true
    }

    if ($ioBit) {
        $StatusLabel.Text = $T.deleting
        $StatusLabel.ForeColor = 'Blue'
        $StatusLabel.Visible = $true

        $success = IoBitDelete -Materials $Materials -Location $mcDest

        if (-not $success) {
            $StatusLabel.Text = $T.error_copy_failed
            $StatusLabel.ForeColor = 'Red'
            $StatusLabel.Visible = $true
            return $false
        }

        Start-Sleep -Milliseconds 100

        $StatusLabel.Text = $T.copying
        $StatusLabel.ForeColor = 'Blue'
        $StatusLabel.Visible = $true
        
        $success = IoBitCopy -Materials $Materials -Destination $mcDest -singlePass $doSinglePass

        if (-not $success) {
            $StatusLabel.Text = $T.error_copy_failed
            $StatusLabel.ForeColor = 'Red'
            $StatusLabel.Visible = $true
            return $false
        }

        return $true
    }

    return $false
}

function IoBitDelete() {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$Materials,
        [Parameter(Mandatory = $true)]
        [string]$Location
    )

    $arguments = "/Delete "
    
    foreach ($material in $Materials) {
        # Get base name
        $material = ($material -split "\\")[-1]
        $materialPath = Join-Path -Path $Location -ChildPath $material
        $arguments += "`"$materialPath`","
    }

    $processOptions = @{
        FilePath     = "$ioBitExe"
        ArgumentList = $arguments.TrimEnd(",")
        Wait         = $true
        PassThru     = $true
    }

    $delete = Start-Process @processOptions

    $MaterialsFound = $Materials | Where-Object { -not (Test-Path $_) }

    Stop-Process $delete

    return $MaterialsFound.Count -eq 0
}

function IoBitCopy() {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$Materials,
        [Parameter(Mandatory = $true)]
        [string]$Destination,
        [Parameter(Mandatory = $false)]
        [boolean]$singlePass = $true
    )

    # Copy all materials in one pass
    if ($singlePass) {
        $arguments = "/Copy "
        $arguments += "`"$($Materials -join '","')`" `"$Destination`""
        $processOptions = @{
            FilePath     = "$ioBitExe"
            ArgumentList = $arguments
            Wait         = $true
            PassThru     = $true
        }

        $proc = Start-Process @processOptions
        Stop-Process $proc
    }
    else {
        # Copy materials one by one (Sanity check)
        $itr = 1
        
        foreach ($material in $Materials) {
            $StatusLabel.Text = $T.copying + " ($itr/$($Materials.Count))"
            $proc = Start-Process $ioBitExe -ArgumentList "/Copy `"$material`" `"$Destination`"" -Wait -PassThru
            Start-Sleep -Milliseconds 100
            Stop-Process $proc
            $itr++
        }
    }

    # Check for copied materials existence
    $MaterialsFound = $Materials | Where-Object {
        $material = ($_.Split("\")[-1])
        Test-Path "$Destination\$material"
    }

    return $MaterialsFound.Count -eq $Materials.Count
}

function Uninstall-Package() {
    param(
        [Parameter(Mandatory = $true)]
        [boolean]$restoreInitial
    )

    if ($restoreInitial) {
        foreach ($mc in $dataSrc) {
            Copy-ShaderFiles -Location $mc.InstallLocation -Materials @("$BRTX_DIR\backup\$($mc.FriendlyName)\RTXStub.material.bin", "$BRTX_DIR\backup\$($mc.FriendlyName)\RTXPostFX.Tonemapping.material.bin")
        }
    }

    Remove-Item -Path $BRTX_DIR -Force -Recurse
    $form.Close()
    Write-Host $T.uninstalled
}

function Expand-MinecraftPack() {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Pack
    )

    $StatusLabel.Visible = $false

    # Check file type
    if (($Pack -notlike "*.mcpack") -and ($Pack -notlike "*.rtpack")) {
        $StatusLabel.Text = $T.error_invalid_file_type
        $StatusLabel.ForeColor = 'Red'
        $StatusLabel.Visible = $true
        return $false
    }

    $StatusLabel.Text = $T.copying
    $StatusLabel.ForeColor = 'Blue'
    $StatusLabel.Visible = $true

    $PackName = ($Pack -split "\\")[-1].Replace(".mcpack", "").Replace(".rtpack", "")
    $PackDirName = Join-Path -Path $BRTX_DIR -ChildPath "packs\$PackName"
    $PackDir = New-Item -ItemType Directory -Path $PackDirName -Force
    $Zip = Join-Path -Path $PackDir -ChildPath "$PackName.zip"

    if (Test-Path $Zip) {
        Remove-Item -Path $Zip -Force
    }

    Copy-Item -Path $Pack -Destination $Zip -Force
    Expand-Archive -Path $Zip -DestinationPath $PackDir -Force

    # Loop through the files in the archive. Get the ones that end with ".material.bin"
    $Materials = Get-ChildItem -Path $PackDir -Recurse -Filter "*.material.bin" -Force

    # Loop through the selected Minecraft installations
    foreach ($mc in $dataSrc) {
        if ($ListBox.SelectedItems -notcontains $mc.FriendlyName) {
            continue
        }

        $success = Copy-ShaderFiles -Location $mc.InstallLocation -Materials ($Materials | Select-Object -ExpandProperty FullName)

        if (-not $success) {
            $StatusLabel.Text = $T.error_copy_failed
            $StatusLabel.ForeColor = 'Red'
            $StatusLabel.Visible = $true
            return $false
        }
    }

    # Delete the temp directory and zip
    Remove-Item -Path $Zip -Force

    # Show success message
    $StatusLabel.Text = "${T.success} $PackName"
    $StatusLabel.ForeColor = 'Green'
    $StatusLabel.Visible = $true

    return $true
}

function Get-ApiPacks() {
    $packs = @()

    if (-not (Test-Path "$BRTX_DIR\packs")) {
        New-Item -ItemType Directory -Path "$BRTX_DIR\packs" -Force | Out-Null
    }

    $API_JSON = "$BRTX_DIR\packs\api.json"

    if ((Test-Path $API_JSON) -and ((Get-Item $API_JSON).LastWriteTime -gt (Get-Date).AddHours(-1))) {
        return (Get-Content $API_JSON -Raw | ConvertFrom-Json)
    }
    
    try {
        $response = Invoke-WebRequest -Uri "https://bedrock.graphics/api" -ContentType "application/json"
        $apiPacks = $response.Content | ConvertFrom-Json

        foreach ($pack in $apiPacks) {
            $packs += [PSCustomObject]@{
                Name = $pack.name
                UUID = $pack.uuid
            }
        }
    }
    catch {
        Write-Host "Failed to get API packs: $_"
    }

    $packs | ConvertTo-Json | Out-File $API_JSON

    return $packs
}

function DownloadPack() {
    param(
        [Parameter(Mandatory = $true)]
        [string]$uuid
    )

    $StatusLabel.Text = $T.downloading
    $StatusLabel.ForeColor = 'Blue'
    $StatusLabel.Visible = $true

    $dir = "$BRTX_DIR\packs\$uuid"

    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    
    try {
        $response = Invoke-WebRequest -Uri "https://bedrock.graphics/api/pack/${uuid}" -ContentType "application/json"
        $content = $response.Content | ConvertFrom-Json

        Invoke-WebRequest -Uri $content.stub -OutFile "$dir\RTXStub.material.bin"
        Invoke-WebRequest -Uri $content.tonemapping -OutFile "$dir\RTXPostFX.Tonemapping.material.bin"
    }
    catch {
        Write-Host "Failed to get API data for ID ${uuid}: $_"
    }
    
    foreach ($mc in $dataSrc) {
        if ($ListBox.SelectedItems -notcontains $mc.FriendlyName) {
            continue
        }

        $success = Copy-ShaderFiles -Location $mc.InstallLocation -Materials @("$dir\RTXStub.material.bin", "$dir\RTXPostFX.Tonemapping.material.bin")

        if (-not $success) {
            $StatusLabel.Text = $T.error_copy_failed
            $StatusLabel.ForeColor = 'Red'
            $StatusLabel.Visible = $true
            return $false
        }
    }

    # Show success message
    $StatusLabel.Text = "$($T.success) $($PackSelectList.SelectedItem)"
    $StatusLabel.ForeColor = 'Green'
    $StatusLabel.Visible = $true

    return $true
}

function ToggleInstallButton() {
    # Enable install button when selection changes and both lists have a selection
    if (($ListBox.SelectedItems.Count -gt 0) -and ($PackSelectList.SelectedItem.Length -gt 1)) {
        $InstallButton.Enabled = $true
    }
    else {
        $InstallButton.Enabled = $false
    }
}

if (-not (Test-Path "$BRTX_DIR\backup")) {
    Write-Host $T.create_initial_backup
    New-Item -ItemType Directory -Path "$BRTX_DIR\backup" -Force | Out-Null

    foreach ($mc in $dataSrc) {
        New-Item -ItemType Directory -Path "$BRTX_DIR\backup\$($mc.FriendlyName)" -Force | Out-Null
        Backup-InitialShaderFiles -Location $mc.InstallLocation -BackupDir "$BRTX_DIR\backup\$($mc.FriendlyName)"
    }
    Clear-Host
}

$lineHeight = 25
$padding = 10
$screenHeight = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height
$windowHeight = [math]::Min($screenHeight * 0.9, (2 * ($lineHeight * 7)))
$windowWidth = 400 + ($padding * 2)
$containerWidth = ($windowWidth - ($padding * 4))

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = $T.package_name
$form.Size = New-Object System.Drawing.Size($windowWidth, $windowHeight)
$form.StartPosition = 'CenterScreen'
$form.Padding = New-Object System.Windows.Forms.Padding($padding)
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.ShowInTaskbar = $true
$form.Topmost = $false

# Form drag and drop
$form.AllowDrop = $true
$form.Add_DragEnter({
        param($sender, $e)

        if (
            $e.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop) -and 
            $e.Data.GetData([Windows.Forms.DataFormats]::FileDrop).Count -eq 1 -and 
            ($e.Data.GetData([Windows.Forms.DataFormats]::FileDrop)[0] -like "*.mcpack" -or
            $e.Data.GetData([Windows.Forms.DataFormats]::FileDrop)[0] -like "*.rtpack" -or
            $e.Data.GetData([Windows.Forms.DataFormats]::FileDrop)[0] -like "*.material.bin")
        ) {
            $e.Effect = [Windows.Forms.DragDropEffects]::Copy
        }
        else {
            $e.Effect = [Windows.Forms.DragDropEffects]::None
        }
    })
$form.Add_DragDrop({
        param($sender, $e)

        $StatusLabel.Visible = $false
        $files = $e.Data.GetData([Windows.Forms.DataFormats]::FileDrop)

        if ($files.Count -eq 1 -and ($files[0] -like "*.mcpack" -or $files[0] -like "*.rtpack")) {
            Expand-MinecraftPack -Pack $files[0]
        }
        
        if ($files.Count -ge 1 -and $files.Count -le 2 -and ($files[0] -like "*.material.bin")) {
            foreach ($mc in $dataSrc) {
                if ($ListBox.SelectedItems -notcontains $mc.FriendlyName) {
                    continue
                }

                $success = Copy-ShaderFiles -Location $mc.InstallLocation -Materials $files

                if (-not $success) {
                    $StatusLabel.Text = $T.error_copy_failed
                    $StatusLabel.ForeColor = 'Red'
                    $StatusLabel.Visible = $true
                    return
                }
            }

            $StatusLabel.Text = $T.success
            $StatusLabel.ForeColor = 'Green'
            $StatusLabel.Visible = $true
        }
    })

$flowPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$flowPanel.Dock = 'Fill'
$flowPanel.FlowDirection = 'TopDown'
$flowPanel.WrapContents = $false

$PackSelectList = New-Object System.Windows.Forms.ComboBox
$PackSelectList.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$PackSelectList.Width = $containerWidth

$packs = Get-ApiPacks
foreach ($pack in $packs) {
    $PackSelectList.Items.Add($pack.Name) | Out-Null
}

$PackSelectList.Items.Add($T.install_custom) | Out-Null
$PackSelectList.Add_SelectedIndexChanged({
        $StatusLabel.Visible = $false
        ToggleInstallButton
    })

$PackListLabel = New-Object System.Windows.Forms.Label
$PackListLabel.Text = $T.install_pack
$PackListLabel.Font = New-Object System.Drawing.Font("Arial", 11, [System.Drawing.FontStyle]::Bold)
$PackListLabel.ForeColor = 'Black'
$PackListLabel.BackColor = [System.Drawing.Color]::FromName("Transparent")
$PackListLabel.Width = $containerWidth

$StatusLabel = New-Object System.Windows.Forms.Label
$StatusLabel.Font = New-Object System.Drawing.Font("Arial", 10)
$StatusLabel.Anchor = 'Top'
$StatusLabel.Height = $lineHeight
$StatusLabel.Width = $containerWidth
$StatusLabel.Visible = $false

$BrowseButton = New-Object System.Windows.Forms.Button
$BrowseButton.Text = $T.browse

$ListLabel = New-Object System.Windows.Forms.Label
$ListLabel.Text = $T.install_instance
$ListLabel.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
$ListLabel.ForeColor = 'Black'
$ListLabel.BackColor = [System.Drawing.Color]::FromName("Transparent")
$ListLabel.Width = $containerWidth

$ListBox = New-Object System.Windows.Forms.ListBox
$ListBox.SelectionMode = 'MultiSimple'
$ListBox.Height = $dataSrc.Count * $lineHeight
$ListBox.Width = $containerWidth

foreach ($mc in $dataSrc) {
    $ListBox.Items.Add($mc.FriendlyName) | Out-Null
}

# Enable or disable install button when selection changes
$ListBox.Add_SelectedIndexChanged({
        $StatusLabel.Visible = $false
        ToggleInstallButton
    })

$LaunchButton = New-Object System.Windows.Forms.Button
$LaunchButton.Text = $T.launch
$LaunchButton.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
$LaunchButton.Width = $containerWidth
$LaunchButton.Height = $lineHeight
$LaunchButton.Anchor = 'Bottom'
$LaunchButton.Enabled = $false
$LaunchButton.Visible = $false
$LaunchButton.Add_Click({
        $StatusLabel.Visible = $false

        if ($ListBox.SelectedItems.Count -eq 0) {
            return
        }

        $selected = $ListBox.SelectedItems[0]
        $mc = $dataSrc | Where-Object { $_.FriendlyName -eq $selected }

        if ($mc -eq $null) {
            $StatusLabel.Text = $T.error_no_installations_selected
            $StatusLabel.ForeColor = 'Red'
            $StatusLabel.Visible = $true
            return
        }

        $LaunchButton.Enabled = $false

        if ($mc.Preview -eq $true) {
            Start-Process minecraft-preview:
        }
        else {
            Start-Process minecraft:
        }

        $LaunchButton.Visible = $false
    })

$InstallButton = New-Object System.Windows.Forms.Button
$InstallButton.Text = $T.install
$InstallButton.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
$InstallButton.Width = $containerWidth
$InstallButton.Height = $lineHeight
$InstallButton.Anchor = 'Bottom'
$InstallButton.Enabled = $ListBox.Items.Count -eq 1

$InstallButton.Add_Click({
        $StatusLabel.Visible = $false
    
        if ($ListBox.SelectedItems.Count -eq 0) {
            $StatusLabel.Text = $T.error_no_installations_selected
            $StatusLabel.ForeColor = 'Red'
            $StatusLabel.Visible = $true
            return
        }

        $success = $false

        if ($PackSelectList.SelectedItem -eq $T.install_custom) {
            $dialog = New-Object System.Windows.Forms.OpenFileDialog
            $dialog.Filter = 'Minecraft Resource Pack (*.mcpack)|*.mcpack'

            if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                $success = Expand-MinecraftPack -Pack $dialog.FileName
            }
        }
        else {
            $success = DownloadPack -uuid ($packs | Where-Object { $_.Name -eq $PackSelectList.SelectedItem }).UUID
        }

        $LaunchButton.Visible = $success
        $LaunchButton.Enabled = $success
    })

$flowPanel.Controls.Add($ListLabel)
$flowPanel.Controls.Add($ListBox)
$flowPanel.Controls.Add($PackListLabel)
$flowPanel.Controls.Add($PackSelectList)
$flowPanel.Controls.Add($InstallButton)
$flowPanel.Controls.Add($StatusLabel)
$flowPanel.Controls.Add($LaunchButton)
$form.Controls.Add($flowPanel)

# Add file menu to dialog
$mainMenu = New-Object System.Windows.Forms.MainMenu
$fileMenu = New-Object System.Windows.Forms.MenuItem
$fileMenu.Text = $T.setup

if (!$hasSideloaded) {
    $sideloadersMenu = New-Object System.Windows.Forms.MenuItem
    $sideloadersMenu.Text = $T.launchers
    $fileMenu.MenuItems.Add($sideloadersMenu) | Out-Null

    $downloadMcLauncherMenuItem = New-Object System.Windows.Forms.MenuItem
    $downloadMcLauncherMenuItem.Text = $T.download + " &MC Launcher"
    $downloadMcLauncherMenuItem.Add_Click({ Start-Process -FilePath "https://github.com/MCMrARM/mc-w10-version-launcher" })
    $sideloadersMenu.MenuItems.Add($downloadMcLauncherMenuItem) | Out-Null

    $downloadBedrockLauncherMenuItem = New-Object System.Windows.Forms.MenuItem
    $downloadBedrockLauncherMenuItem.Text = $T.download + " &Bedrock Launcher"
    $downloadBedrockLauncherMenuItem.Add_Click({ Start-Process -FilePath "https://github.com/BedrockLauncher/BedrockLauncher" })
    $sideloadersMenu.MenuItems.Add($downloadBedrockLauncherMenuItem) | Out-Null
}

if (!$ioBit) {
    $downloadIoBitMenuItem = New-Object System.Windows.Forms.MenuItem
    $downloadIoBitMenuItem.Text = $T.download + " &IObit Unlocker"
    $downloadIoBitMenuItem.Add_Click({ Start-Process -FilePath "https://www.iobit.com/en/iobit-unlocker.php" })
    $fileMenu.MenuItems.Add($downloadIoBitMenuItem) | Out-Null
}

$backupMenuItem = New-Object System.Windows.Forms.MenuItem
$backupMenuItem.Text = $T.backup
$backupMenuItem.Add_Click({
        foreach ($mc in $dataSrc) {
            if ($ListBox.SelectedItems.Count -gt 0 -and $ListBox.SelectedItems -notcontains $mc.FriendlyName) {
                continue
            }
            Backup-ShaderFiles -Location $mc.InstallLocation -BackupDir "$BRTX_DIR\backup\$($mc.FriendlyName)"
        }
    })

$fileMenu.MenuItems.Add($backupMenuItem) | Out-Null
$mainMenu.MenuItems.Add($fileMenu) | Out-Null

$helpMenu = New-Object System.Windows.Forms.MenuItem
$helpMenu.Text = $T.help
$mainMenu.MenuItems.Add($helpMenu) | Out-Null

$discordMenuItem = New-Object System.Windows.Forms.MenuItem
$discordMenuItem.Text = "&Discord"
$discordMenuItem.Add_Click({ Start-Process -FilePath "https://discord.com/invite/minecraft-rtx-691547840463241267" })
$helpMenu.MenuItems.Add($discordMenuItem) | Out-Null

$gitHubMenuItem = New-Object System.Windows.Forms.MenuItem
$gitHubMenuItem.Text = "&GitHub"
$gitHubMenuItem.Add_Click({ Start-Process -FilePath "https://github.com/BetterRTX/BetterRTX-Installer" })
$helpMenu.MenuItems.Add($gitHubMenuItem) | Out-Null

$uninstallMenu = New-Object System.Windows.Forms.MenuItem
$uninstallMenu.Text = $T.uninstall
$uninstallMenu.Add_Click({ Uninstall-Package -restoreInitial $true })
$fileMenu.MenuItems.Add($uninstallMenu) | Out-Null

$form.Menu = $mainMenu

$form.ShowDialog() | Out-Null
exit;
