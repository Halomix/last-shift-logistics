$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
Write-Host "Validating event flow probe in $root"

$probe = Start-Process -FilePath "godot.exe" -ArgumentList @(
    "--headless",
    "--path", "`"$root`"",
    "--script", "res://scripts/tests/event_flow_probe.gd"
) -Wait -PassThru -NoNewWindow

if ($probe.ExitCode -ne 0) {
    throw "Event flow probe failed"
}

Write-Host "Event flow probe passed."
