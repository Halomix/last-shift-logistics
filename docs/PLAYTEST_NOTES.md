# Playtest Notes

## 2026-04-02 - Live Vehicle Translation Validation
### Test Passes
- live contract acceptance through `RequestBoardState`, `AcceptContract`, and `BeginShift`
- live truck seat flow through `RequestVehicleSeat`
- live truck forward movement through `UpdateVehicleInput`
- `powershell -ExecutionPolicy Bypass -File roblox\\tools\\validate-roblox-scaffold.ps1`
- `git diff --check`

### What Worked
- The truck now moves forward in the live blank-place logistics world.
- The player can:
  - open the dispatch board
  - accept a job
  - start a shift
  - seat into the truck
  - move the truck out of the bay
- The shared depot still reads like a social logistics space while the movement fix is in place.

### What Felt Weak Or Risky
- Full pickup / handoff / delivery completion in live Studio is still not fully proven yet.
- Vehicle feel is functional, but not yet tuned for stronger weight, cornering feel, or route-specific readability.

### Fixes Applied After The Pass
- excluded the owning player character from the truck obstruction probe more reliably
- made the depot canopy and gate beam non-colliding so overhead dressing stopped blocking the drive lane
- removed temporary debug attributes after confirming the motion fix

## 2026-04-02 - Live Blank-Place Roblox Slice Assembly
### Test Passes
- `mcp__roblox_studio__list_roblox_studios`
- `mcp__roblox_studio__set_active_studio`
- `mcp__roblox_studio__search_game_tree` on `Workspace`, `ReplicatedStorage`, `StarterPlayer`, `Players`, and `ServerScriptService`
- `mcp__roblox_studio__inspect_instance` on the dispatch board, truck, truck seat, and live player data
- `mcp__roblox_studio__script_read` on live Roblox scripts in edit mode
- `mcp__roblox_studio__multi_edit` for direct Studio script fixes
- `mcp__roblox_studio__execute_luau` for live contract acceptance, seat checks, and runtime diagnostics
- `mcp__roblox_studio__start_stop_play`
- `mcp__roblox_studio__get_console_output`
- `mcp__roblox_studio__screen_capture`
- `powershell -ExecutionPolicy Bypass -File roblox\\tools\\validate-roblox-scaffold.ps1`
- `git diff --check`

### What Worked
- The blank Roblox place was confirmed and used as the live project foundation.
- The live depot/hub now exists in Studio with:
  - dispatch board
  - crew board
  - leaderboard/showcase pads
  - truck bays
  - route signage
  - pickup / handoff / delivery nodes
  - ambient depot actors
- The dispatch board is visible and readable in play.
- A contract can be accepted live and a shift can be started live.
- The truck now assembles as a real model in play instead of only leaving an `OwnerUserId` marker.
- The player can be seated in the live truck successfully.

### What Felt Weak Or Risky
- Truck motion is still not translating under live input.
- The vehicle loop is therefore only partially proven:
  - spawn/use works
  - seat works
  - assignment state works
  - movement still does not
- This is currently the biggest thing preventing the Roblox slice from feeling like the intended final game in the docs.

### Fixes Applied After The Pass
- Removed duplicated trailing source from several live server scripts.
- Fixed the dispatch board SurfaceGui path.
- Reworked the live truck runtime to track `RootCFrame` directly instead of relying on a broken model pivot.
- Added an explicit `UpdateVehicleInput` remote path.
- Made truck-bay markers non-colliding.
- Raised and tightened the truck obstruction box to stop floor self-collision.
- Replaced `math.sign` in the vehicle runtime with a local helper for Luau safety.

## 2026-04-02 - Milestone 5: Roblox MCP Recovery And Dispatch Readability
### Test Passes
- `mcp__roblox_studio__list_roblox_studios`
- `mcp__roblox_studio__set_active_studio`
- `mcp__roblox_studio__search_game_tree` on `Workspace`, `ServerScriptService`, `ReplicatedStorage`, and `StarterPlayer`
- `mcp__roblox_studio__inspect_instance` on `Workspace`
- `powershell -ExecutionPolicy Bypass -File roblox\\tools\\validate-roblox-scaffold.ps1`
- `git diff --check`

### What Worked
- The Roblox MCP bridge finally came up and exposed the live Studio instance in read-only mode.
- The active place title was visible as `Sgchau_1's Place`.
- Local Roblox scaffold validation still passed after the new HUD, progression, truck-label, and wayfinding changes.
- The depot/dispatch loop is easier to read on paper now because jobs surface route type, cargo family, client badge, ETA, and public queue state.

### What Felt Weak Or Risky
- The live Studio place is not the repo-aligned logistics game yet; its tree showed unrelated props/foliage content instead of the new logistics runtime.
- The Studio bridge later dropped entirely when the active Studio session disconnected, so live MCP use is still session-fragile.
- We still do not have a real in-Studio drive test of the Roblox truck layer.

### Fixes Applied After The Pass
- Logged the real blocker as place alignment / session stability instead of "MCP not configured."
- Improved the filesystem-first Roblox loop so the next live Studio sync lands with a clearer dispatch board, stronger public progression, and depot wayfinding already in place.
- Kept the next action focused on opening the correct place and performing the first live truck tune instead of redoing migration work.

