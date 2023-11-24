function CreatePack($url, $dest = ".\download") {
    # Create the destination directory
    New-Item -ItemType Directory -Force -Path $dest

    # Get the JSON data
    $json = Invoke-WebRequest -Uri $url -UseBasicParsing | ConvertFrom-Json
    $subpacks = @()

    # Loop through the JSON data
    foreach ($item in $json) {
        # Make item name safe
        $folder = $item.name.Replace(" ", "_").Replace(".", "_").Replace(":", "").Replace("?", "").Replace("/", "_").Replace("\\", "_").Replace("*", "").Replace("<", "").Replace(">", "").Replace("|", "")

        # Create the directory
        New-Item -ItemType Directory -Force -Path "$dest\$($folder)"

        # Download the stub and tonemapping files
        $stubResult = Invoke-WebRequest -Uri $item.stub -OutFile "$dest\$($folder)\renderer\materials\RTXStub.material.bin"

        if ($stubResult.StatusCode -ne 200) {
            Write-Host "Failed to download stub for $($item.name)"
            # Delete this directory
            Remove-Item -Path "$dest\$($folder)" -Recurse -Force
            continue
        }

        $materialResult = Invoke-WebRequest -Uri $item.tonemapping -OutFile "$dest\$($folder)\renderer\materials\RTXPostFX.Tonemapping.material.bin"

        if ($materialResult.StatusCode -ne 200) {
            Write-Host "Failed to download tonemapping for $($item.name)"
            # Delete this directory
            Remove-Item -Path "$dest\$($folder)" -Recurse -Force
            continue
        }

        # Add to subpacks array
        $subpacks += @{
            name        = $item.name
            folder_name = $folder
            memory_tier = 0
        }
    }

    # Create the manifest
    $manifest = @{
        format_version = 2
        header         = @{
            name               = "BetterRTX"
            description        = "BetterRTX"
            uuid               = [guid]::NewGuid().ToString()
            version            = @(1, 1, 0)
            min_engine_version = @(1, 19, 0)
        }
        modules        = @(
            @{
                type        = "resources"
                uuid        = [guid]::NewGuid().ToString()
                version     = @(1, 1, 0)
                description = "BetterRTX packs"
            }
        )
        subpacks       = $subpacks
    }

    
    # Create the manifest file
    $manifest | Out-File -FilePath "$dest\BetterRTX\manifest.json"

    Copy-Item -Path "$PSScriptRoot\src\pack_icon.png" -Destination "$dest\BetterRTX\pack_icon.png" -Force

    # Create the resource pack
    Compress-Archive -Path "$dest\BetterRTX\*" -DestinationPath "$dest\BetterRTX.mcpack" -Force

    # Remove the BetterRTX folder
    # Remove-Item -Path "$dest\BetterRTX" -Recurse -Force

    return "$dest\BetterRTX.mcpack"
}

param (
    [Parameter(Mandatory = $true)]
    [string]$url
)

CreatePack -url $url
