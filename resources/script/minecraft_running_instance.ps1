$minecraftProcess = Get-Process Minecraft.Windows | Select-Object -Property Path

if ($null -eq $minecraftProcess) {
    return @{
        "name"    = $null
        "preview" = $null
    } | ConvertTo-Json
}

$name = "Minecraft"
$isPreview = $minecraftProcess.Path.Contains("Beta")

if ($isPreview) {
    $name = "Minecraft Preview"
}

return @{
    "name"    = $name
    "preview" = $isPreview
} | ConvertTo-Json
