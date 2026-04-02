$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot

Write-Host "Launching Godot editor for Last Shift Logistics in $root"
Start-Process -FilePath "godot.exe" -ArgumentList @("--editor", "--path", $root)
