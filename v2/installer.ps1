Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Import-LocalizedData -BindingVariable T

$dataSrc = @()

foreach ($mc in (Get-AppxPackage -Name "Microsoft.Minecraft*")) {
    $dataSrc += [PSCustomObject]@{
        FriendlyName    = (Get-AppxPackageManifest -Package $mc).Package.Properties.DisplayName
        InstallLocation = $mc.InstallLocation
    }
}

function Copy-ShaderFiles(
) {
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

    $ioBit = Get-StartApps | Where-Object { $_.Name -eq "IObit Unlocker" }

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

function Expand-MinecraftPack(
    [Parameter(Mandatory = $true)]
    [string]$Pack
) {
    # Check file type
    if ($Pack -notlike "*.mcpack") {
        $StatusLabel.Text = $T.error_invalid_file_type
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

$lineHeight = 25
$windowHeight = ($dataSrc.Count * ($lineHeight * 4))
$windowWidth = 400

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
$form.ShowInTaskbar = $false
$form.Topmost = $true

$flowPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$flowPanel.Dock = 'Fill'
$flowPanel.FlowDirection = 'TopDown'
$flowPanel.WrapContents = $false

$StatusLabel = New-Object System.Windows.Forms.Label
$StatusLabel.Font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
$StatusLabel.Anchor = 'Top'

# Add the browse button
$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Text = $T.browse

$ListLabel = New-Object System.Windows.Forms.Label
$ListLabel.Text = $T.install
$ListLabel.Font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
$ListLabel.ForeColor = 'Black'
$ListLabel.BackColor = [System.Drawing.Color]::FromName("Transparent")

$ListBox = New-Object System.Windows.Forms.ListBox
$ListBox.SelectionMode = 'MultiSimple'
$ListBox.Height = $dataSrc.Count * $lineHeight
$ListBox.Width = $windowWidth - ($browseButton.Width + 20)

foreach ($mc in $dataSrc) {
    $ListBox.Items.Add($mc.FriendlyName) | Out-Null
}

$flowPanel.Controls.Add($StatusLabel)
$flowPanel.Controls.Add($ListLabel)
$flowPanel.Controls.Add($ListBox)
$flowPanel.Controls.Add($browseButton)
$form.Controls.Add($flowPanel)

# Extract on drop
$form.Add_DragDrop({
        param($sender, $e)

        $files = $e.Data.GetData([Windows.Forms.DataFormats]::FileDrop)
        Expand-MinecraftPack -Pack $files[0]
    })

$browseButton.Add_Click({
        # Create a file dialog object
        $dialog = New-Object System.Windows.Forms.OpenFileDialog
        $dialog.Filter = 'Minecraft Resource Pack (*.mcpack)|*.mcpack'
        # $dialog.InitialDirectory = [Environment]::GetFolderPath('Downloads')

        # Show the dialog and check if the user clicked OK
        if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            # Get the selected file
            $file = $dialog.FileName

            # Expand the pack
            Expand-MinecraftPack -Pack $file
        }
    })

$form.ShowDialog()
