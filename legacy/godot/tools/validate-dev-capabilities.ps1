$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$reportRoot = Join-Path $env:TEMP "last_shift_logistics_dev"
New-Item -ItemType Directory -Path $reportRoot -Force | Out-Null

Write-Host "Validating development capabilities for Last Shift Logistics in $root"

function Assert-Command($name, $label) {
    $cmd = Get-Command $name -ErrorAction SilentlyContinue
    if (-not $cmd) {
        throw "$label is not available on PATH"
    }
    return $cmd.Source
}

function Get-BlenderExecutable {
    $candidatePaths = @()
    if ($env:BLENDER_EXE) {
        $candidatePaths += $env:BLENDER_EXE
    }
    $candidatePaths += @(
        "C:\Program Files\Blender Foundation\Blender 4.5\blender.exe",
        "C:\Program Files\Blender Foundation\Blender 5.1\blender.exe"
    )

    foreach ($candidate in $candidatePaths) {
        if ($candidate -and (Test-Path $candidate)) {
            return $candidate
        }
    }

    throw "Blender executable not found. Set BLENDER_EXE or install Blender in a known location."
}

function Get-KritaExecutable {
    $candidatePaths = @(
        "C:\Program Files\Krita (x64)\bin\krita.exe"
    )

    foreach ($candidate in $candidatePaths) {
        if ($candidate -and (Test-Path $candidate)) {
            return $candidate
        }
    }

    throw "Krita executable not found. Install Krita in the standard Program Files location."
}

$results = [ordered]@{}
$results.git = & git --version
$results.gh = & gh --version | Select-Object -First 2
$results.node = & node --version
$results.npm = & npm --version
$results.python = & python --version
$results.playwright = & playwright --version

$godotVersionPath = Join-Path $reportRoot "godot-version.txt"
if (Test-Path $godotVersionPath) {
    Remove-Item $godotVersionPath -Force
}
$godotVersionProcess = Start-Process -FilePath "godot.exe" -ArgumentList @("--version") -Wait -PassThru -NoNewWindow -RedirectStandardOutput $godotVersionPath
if ($godotVersionProcess.ExitCode -ne 0) {
    throw "Godot version check failed"
}
$results.godot = (Get-Content -Raw $godotVersionPath).Trim()

$results.gitRemote = (& git remote -v) -join "`n"
$results.ghAuth = (& gh auth status) -join "`n"

$playwrightSmokePath = Join-Path $reportRoot "playwright-smoke.txt"
if (Test-Path $playwrightSmokePath) {
    Remove-Item $playwrightSmokePath -Force
}

$env:NODE_PATH = (npm root -g)
node -e "const { chromium } = require('playwright'); (async () => { const browser = await chromium.launch({ headless: true }); const page = await browser.newPage(); await page.goto('data:text/html,<html><title>Dev Capabilities Smoke</title><body>OK</body></html>'); const title = await page.title(); require('fs').writeFileSync(process.argv[1], title, 'utf8'); await browser.close(); })().catch(err => { console.error(err); process.exit(1); });" $playwrightSmokePath

$results.playwrightSmoke = Get-Content -Raw $playwrightSmokePath

$blenderExe = Get-BlenderExecutable
$results.blender = (& $blenderExe --version 2>&1 | Out-String).Trim()
$blenderSmokePath = Join-Path $reportRoot "blender-smoke.py"
@'
import bpy
print("Dev Capabilities Smoke:", bpy.app.version_string)
'@ | Set-Content -Path $blenderSmokePath -Encoding ASCII
$results.blenderSmoke = (& $blenderExe --background --factory-startup --python $blenderSmokePath 2>&1 | Out-String).Trim()

$kritaExe = Get-KritaExecutable
$kritaVersion = (Get-Item $kritaExe).VersionInfo.ProductVersion
$kritaProcess = Start-Process -FilePath $kritaExe -PassThru
try {
    Start-Sleep -Seconds 4
    if ($kritaProcess.HasExited) {
        throw "Krita exited immediately"
    }
    $results.krita = "Krita $kritaVersion"
    $results.kritaSmoke = "Launch smoke succeeded with PID $($kritaProcess.Id)"
}
finally {
    if (-not $kritaProcess.HasExited) {
        Stop-Process -Id $kritaProcess.Id -Force
    }
}

Write-Host "Core environment:"
Write-Host ("- Git: " + $results.git)
Write-Host ("- GitHub CLI: " + ($results.gh -join " | "))
Write-Host ("- Godot: " + $results.godot)
Write-Host ("- Node: " + $results.node)
Write-Host ("- npm: " + $results.npm)
Write-Host ("- Python: " + $results.python)
Write-Host ("- Playwright: " + $results.playwright)
Write-Host ("- Playwright smoke: " + $results.playwrightSmoke)
Write-Host ("- Blender: " + $results.blender)
Write-Host ("- Blender smoke: " + $results.blenderSmoke)
Write-Host ("- Krita: " + $results.krita)
Write-Host ("- Krita smoke: " + $results.kritaSmoke)
Write-Host ("- Git remotes:`n" + $results.gitRemote)
Write-Host ("- GitHub auth:`n" + $results.ghAuth)

Write-Host "Development capability validation passed."
