Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ioBit = Get-StartApps | Where-Object { $_.Name -eq "IObit Unlocker" }
$MinecraftInstallations = Get-AppxPackage -Name "Microsoft.Minecraft*" 

$lineHeight = 25
$windowHeight = (($MinecraftInstallations.Count * $lineHeight) + ($lineHeight * 2))
if ($windowHeight -lt 200) {
    $windowHeight = 200
}
$windowWidth = $windowHeight * (3 / 2)
$y = $lineHeight

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'BetterRTX Installer'
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

$imagePath = 'https://bedrock.graphics/images/default.jpg'
$pictureBox = New-Object System.Windows.Forms.PictureBox
$pictureBox.Dock = 'Fill'
$pictureBox.SizeMode = 'StretchImage'
$pictureBox.ImageLocation = $imagePath
$pictureBox.Cursor = [System.Windows.Forms.Cursors]::Hand
$form.Controls.Add($pictureBox)

# Add error message placeholder
$errorLabel = New-Object System.Windows.Forms.Label
$errorLabel.Location = New-Object System.Drawing.Point(0, 0)
$errorLabel.Size = New-Object System.Drawing.Size($windowWidth, $lineHeight)
$errorLabel.Text = 'Error'
$errorLabel.Font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
$errorLabel.ForeColor = 'Red'
$errorLabel.BackColor = [System.Drawing.Color]::FromName("Transparent")
$errorLabel.TextAlign = 'MiddleCenter'
$errorLabel.Visible = $false
$form.Controls.Add($errorLabel)

function Get-FriendlyName(
    [Parameter(Mandatory = $true)]
    [string]$Installation
) {
    $manifest = Get-AppxPackageManifest -Package $Installation
    return $manifest.Package.Properties.DisplayName
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
    if ($ioBit) {
        $argList = "/Copy "

        foreach ($file in $Materials) {
            $argList += "`"$file`" "
        }

        $argList += " $mcDest"

        Start-Process -FilePath $ioBit.AppID -ArgumentList $argList -Wait
        return $true
    }

    $errorLabel.Text = "Unable to copy to side-loaded Minecraft installation. Please install IObit Unlocker."
    $errorLabel.Visible = $true
    return $false
}

function Expand-MinecraftPack(
    [Parameter(Mandatory = $true)]
    [string]$Pack
) {
    # Check file type
    if ($Pack -notlike "*.mcpack") {
        $errorLabel.Text = "Invalid file type. Please select a .mcpack file."
        return
    }

    if ($SelectedInstallations.Count -eq 0) {
        $errorLabel.Text = "Please select at least one Minecraft installation."
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
    foreach ($mc in $MinecraftInstallations) {
        $labelName = Get-FriendlyName -Installation $mc
        # Check if the checkbox is checked
        $checkbox = $form.Controls | Where-Object { $_.Text -eq $labelName }

        if (-not $checkbox.Checked) {
            continue
        }

        $success = Copy-ShaderFiles -Location $mc.InstallLocation -Materials ($Materials | Select-Object -ExpandProperty FullName)

        if (-not $success) {
            # Show error message
            Write-Host "Failed to copy files to $mc"
            return
        }
    }

    # Delete the temp directory
    Remove-Item -Path $TempDir -Force -Recurse
}

$y += 20

foreach ($mc in $MinecraftInstallations) {
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Location = New-Object System.Drawing.Point(10, $y)
    $checkbox.Size = New-Object System.Drawing.Size(250, 20)
    $checkbox.Text = Get-FriendlyName -Installation $mc
    $checkbox.Checked = $false

    $form.Controls.Add($checkbox)

    $y += 20
}

# Extract on drop
$form.Add_DragDrop({
        param($sender, $e)

        $files = $e.Data.GetData([Windows.Forms.DataFormats]::FileDrop)
        Expand-MinecraftPack -Pack $files[0]
    })

# Browse on click of background
$pictureBox.Add_Click({
        param($sender, $e)

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


$form.Controls.SetChildIndex($pictureBox, $form.Controls.Count - 1)
# Show the form
$form.ShowDialog()
