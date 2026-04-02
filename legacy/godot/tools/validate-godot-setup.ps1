$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$projectPath = Join-Path $root "project.godot"
$pluginPath = Join-Path $root "addons\godot_mcp\plugin.cfg"
$artifactRoot = Join-Path $env:TEMP "last_shift_logistics_godot"
New-Item -ItemType Directory -Path $artifactRoot -Force | Out-Null
$headlessStdout = Join-Path $artifactRoot "godot-setup-headless-stdout.log"
$headlessStderr = Join-Path $artifactRoot "godot-setup-headless-stderr.log"
$editorStdout = Join-Path $artifactRoot "godot-setup-editor-stdout.log"
$editorStderr = Join-Path $artifactRoot "godot-setup-editor-stderr.log"
$versionStdout = Join-Path $artifactRoot "godot-version-stdout.txt"

Write-Host "Validating Godot setup for Last Shift Logistics in $root"

$godot = Get-Command godot.exe -ErrorAction SilentlyContinue
if (-not $godot) {
    throw "godot.exe is not available on PATH"
}

if (Test-Path $versionStdout) {
    Remove-Item $versionStdout -Force
}

$versionProcess = Start-Process -FilePath "godot.exe" -ArgumentList @("--version") -Wait -PassThru -NoNewWindow -RedirectStandardOutput $versionStdout
if ($versionProcess.ExitCode -ne 0) {
    throw "Failed to query Godot version"
}

$version = (Get-Content -Raw $versionStdout).Trim()
Remove-Item $versionStdout -Force
Write-Host "Godot version: $version"
if ($version -notmatch '^4\.6\.1') {
    throw "Expected Godot 4.6.1.x, got '$version'"
}

if (-not (Test-Path $projectPath)) {
    throw "Missing project.godot"
}

if (-not (Test-Path $pluginPath)) {
    throw "Missing Godot MCP plugin.cfg"
}

$projectText = Get-Content -Raw $projectPath
if ($projectText -notmatch 'run/main_scene="res://scenes/main\.tscn"') {
    throw "project.godot does not point to the expected main scene"
}

if ($projectText -notmatch 'res://addons/godot_mcp/plugin\.cfg') {
    throw "project.godot does not enable the Godot MCP editor plugin"
}

Write-Host "Running a headless project boot check..."
$headlessProcess = Start-Process -FilePath "godot.exe" -ArgumentList @(
    "--headless",
    "--path", "`"$root`"",
    "--scene", "res://scenes/main.tscn",
    "--quit-after", "1"
) -Wait -PassThru -NoNewWindow -RedirectStandardOutput $headlessStdout -RedirectStandardError $headlessStderr
if ($headlessProcess.ExitCode -ne 0) {
    throw "Headless Godot boot failed"
}

Write-Host "Running an editor startup check..."
$editorProcess = Start-Process -FilePath "godot.exe" -ArgumentList @(
    "--editor",
    "--headless",
    "--path", "`"$root`"",
    "--quit-after", "1"
) -Wait -PassThru -NoNewWindow -RedirectStandardOutput $editorStdout -RedirectStandardError $editorStderr
if ($editorProcess.ExitCode -ne 0) {
    throw "Editor startup check failed"
}

if ((Test-Path $editorStdout) -or (Test-Path $editorStderr)) {
    $editorLogText = @()
    if (Test-Path $editorStdout) {
        $editorLogText += Get-Content -Raw $editorStdout
    }
    if (Test-Path $editorStderr) {
        $editorLogText += Get-Content -Raw $editorStderr
    }
    $editorLogText = $editorLogText -join "`n"
    if ($editorLogText -notmatch 'MCP SERVER STARTING') {
        Write-Warning "Godot editor started, but the MCP plugin start marker was not found in the log."
    }
}

Write-Host "Godot setup validation passed."
