$results = @{}

Get-AppxPackage -Name "Microsoft.Minecraft*" | Select-Object -Property Name, @{Name = "InstallLocation"; Expression = { $_.InstallLocation } } | ForEach-Object {
    $name = $_.Name
    $location = $_.InstallLocation

    $results[$name] = $location
}

$results | ConvertTo-Json
