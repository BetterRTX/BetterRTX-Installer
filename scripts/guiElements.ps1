. "$PSScriptRoot\lib.ps1"

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$BetterRTX = New-Object system.Windows.Forms.Form
$BetterRTX.ClientSize = New-Object System.Drawing.Point(481, 637)
$BetterRTX.text = "BetterRTX Installer"
$BetterRTX.TopMost = $false
$BetterRTX.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#ffffff")

$ProgressBar = New-Object System.Windows.Forms.ProgressBar
$ProgressBar.Minimum = 0
$ProgressBar.Maximum = 100
$ProgressBar.Value = 0
$ProgressBar.Width = 200
$ProgressBar.Height = 20
$ProgressBar.Location = New-Object System.Drawing.Point(245, 200)
$ProgressBar.Style = "Continuous"
$ProgressBar.Visible = $false

$Menu = New-Object System.Windows.Forms.MenuStrip
$FileMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$FileMenu.Text = "File"

$BackupOption = New-Object System.Windows.Forms.ToolStripMenuItem
$BackupOption.Text = "Backup Minecraft"
$BackupOption.Add_Click({
        BackupMinecraft
    })

$RestoreOption = New-Object System.Windows.Forms.ToolStripMenuItem
$RestoreOption.Text = "Restore Minecraft"
$RestoreOption.Add_Click({
        RestoreMinecraft
    })

if (-not (Test-Path "$comMojangBackup") && -not (Test-Path "$previewComMojangBackup")) {
    $RestoreOption.Enabled = $false
}

$FileMenu.DropDownItems.AddRange(@($BackupOption, $RestoreOption))
$Menu.Items.Add($FileMenu)
$BetterRTX.Controls.Add($Menu)

$SplashBanner = New-Object system.Windows.Forms.PictureBox
$SplashBanner.Width = 233
$SplashBanner.Height = 131
$SplashBanner.location = New-Object System.Drawing.Point(0, 1)
$SplashBanner.imageLocation = "https://user-images.githubusercontent.com/81783950/257937236-ef6a098d-3f54-48cf-ad83-1a709d251fd1.png"
$SplashBanner.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::zoom
$SplashBanner.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#f2f2f2")

$InstanceList = New-Object system.Windows.Forms.Groupbox
$InstanceList.height = 50
$InstanceList.AutoSize = $true
$InstanceList.width = 464
$InstanceList.text = "Instances"
$InstanceList.location = New-Object System.Drawing.Point(7, 149)

$point = 29

Get-AppxPackage -Name "Microsoft.Minecraft*" | ForEach-Object {
    $CheckBox = New-Object system.Windows.Forms.CheckBox
    $CheckBox.text = $_.Name
    $CheckBox.AutoSize = $false
    $CheckBox.width = 400
    $CheckBox.height = 20
    $CheckBox.location = New-Object System.Drawing.Point(10, $point)
    $CheckBox.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
    $InstanceList.Height += 30
    $InstanceList.controls.AddRange(@($CheckBox))

    $point += 30
}

$Install = New-Object system.Windows.Forms.Button
$Install.text = "Install Preset"
$Install.width = 226
$Install.height = 32
$Install.enabled = $false
$Install.location = New-Object System.Drawing.Point(245, 595)
$Install.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