## 2026-04-02 - Milestone 4: Roblox Truck Layer And Depot Graybox
### Test Passes
- `functions.list_mcp_resources` against `roblox_studio` with Roblox Studio open
- `functions.list_mcp_resource_templates` against `roblox_studio` with Roblox Studio open
- `powershell -ExecutionPolicy Bypass -File roblox\\tools\\validate-roblox-scaffold.ps1`
- `git diff --check`

### What Worked
- The active Roblox scaffold still validates after adding the first real truck/runtime layer.
- The depot now has stronger logistics-space identity through office massing, canopy, lane stripes, gate framing, and stronger delivery compounds.
- The contract loop is now wired into truck handling, so cargo and route identity can affect feel once live tuning starts.
- The truck/use flow is clearer on paper: prompt to enter, `F` to exit, `R` to reset to depot.

### What Felt Weak Or Risky
- This run could not do a real in-Studio playtest because `roblox_studio` still timed out even with Roblox Studio open.
- Seating behavior and moment-to-moment drive feel are still unverified in a live Roblox session.
- The current truck layer is a controlled anchored-movement baseline, not a final chassis.

### Fixes Applied After The Pass
- Logged the MCP timeout as a specific live Studio blocker instead of a vague “not ready” note.
- Kept the implementation multiplayer-safe and extension-friendly so tuning can happen without ripping the system apart.
- Moved the next batch toward live vehicle tuning and post-drive prioritization instead of redoing scaffold work.

## 2026-04-02 - Milestone 1: World Footprint And Hub Expansion
### Test Passes
- `.\scripts\validate-godot-setup.ps1`
- `.\scripts\validate-event-flow.ps1`
- `godot.exe --headless --path . --scene res://scenes/main.tscn --quit-after 1`

### What Worked
- The project still booted after the larger map, added districts, added hubs, and expanded zone definitions.
- The existing starter contract still completed through the event probe without regression.
- The larger road footprint and added support hubs did not break spawn or startup flow.

### What Felt Weak Or Risky
- The new larger city needed a stronger gameplay reason to use the new spaces.
- The expanded selection list needed progression structure so it did not feel like extra rows without meaning.

### Fixes Applied After The Pass
- Added contract unlock gates.
- Added staged handoff jobs.
- Added clearer support-hub usage inside the shift loop.

## 2026-04-02 - Milestone 2: Progression, Staged Jobs, And Schedule Pressure
### Test Passes
- `.\scripts\validate-godot-setup.ps1`
- `.\scripts\validate-event-flow.ps1`
- `.\scripts\validate-world-expansion.ps1`
- `godot.exe --headless --path . --scene res://scenes/main.tscn --quit-after 1`
- `mcp__godot__godot_boot` on `res://scenes/main.tscn`
- `git diff --check`

### What Worked
- Staged contracts successfully required a handoff stop before final delivery.
- Completed-shift progression unlocked later contracts.
- Schedule pressure and payout logic stayed stable.
- The new world-expansion probe verified staged delivery, progression, and payout end-to-end.

### What Felt Weak Or Risky
- The current automated tests cannot measure true driving feel through the larger route network.
- The known `ObjectDB instances leaked at exit` warning still appears on headless exits.

### Fixes Applied After The Pass
- Removed accidental double application of cargo handling modifiers.
- Kept damage disabled during this phase so playtesting can focus on route/world flow instead of failure-state noise.

## Current Honest Read
- The game is much closer to a production-ready graybox than it was at the start of the sprint.
- The next tests should include human play through the new Brightline and Old Transit jobs, especially the staged handoff flow and the larger map readability.

## 2026-04-02 - Milestone 3: Roblox-Facing Retention And World-Life Pass
### Test Passes
- `.\scripts\validate-godot-setup.ps1`
- `.\scripts\validate-event-flow.ps1`
- `.\scripts\validate-world-expansion.ps1`
- `godot.exe --headless --path . --scene res://scenes/main.tscn --quit-after 1`
- `mcp__godot__godot_boot` on `res://scenes/main.tscn`
- `git diff --check`

### What Worked
- The expanded city still boots cleanly after adding ambient workers, vans, and a forklift.
- The late-game contract flow now supports a full pickup -> handoff -> final-delivery chain and the automated probe still passes.
- Rotating offer boards, featured-district bonuses, district mastery, and dispatch streak logic now give the player clearer reasons to keep taking "one more shift."
- The world feels more like an active logistics network instead of a quiet map with only the player moving through it.

### What Felt Weak Or Risky
- The new retention/progression layer is still session-local; there is no true save/meta persistence yet.
- The world has presence now, but not full traffic or player-to-player social life.
- The Roblox-facing direction is clear, but there is not yet a repo-level Roblox sync/build pipeline.

### Fixes Applied After The Pass
- Upgraded the regression probe to cover the new multi-stop contract chain.
- Verified Roblox Studio is installed locally so transition planning can be grounded in a real capability check.
- Kept the new board/streak incentives lightweight so they deepen the loop without turning the HUD back into a text wall.
