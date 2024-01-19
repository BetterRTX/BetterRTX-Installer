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

$ioBit = Get-StartApps | Where-Object { $_.Name -eq "IObit Unlocker" }
$hasSideloaded = (Get-AppxPackage -Name "Microsoft.Minecraft*" | Where-Object { $_.InstallLocation -notlike "C:\Program Files\WindowsApps\*" }).Count -gt 0

$dataSrc = @()

foreach ($mc in (Get-AppxPackage -Name "Microsoft.Minecraft*")) {
    $dataSrc += [PSCustomObject]@{
        FriendlyName    = (Get-AppxPackageManifest -Package $mc).Package.Properties.DisplayName
        InstallLocation = $mc.InstallLocation
    }
}

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

        $success = IoBitDelete

        if (-not $success) {
            $StatusLabel.Text = $T.error_copy_failed
            $StatusLabel.ForeColor = 'Red'
            $StatusLabel.Visible = $true
            return $false
        }

        $StatusLabel.Text = $T.copying
        $StatusLabel.ForeColor = 'Blue'
        $StatusLabel.Visible = $true
        
        $success = IoBitCopy

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
    $arguments = @("/Delete")
    
    foreach ($material in $Materials) {
        # Get base name
        $material = ($material -split "\\")[-1]
        $materialPath = Join-Path -Path $mcDest -ChildPath $material
        $arguments += "`"$materialPath`","
    }

    $arguments[-1] = $arguments[-1].TrimEnd(",")
    $arguments = $arguments -join " "

    $processOptions = @{
        FilePath     = $($ioBit.AppID)
        ArgumentList = $arguments
        Wait         = $true
    }

    Start-Process @processOptions

    $MaterialsFound = $Materials | Where-Object { -not (Test-Path $_) }

    return $MaterialsFound.Count -eq 0
}

function IoBitCopy() {
    $arguments = @("/Copy")
        
    foreach ($material in $Materials) {
        $arguments += "`"$material`","
    }

    $arguments[-1] = $arguments[-1].TrimEnd(",")
    $arguments += "`"$mcDest`""
    $arguments = $arguments -join " "

    $processOptions = @{
        FilePath     = $($ioBit.AppID)
        ArgumentList = $arguments
        Wait         = $true
    }

    Start-Process @processOptions

    $MaterialsFound = $Materials | Where-Object { Test-Path $_ }

    return $MaterialsFound.Count -eq $Materials.Count
}

function Uninstall-Package() {
    param(
        [Parameter(Mandatory = $true)]
        [boolean]$restoreInitial
    )

    if ($restoreInitial) {
        foreach ($mc in $dataSrc) {
            Copy-ShaderFiles -Location $mc.InstallLocation -Materials "$BRTX_DIR\backup\$($mc.FriendlyName)\RTXStub.material.bin", "$BRTX_DIR\backup\$($mc.FriendlyName)\RTXPostFX.Tonemapping.material.bin"
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
    if ($Pack -notlike "*.mcpack") {
        $StatusLabel.Text = $T.error_invalid_file_type
        $StatusLabel.ForeColor = 'Red'
        $StatusLabel.Visible = $true
        return
    }

    $StatusLabel.Text = $T.copying
    $StatusLabel.ForeColor = 'Blue'
    $StatusLabel.Visible = $true

    $PackName = ($Pack -split "\\")[-1].Replace(".mcpack", "")
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
            return
        }
    }

    # Delete the temp directory and zip
    Remove-Item -Path $Zip -Force

    # Show success message
    $StatusLabel.Text = "${T.success} $PackName"
    $StatusLabel.ForeColor = 'Green'
    $StatusLabel.Visible = $true
}

function Get-ApiPacks() {
    $packs = @()

    if (-not (Test-Path "$BRTX_DIR\packs")) {
        New-Item -ItemType Directory -Path "$BRTX_DIR\packs" -Force | Out-Null
    }

    $API_JSON = "$BRTX_DIR\packs\api.json"

    if (Test-Path $API_JSON) {
        return (Get-Content $API_JSON -Raw | ConvertFrom-Json)
    }
    
    try {
        $response = Invoke-WebRequest -Uri "https://bedrock.graphics/api/" -ContentType "application/json"
        $apiPacks = $response.Content | ConvertFrom-Json

        foreach ($pack in $apiPacks) {
            $packs += [PSCustomObject]@{
                Name = $pack.name
                UUID = $pack.uuid
            }
        }
    }
    catch {
        Write-Host "Failed to get API packs: $_.Exception.Message"
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

        try {
            $response = Invoke-WebRequest -Uri "https://bedrock.graphics/api/pack/${uuid}" -ContentType "application/json"
            $content = $response.Content | ConvertFrom-Json

            Invoke-WebRequest -Uri $content.stub -OutFile "$dir\RTXStub.material.bin"
            Invoke-WebRequest -Uri $content.tonemapping -OutFile "$dir\RTXPostFX.Tonemapping.material.bin"

        }
        catch {
            Write-Host "Failed to get API data for ID ${uuid}: $_"
        }
    }
    
    foreach ($mc in $dataSrc) {
        if ($ListBox.SelectedItems -notcontains $mc.FriendlyName) {
            continue
        }

        $success = Copy-ShaderFiles -Location $mc.InstallLocation -Materials "$dir\RTXStub.material.bin", "$dir\RTXPostFX.Tonemapping.material.bin"

        if (-not $success) {
            $StatusLabel.Text = $T.error_copy_failed
            $StatusLabel.ForeColor = 'Red'
            $StatusLabel.Visible = $true
            return
        }
    }

    # Show success message
    $StatusLabel.Text = "$($T.success) $($PackSelectList.SelectedItem)"
    $StatusLabel.ForeColor = 'Green'
    $StatusLabel.Visible = $true
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
$windowHeight = ($dataSrc.Count * ($lineHeight * 6))
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
            $e.Data.GetData([Windows.Forms.DataFormats]::FileDrop)[0] -like "*.mcpack"
        ) {
            $e.Effect = [Windows.Forms.DragDropEffects]::Copy
        }
        else {
            $e.Effect = [Windows.Forms.DragDropEffects]::None
        }
    })
$form.Add_DragDrop({
        param($sender, $e)

        $files = $e.Data.GetData([Windows.Forms.DataFormats]::FileDrop)
        Expand-MinecraftPack -Pack $files[0]
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

$InstallButton = New-Object System.Windows.Forms.Button
$InstallButton.Text = $T.install
$InstallButton.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
$InstallButton.Width = $containerWidth
$InstallButton.Height = $lineHeight
$InstallButton.Anchor = 'Bottom'
$InstallButton.Enabled = $false

$InstallButton.Add_Click({
        $StatusLabel.Visible = $false
    
        if ($ListBox.SelectedItems.Count -eq 0) {
            $StatusLabel.Text = $T.error_no_installations_selected
            $StatusLabel.ForeColor = 'Red'
            $StatusLabel.Visible = $true
            return
        }

        if ($PackSelectList.SelectedItem -eq $T.install_custom) {
            $dialog = New-Object System.Windows.Forms.OpenFileDialog
            $dialog.Filter = 'Minecraft Resource Pack (*.mcpack)|*.mcpack'

            if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                Expand-MinecraftPack -Pack $dialog.FileName
            }
        }
        else {
            DownloadPack -uuid ($packs | Where-Object { $_.Name -eq $PackSelectList.SelectedItem }).UUID
        }
    })

$flowPanel.Controls.Add($StatusLabel)
$flowPanel.Controls.Add($ListLabel)
$flowPanel.Controls.Add($ListBox)
$flowPanel.Controls.Add($PackListLabel)
$flowPanel.Controls.Add($PackSelectList)
$flowPanel.Controls.Add($InstallButton)
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
