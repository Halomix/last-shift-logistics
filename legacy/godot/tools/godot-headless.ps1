$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$scene = if ($args.Count -gt 0 -and $args[0]) { $args[0] } else { "res://scenes/main.tscn" }
$artifactRoot = Join-Path $env:TEMP "last_shift_logistics_godot"
New-Item -ItemType Directory -Path $artifactRoot -Force | Out-Null
$logPath = Join-Path $artifactRoot "godot-headless.log"

Write-Host "Running headless Godot boot for Last Shift Logistics scene $scene"
& godot.exe --headless --path $root --scene $scene --quit-after 1 --log-file $logPath
