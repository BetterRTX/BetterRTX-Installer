New-Item -Path "${$PSScriptRoot}output" -ItemType Directory -ErrorAction SilentlyContinue
$output = Join-Path "${PSScriptRoot}" "output"

$zip = @{
    Path = "${$PSScriptRoot}Localized/*", "${$PSScriptRoot}BetterRTX_Installer.ps1", "${$PSScriptRoot}../CHANGELOGS.md", "${$PSScriptRoot}../LICENSE.md", "${$PSScriptRoot}../README.md", "${$PSScriptRoot}../CREDITS.md", "${$PSScriptRoot}../CODE_OF_CONDUCT.md"
    CompressionLevel = "Optimal"
    DestinationPath = Join-Path $output "BetterRTX_Installer.zip"
}
Compress-Archive @zip -Force

Copy-Item -Path "${$PSScriptRoot}BetterRTX_Installer.ps1" -Destination $output -Force

.\hashinstaller.ps1 -zip "${$PSScriptRoot}output/BetterRTX_Installer.zip" -psscript "${$PSScriptRoot}output/BetterRTX_Installer.ps1"
