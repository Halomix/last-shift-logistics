$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..\\..")
$requiredFiles = @(
	"roblox/default.project.json",
	"roblox/src/ReplicatedStorage/Shared/Config/Districts.lua",
	"roblox/src/ReplicatedStorage/Shared/Config/Contracts.lua",
	"roblox/src/ReplicatedStorage/Shared/Config/VehicleConfig.lua",
	"roblox/src/ReplicatedStorage/Net/RemoteNames.lua",
	"roblox/src/ServerScriptService/Bootstrap.server.lua",
	"roblox/src/ServerScriptService/Services/VehicleService.lua",
	"roblox/src/StarterPlayer/StarterPlayerScripts/Bootstrap.client.lua",
	"legacy/godot/project.godot"
)

$missing = @()
foreach ($relative in $requiredFiles) {
	$full = Join-Path $root $relative
	if (-not (Test-Path $full)) {
		$missing += $relative
	}
}

if ($missing.Count -gt 0) {
	Write-Error ("Missing required Roblox migration files:`n - " + ($missing -join "`n - "))
}

$projectFile = Join-Path $root "roblox/default.project.json"
$json = Get-Content $projectFile -Raw | ConvertFrom-Json
if ($json.name -ne "LastShiftLogistics") {
	Write-Error "Unexpected Roblox project name in default.project.json"
}

if (Test-Path (Join-Path $root "project.godot")) {
	Write-Error "Godot project.godot still exists at repo root; expected it under legacy/godot"
}

Write-Host "Roblox scaffold validation passed."
