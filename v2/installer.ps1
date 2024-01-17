#!/usr/bin/env pwsh
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$T = Data {
    # Default
    ConvertFrom-StringData -StringData @'
    package_name = BetterRTX
    browse = Browse...
    install = Install
    install_instance = Install to Instance
    install_pack = Install Preset
    success = Success
    error = Error
    error_invalid_file_type = Invalid file type. Please select a .mcpack file.
    error_no_installations_selected = Please select at least one Minecraft installation.
    error_copy_failed = Unable to copy to side-loaded Minecraft installation. Please install IObit Unlocker.
    setup = Setup
    download = Download
    launchers = Launchers
    help = Help
    backup = Backup
'@
}

if ($PsUICulture -ne "en-US") {
    $localizedData = "https://raw.githubusercontent.com/BetterRTX/BetterRTX-Installer/main/Localized/$PsUICulture/installer.psd1"
    $localizedDataPath = Join-Path -Path $PSScriptRoot -ChildPath "Localized/$PsUICulture.psd1"

    if (-not (Test-Path $localizedDataPath)) {
        Invoke-WebRequest -Uri $localizedData -OutFile $localizedDataPath
    }
}
Import-LocalizedData -BaseDirectory (Join-Path -Path $PSScriptRoot -ChildPath Localized) -ErrorAction:SilentlyContinue -BindingVariable T -FileName installer.psd1
Clear-Host

