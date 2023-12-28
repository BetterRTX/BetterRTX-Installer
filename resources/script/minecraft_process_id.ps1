$processID = (Get-Process -Name "Minecraft.Windows" -ErrorAction SilentlyContinue).Id

@{
    "processID" = $processID
} | ConvertTo-Json

