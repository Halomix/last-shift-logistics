# Expansion Sprint Plan

## Goal
Use this sprint to push Last Shift Logistics toward a Roblox-facing vertical-slice shape:
- larger, more legible city
- stronger repeatable session loop
- better return-value and progression hooks
- more living-world presence
- clearer asset and Roblox-transition readiness

## Milestones
1. Audit and doc alignment - complete
2. World and route expansion - complete
3. Core loop / progression / retention upgrade - complete
4. World-life and simulation-presence pass - complete
5. Playtest-driven tuning and readiness documentation - complete

## Guardrails
- Keep damage disabled until explicitly re-enabled by the user.
- Prefer replayability, progression clarity, and logistics fantasy over shallow decoration.
- Validate after each milestone.
- Leave the repo in a stable, documented state.

## Validation Loop
- `.\scripts\validate-godot-setup.ps1`
- `.\scripts\validate-event-flow.ps1`
- `.\scripts\validate-world-expansion.ps1`
- `godot.exe --headless --path . --scene res://scenes/main.tscn --quit-after 1`
- `git diff --check`

## Outcome
- The city now supports multi-stop logistics chains, rotating offer boards, featured-district incentives, district mastery, and dispatch streak bonuses.
- Ambient workers, vans, and a forklift give the graybox a stronger sense of operational life.
- The repo is still ready for asset production.
- The repo is now also ready to begin Roblox transition planning, though not yet ready for direct conversion implementation.
