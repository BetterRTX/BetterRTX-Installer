$results = @{}

$target = if ($args[0] -eq "beta") { "Microsoft.MinecraftBeta" } else { "Microsoft.MinecraftUWP" }

Get-AppxPackage $target | Select-Object -Property Version, PackageFullName, @{Name = "InstallLocation"; Expression = { $_.InstallLocation } } | ForEach-Object {
    $version = $_.Version
    $name = $_.PackageFullName
    $location = $_.InstallLocation

    $results[$version] = @{
        "name"     = $name
        "location" = $location
    }
}

$results | ConvertTo-Json
