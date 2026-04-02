# Tooling And Capabilities Report

## Current Runtime Tooling Verdict
- Active runtime target: `roblox/`
- Legacy runtime reference: `legacy/godot/`
- Active validator: `roblox/tools/validate-roblox-scaffold.ps1`
- Roblox Studio: installed locally
- Roblox MCP: configured as `roblox_studio` and now healthy enough for read-only Studio inspection

## Verified In This Roblox Migration Phase
- Roblox-native repo scaffold exists and validates cleanly
- shared Luau config modules exist for districts, routes, cargo, clients, contracts, economy, progression, monetization hooks, and world blueprints
- server-side Roblox services exist for world state, contracts, delivery flow, economy, progression, and ambient life
- client-side controllers exist for HUD, dispatch, interaction, vehicle placeholder, and audio placeholder
- Playwright works through direct `npx --yes --package @playwright/cli playwright-cli`
- Roblox Studio launches locally
- `StudioMCP.exe` responds correctly to `--help`, `--version`, and `--stdio`

## Roblox MCP Status
- `MCP name`: `roblox_studio`
- `Install method`: direct Codex registration using the Roblox-provided `mcp.bat` wrapper
- `Registration succeeded`: yes, in `C:\Users\chizz\.codex\config.toml`
- `Codex can use it in this session`: yes, for live instance listing, tree inspection, script reads, script edits, Luau execution, and playtest control while Studio is open
- `Studio-side handshake confirmed`: yes, for the blank logistics place now being used as the live project foundation
- `Latest retry state`: the bridge exposed the live blank place, allowed direct runtime edits, and supported play mode and console checks during live Roblox work

## Remaining Tooling Blockers
- the Studio bridge is still session-fragile and can require a reopen/reselect cycle
- `rojo` is not installed, so repo-sync convenience is still missing
- the recurring Codex automation remains app-side/manual for now
- no critical tooling blocker remains for the first live Roblox contract slice

## What This Unlocks Already
- filesystem-first Roblox development can continue safely
- live blank-place Roblox assembly can continue directly through the MCP
- the first truck/runtime layer can now be tuned in the real project place instead of in theory
- asset-production planning can proceed against a stable Roblox project structure

## Immediate Next Tooling Step
1. Keep the current blank logistics place open in Studio.
2. Run the first full pickup / handoff / delivery trip.
3. Then shift to tuning route feel, district readability, and persistence priorities.
