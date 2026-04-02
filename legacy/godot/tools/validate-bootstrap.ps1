$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$requiredFiles = @(
    "AGENTS.md",
    ".codex/config.toml",
    "docs/MIGRATION_FROM_HOUSE_IS_LISTENING.md",
    "docs/TOOLS_CAPABILITY.md",
    "docs/GAME_VISION.md",
    "docs/PRODUCTION_PLAN.md",
    "docs/MILESTONES.md",
    "docs/TASK_BOARD.md",
    "docs/DECISIONS.md",
    "docs/BUILD_LOG.md",
    "docs/BLOCKERS.md",
    "docs/NEXT_ACTIONS.md",
    "CODEOWNERS",
    "project.godot"
)

$requiredWorkflow = ".github/workflows/bootstrap-validation.yml"
$secondaryWorkflows = @(
    ".github/workflows/godot-smoke-test.yml",
    ".github/workflows/discord-pr-notifications.yml"
)

Write-Host "Validating bootstrap files in $root"

foreach ($relativePath in $requiredFiles) {
    $fullPath = Join-Path $root $relativePath
    if (-not (Test-Path $fullPath)) {
        throw "Missing required bootstrap file: $relativePath"
    }
}

if (-not (Test-Path (Join-Path $root $requiredWorkflow))) {
    throw "Missing required workflow file: $requiredWorkflow"
}

$migration = Get-Content -Raw (Join-Path $root "docs/MIGRATION_FROM_HOUSE_IS_LISTENING.md")
$tools = Get-Content -Raw (Join-Path $root "docs/TOOLS_CAPABILITY.md")
$agents = Get-Content -Raw (Join-Path $root "AGENTS.md")

foreach ($workflow in $secondaryWorkflows) {
    if (-not (Test-Path (Join-Path $root $workflow))) {
        throw "Missing required workflow file: $workflow"
    }
}

if ($migration -notmatch "What Was Found" -or $migration -notmatch "What Is Being Reused") {
    throw "docs/MIGRATION_FROM_HOUSE_IS_LISTENING.md does not capture the migration inventory."
}

if ($tools -notmatch "House Is Listening" -or $tools -notmatch "Recommended Tool Usage Policy") {
    throw "docs/TOOLS_CAPABILITY.md does not reflect inherited capability state."
}

if ($agents -notmatch "Last Shift Logistics" -or $agents -notmatch "docs/TOOLS_CAPABILITY.md") {
    throw "AGENTS.md does not reference the migrated project brain."
}

Write-Host "Bootstrap validation passed."
