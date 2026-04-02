$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
Write-Host "Validating world expansion probe in $root"

$probe = Start-Process -FilePath "godot.exe" -ArgumentList @(
    "--headless",
    "--path", "`"$root`"",
    "--script", "res://scripts/tests/world_expansion_probe.gd"
) -Wait -PassThru -NoNewWindow

if ($probe.ExitCode -ne 0) {
    throw "World expansion probe failed"
}

Write-Host "World expansion probe passed."