$ioBit = Get-StartApps | Where-Object { $_.Name -eq "IObit Unlocker" }
$hasSideloaded = (Get-AppxPackage -Name "Microsoft.Minecraft*" | Where-Object { $_.InstallLocation -notlike "C:\Program Files\WindowsApps\" }).Count -gt 0

$dataSrc = @()

foreach ($mc in (Get-AppxPackage -Name "Microsoft.Minecraft*")) {
    $dataSrc += [PSCustomObject]@{
        FriendlyName    = (Get-AppxPackageManifest -Package $mc).Package.Properties.DisplayName
        InstallLocation = $mc.InstallLocation
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
        [string]$BackupDir = "$env:TEMP\graphics.bedrock\backup"
    )

    $mcSrc = "$location\data\renderer\materials"

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

    # Get base name of location
    $instance = ($Location -split "\\")[-1].Replace(" ", "_")

    # Convert backup dir to zip archive
    $zip = "betterrtx_backup_" + ($instance) + (Get-Date -Format "yyyy-MM-dd_HH-mm") + ".zip"

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

    $mcDest = "$location\data\renderer\materials"

    $isSideloaded = $location -notlike "C:\Program Files\WindowsApps\"

    if ($isSideloaded) {
        Write-Host "Copying to $mcDest"
        Copy-Item -Path $Materials -Destination $mcDest -Force -ErrorAction Stop
        return $true
    }

    if ($ioBit) {
        $argList = "/Copy "

        foreach ($file in $Materials) {
            $argList += "`"$file`" "
        }

        $argList += " $mcDest"

        Start-Process -FilePath $ioBit.AppID -ArgumentList $argList -Wait
        return $true
    }

    return $false
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

    $Zip = $Pack + ".zip"

    if (Test-Path $Zip) {
        Remove-Item -Path $Zip -Force
    }

    Copy-Item -Path $Pack -Destination $Zip -Force

    # Output contents into a temp directory
    $TempDir = New-Item -ItemType Directory -Path "$env:TEMP\graphics.bedrock" -Force

    Expand-Archive -Path $Zip -DestinationPath $TempDir -Force

    # Loop through the files in the archive. Get the ones that end with ".material.bin"
    $Materials = Get-ChildItem -Path $TempDir -Recurse -Filter "*.material.bin" -Force

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
    Remove-Item -Path $TempDir -Force -Recurse
    Remove-Item -Path $Zip -Force

    # Show success message
    $StatusLabel.Text = $T.success
    $StatusLabel.ForeColor = 'Green'
    $StatusLabel.Visible = $true
}

function Get-ApiPacks() {
    $packs = @()

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

    return $packs
}

function DownloadPack() {
    param(
        [Parameter(Mandatory = $true)]
        [string]$uuid
    )

    $dir = "$env:TEMP\graphics.bedrock\$uuid"

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

        Copy-ShaderFiles -Location $mc.InstallLocation -Materials "$dir\RTXStub.material.bin", "$dir\RTXPostFX.Tonemapping.material.bin"
    }
}

$lineHeight = 25
$windowHeight = ($dataSrc.Count * ($lineHeight * 4) + ($lineHeight * 2))
$windowWidth = 400
$containerWidth = ($windowWidth - $lineHeight)

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = $T.package_name
$form.Size = New-Object System.Drawing.Size($windowWidth, $windowHeight)
$form.StartPosition = 'CenterScreen'
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

$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.ShowInTaskbar = $true
$form.Topmost = $true

$PackSelectList = New-Object System.Windows.Forms.ComboBox
$PackSelectList.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$PackSelectList.Width = $containerWidth

$packs = Get-ApiPacks
foreach ($pack in $packs) {
    $PackSelectList.Items.Add($pack.Name) | Out-Null
}

$PackSelectList.Items.Add("Custom") | Out-Null

$PackListLabel = New-Object System.Windows.Forms.Label
$PackListLabel.Text = $T.install_pack
$PackListLabel.Font = New-Object System.Drawing.Font("Arial", 11, [System.Drawing.FontStyle]::Bold)
$PackListLabel.ForeColor = 'Black'
$PackListLabel.BackColor = [System.Drawing.Color]::FromName("Transparent")
$PackListLabel.Width = $containerWidth

$flowPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$flowPanel.Dock = 'Fill'
$flowPanel.FlowDirection = 'TopDown'
$flowPanel.WrapContents = $false

$StatusLabel = New-Object System.Windows.Forms.Label
$StatusLabel.Font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
$StatusLabel.Anchor = 'Top'

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

$InstallButton = New-Object System.Windows.Forms.Button
$InstallButton.Text = $T.install
$InstallButton.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
$InstallButton.Width = $containerWidth
$InstallButton.Height = $lineHeight
$InstallButton.Anchor = 'Bottom'

$InstallButton.Add_Click({
        if ($ListBox.SelectedItems.Count -eq 0) {
            $StatusLabel.Text = $T.error_no_installations_selected
            $StatusLabel.ForeColor = 'Red'
            $StatusLabel.Visible = $true
            return
        }

        $StatusLabel.Visible = $false

        if ($PackSelectList.SelectedItem -eq "Custom") {
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

# Extract on drop
$form.Add_DragDrop({
        param($sender, $e)

        $files = $e.Data.GetData([Windows.Forms.DataFormats]::FileDrop)
        Expand-MinecraftPack -Pack $files[0]
    })

$BrowseButton.Add_Click({
        $dialog = New-Object System.Windows.Forms.OpenFileDialog
        $dialog.Filter = 'Minecraft Resource Pack (*.mcpack)|*.mcpack'

        if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            Expand-MinecraftPack -Pack $dialog.FileName
        }
    })

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
    $downloadMcLauncherMenuItem.add_Click({ Start-Process -FilePath "https://github.com/MCMrARM/mc-w10-version-launcher" })
    $sideloadersMenu.MenuItems.Add($downloadMcLauncherMenuItem) | Out-Null

    $downloadBedrockLauncherMenuItem = New-Object System.Windows.Forms.MenuItem
    $downloadBedrockLauncherMenuItem.Text = $T.download + " &Bedrock Launcher"
    $downloadBedrockLauncherMenuItem.add_Click({ Start-Process -FilePath "https://github.com/BedrockLauncher/BedrockLauncher" })
    $sideloadersMenu.MenuItems.Add($downloadBedrockLauncherMenuItem) | Out-Null
}

if (!$ioBit) {
    $downloadIoBitMenuItem = New-Object System.Windows.Forms.MenuItem
    $downloadIoBitMenuItem.Text = $T.download + " &IObit Unlocker"
    $downloadIoBitMenuItem.add_Click({ Start-Process -FilePath "https://www.iobit.com/en/iobit-unlocker.php" })
    $fileMenu.MenuItems.Add($downloadIoBitMenuItem) | Out-Null
}

$backupMenuItem = New-Object System.Windows.Forms.MenuItem
$backupMenuItem.Text = $T.backup
$backupMenuItem.add_Click({
        foreach ($mc in $dataSrc) {
            if ($ListBox.SelectedItems.Count -gt 0 -and $ListBox.SelectedItems -notcontains $mc.FriendlyName) {
                continue
            }
            Backup-ShaderFiles -Location $mc.InstallLocation
        }
    })

$fileMenu.MenuItems.Add($backupMenuItem) | Out-Null
$mainMenu.MenuItems.Add($fileMenu) | Out-Null

$helpMenu = New-Object System.Windows.Forms.MenuItem
$helpMenu.Text = $T.help
$mainMenu.MenuItems.Add($helpMenu) | Out-Null

$discordMenuItem = New-Object System.Windows.Forms.MenuItem
$discordMenuItem.Text = "&Discord"
$discordMenuItem.add_Click({ Start-Process -FilePath "https://discord.com/invite/minecraft-rtx-691547840463241267" })
$helpMenu.MenuItems.Add($discordMenuItem) | Out-Null

$gitHubMenuItem = New-Object System.Windows.Forms.MenuItem
$gitHubMenuItem.Text = "&GitHub"
$gitHubMenuItem.add_Click({ Start-Process -FilePath "https://github.com/BetterRTX/BetterRTX-Installer" })
$helpMenu.MenuItems.Add($gitHubMenuItem) | Out-Null

$form.Menu = $mainMenu

$form.ShowDialog() | Out-Null
