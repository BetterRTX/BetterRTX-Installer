. "$PSScriptRoot\guiElements.ps1"

$BetterRTX.controls.AddRange(@($InstanceList, $SplashBanner, $ProgressBar))

[void]$BetterRTX.ShowDialog()