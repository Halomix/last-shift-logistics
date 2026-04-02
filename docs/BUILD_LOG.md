# Build Log

## 2026-04-02 - Live Truck Translation Fix
### What changed
- Finished the first working Roblox-native truck translation baseline in the live blank-place logistics world.
- Fixed the last movement blockers by:
  - excluding the owning player character reliably from the truck obstruction probe
  - making the dispatch canopy and gate beam non-colliding so overhead depot dressing no longer blocks the truck lane
- Confirmed the explicit `UpdateVehicleInput` remote path works with the anchored logistics baseline.
- Removed the temporary runtime debug attributes after the fix was proven.

### What was tested
- live contract accept in Studio
- live shift start in Studio
- live vehicle seat/use flow in Studio
- live remote-driven forward movement in Studio
- `powershell -ExecutionPolicy Bypass -File roblox\\tools\\validate-roblox-scaffold.ps1`
- `git diff --check`

### Notes
- The truck now translates forward in the live place.
- The Roblox slice now has:
  - shared depot
  - readable dispatch board
  - public progression
  - contract acceptance
  - shift start
  - seatable truck
  - working forward truck movement
- The next step is no longer fixing the vehicle baseline; it is running the first full route-node and delivery validation pass.

## 2026-04-02 - Live Blank-Place Roblox Slice Assembly And Vehicle Runtime Debug
### What changed
- Used the healthy `roblox_studio` MCP against the confirmed blank place `Place1` and treated it as the live project foundation.
- Built the first real Roblox logistics slice directly into the blank Studio place:
  - shared depot / central hub
  - dispatch board
  - crew board
  - leaderboard / showcase pads
  - truck bays
  - route signage
  - pickup / handoff / delivery nodes
  - ambient depot actors
- Fixed a live Studio import regression where several server scripts had duplicated trailing source after `return`.
- Fixed the dispatch board SurfaceGui runtime issue in the live place.
- Stabilized the live truck assembly:
  - the truck now spawns with chassis, cab, cargo bed, seat, wheels, headlights, and brake lights
  - the truck now spawns at the correct depot height instead of drifting into a broken pivot state
- Added an explicit Roblox-native vehicle input path on disk and in Studio:
  - `UpdateVehicleInput` remote
  - client drive-input controller bindings
  - server-side input handling in `VehicleService`
- Made truck-bay visual markers non-blocking and raised/tightened the collision probe so depot floor geometry does not block the truck baseline.
- Replaced `math.sign` in the vehicle runtime with a local helper for Luau safety.

### What was tested
- `mcp__roblox_studio__list_roblox_studios`
- `mcp__roblox_studio__set_active_studio`
- `mcp__roblox_studio__search_game_tree`
- `mcp__roblox_studio__inspect_instance`
- `mcp__roblox_studio__script_read`
- `mcp__roblox_studio__multi_edit`
- `mcp__roblox_studio__execute_luau`
- `mcp__roblox_studio__start_stop_play`
- `mcp__roblox_studio__get_console_output`
- `mcp__roblox_studio__screen_capture`
- `powershell -ExecutionPolicy Bypass -File roblox\\tools\\validate-roblox-scaffold.ps1`
- `git diff --check`

### Notes
- The blank Studio place is now the correct live project place and no longer a setup blocker.
- The dispatch/job loop is live enough to open the board, inspect shared-ready jobs, accept a contract, begin a shift, and seat the player in the truck.
- The remaining live blocker is now specific and honest:
  - truck translation still does not respond under live input
  - this is now a focused vehicle-motion debugging task, not a migration, alignment, or world-assembly task

## 2026-04-02 - Roblox MCP Recovery And Dispatch Readability Pass
### What changed
- Switched the Codex-side Roblox MCP config to the Studio-provided wrapper path:
  - `cmd.exe /c %LOCALAPPDATA%\\Roblox\\mcp.bat --stdio`
- Re-checked `roblox_studio` and confirmed the bridge could:
  - list Studio instances
  - set the active Studio
  - inspect the live tree in read-only mode
- Confirmed the currently open Studio place was `Sgchau_1's Place` and not the repo-aligned logistics project, so I did not push blind Studio edits into the wrong place.
- Tightened the Roblox filesystem-first implementation instead:
  - richer assignment packets
  - clearer board rows with route/cargo/client detail
  - stronger public truck / player activity signals
  - next-unlock and company-rank readouts in the HUD
  - depot wayfinding signs for north/east/west route exits
- Preserved Roblox as the active runtime target and left Godot archived as legacy-only reference.

### What was tested
- `mcp__roblox_studio__list_roblox_studios`
- `mcp__roblox_studio__set_active_studio`
- `mcp__roblox_studio__search_game_tree`
- `mcp__roblox_studio__inspect_instance`
- `powershell -ExecutionPolicy Bypass -File roblox\\tools\\validate-roblox-scaffold.ps1`
- `git diff --check`

### Notes
- `roblox_studio` is no longer blocked at startup; the bridge can come up and expose Studio instances.
- The open Studio place was not aligned with the repo runtime, so filesystem-first remained the source of truth for this batch.
- The bridge later dropped when the Studio session disconnected, so the remaining live-tooling issue is session stability and place alignment, not initial MCP registration.

## 2026-04-02 - Roblox Vehicle And Depot Graybox Pass
### What changed
- Re-checked `roblox_studio` in a fresh session with Roblox Studio open and confirmed it still times out on `tools/list`.
- Added the first real Roblox-native vehicle/chassis layer:
  - `roblox/src/ReplicatedStorage/Shared/Config/VehicleConfig.lua`
  - `roblox/src/ServerScriptService/Services/VehicleService.lua`
- Added owner-assigned company trucks with:
  - prompt-based entry
  - reset-to-bay support
  - route/cargo-aware handling modifiers
  - public owner/fleet billboards
  - headlights and brake-light feedback
- Wired the contract loop into vehicle load state so accepting a contract now changes truck handling and completing/resetting a shift clears that load state.
- Upgraded the procedural depot/world graybox in `WorldStateService.lua` with:
  - depot office massing
  - dispatch canopy
  - container stacks
  - lane stripes
  - gate structures
  - stronger delivery-node compounds and dock lots
- Upgraded interaction flow so trucks can be entered by prompt and exited with `F`.
- Extended the Roblox scaffold validator so it now checks for the active vehicle runtime files too.
- Added `docs/VEHICLE_IMPLEMENTATION_NOTES.md` to preserve the new vehicle architecture and limitations.

### What was tested
- `functions.list_mcp_resources` against `roblox_studio` with Roblox Studio open
- `functions.list_mcp_resource_templates` against `roblox_studio` with Roblox Studio open
- `powershell -ExecutionPolicy Bypass -File roblox\\tools\\validate-roblox-scaffold.ps1`
- `git diff --check`

### Notes
- Roblox Studio launched successfully, but `roblox_studio` still timed out awaiting `tools/list`, so no live Studio inspection or in-Studio playtest was possible in this run.
- The vehicle layer is now real on disk, but it still needs live Studio tuning for movement feel and seating behavior.

## 2026-04-02 - Roblox Social Hub And Public Activity Pass
### What changed
- Expanded the Roblox shared depot into a more visibly social space with:
  - a crew status board
  - public showcase pads
  - richer public leaderboard lines
  - stronger live depot presence messaging in the HUD
- Updated the Roblox dispatch UI so it now reads more clearly as a public jobs board with:
  - section headers
  - richer contract rows
  - visible crew-slot language
  - toggle-open / toggle-close behavior on `B`
- Updated progression signaling so public player billboards refresh with live company level, fleet tier, and delivery count instead of only updating on respawn.
- Fixed Roblox contract slot bookkeeping so reset/removal/completion paths release reserved board slots cleanly.
- Updated public crew-board refresh behavior so stage progression is reflected on shared boards instead of only in the local player's state.
- Rewrote the tools capability docs to make Roblox the active runtime and Godot the archived legacy reference.

### What was tested
- `powershell -ExecutionPolicy Bypass -File roblox\\tools\\validate-roblox-scaffold.ps1`
- `git diff --check`

### Notes
- The active Roblox scaffold remains healthy after the social/runtime pass.
- `roblox_studio` was later re-checked with Studio open and still timed out on `tools/list`, so live Studio inspection remains blocked.

## 2026-04-02 - Roblox Runtime Migration Batch
### What changed
- Moved the active Godot runtime out of the repo root and archived it under `legacy/godot`.
- Removed generated Godot/editor/playtest artifacts from the active root.
- Created the active Roblox-native source tree under `roblox/`.
- Added the first Roblox-native shared config modules for districts, routes, cargo, clients, contracts, economy, progression, monetization hooks, and world blueprints.
- Added the first server-side Roblox services:
  - `WorldStateService`
  - `ProgressionService`
  - `RouteService`
  - `EconomyService`
  - `DeliveryService`
  - `AmbientLifeService`
  - `ContractService`
- Added the first client-side Roblox controllers:
  - `HudController`
  - `DispatchController`
  - `InteractionController`
  - `VehicleController`
  - `AudioController`
- Added `roblox/default.project.json` and `roblox/tools/validate-roblox-scaffold.ps1`.
- Created the migration docs:
  - `MIGRATION_PLAN.md`
  - `GODOT_TO_ROBLOX_MAPPING.md`
  - `ROBLOX_ARCHITECTURE.md`
  - `LEGACY_GODOT_ARCHIVE_PLAN.md`
- Updated the project brain so Roblox is the active runtime target and Godot is legacy reference only.

### What was tested
- `functions.list_mcp_resources` and `functions.list_mcp_resource_templates` against `roblox_studio`
- Roblox Studio process launch and presence check
- `roblox/tools/validate-roblox-scaffold.ps1`

### Notes
- `roblox_studio` is still not healthy in this session: MCP startup times out on `tools/list` even with Studio open.
- The filesystem-first migration is still valid and unblocked, but live Studio inspection/editing is not available yet.
- The new Roblox code is scaffold-first and service-oriented; it still needs live Studio validation and vehicle/chassis implementation.

## 2026-04-02 - Roblox MCP Bootstrap
### What changed
- Audited the live Codex MCP surface and confirmed there was no Roblox MCP configured at session start.
- Verified the built-in Roblox Studio MCP binary already ships with the installed Roblox Studio build:
  - `C:\Users\chizz\AppData\Local\Roblox\Versions\version-ac9bdbe6aedb4e5e\StudioMCP.exe`
- Verified the binary supports:
  - `--help`
  - `--version`
  - `--stdio`
- Registered a new Codex MCP entry in `C:\Users\chizz\.codex\config.toml`:
  - name: `roblox_studio`
  - command: `StudioMCP.exe`
  - args: `--stdio`
- Updated Roblox capability and transition docs with the exact remaining human step.

### What was tested
- `functions.list_mcp_resources` and `functions.list_mcp_resource_templates` to check current MCP availability
- `StudioMCP.exe --help`
- `StudioMCP.exe --version`
- `StudioMCP.exe --stdio --verbose` startup probe

### Notes
- Registration succeeded in Codex config, but the current live Codex session does not hot-reload new MCP definitions.
- The current session still reports `unknown MCP server 'roblox_studio'`, so a full Codex restart is required before the server can be used in-run.
- Live Studio-side connection is not yet confirmed.
- No separate Roblox plugin installation was discovered locally, and the strongest upstream guidance indicates the built-in Studio MCP path is now primary.

## 2026-04-02 - Roblox-Facing Expansion And Transition Sprint
### What changed
- Added rotating offer-board modifiers, featured-district incentives, and streak-sensitive shift framing so repeat runs have stronger retention pull.
- Added ambient world-life actors: workers, a forklift, and moving vans to make the logistics network feel operational.
- Upgraded the late-game contracts into multi-stop logistics chains with pickup, handoff, and final delivery stages.
- Added district mastery growth, dispatch streak bonuses, and stronger summary reporting so repeated shifts feel like company progression instead of isolated runs.
- Updated the world-expansion regression probe so it now verifies the more complex pickup -> handoff -> delivery chain.
- Verified Roblox transition capability locally: Roblox Studio is installed, `StudioMCP.exe` exists, and `rojo` is not installed.
- Created Roblox-facing readiness/reporting docs and updated the project brain to preserve the new direction.

### What was tested
- `.\scripts\validate-godot-setup.ps1`
- `.\scripts\validate-event-flow.ps1`
- `.\scripts\validate-world-expansion.ps1`
- `godot.exe --headless --path . --scene res://scenes/main.tscn --quit-after 1`
- `mcp__godot__godot_boot` on `res://scenes/main.tscn`
- `git diff --check`
- Playwright CLI research on Roblox Creator Hub discovery docs

### Notes
- All validations passed after the multi-stop contract and world-life changes.
- The known `ObjectDB instances leaked at exit` warning still appears on headless exit, but it remains non-blocking.
- Damage remains intentionally disabled by explicit user request.
- The project is still `READY FOR ASSETS`.
- The project is now also ready to begin Roblox transition planning, though not actual Roblox conversion implementation yet.

## 2026-04-02 - Major Graybox World Expansion Sprint
### What changed
- Expanded the city footprint with more major roads, district silhouettes, support hubs, signage, and graybox infrastructure.
- Added two new delivery districts: `Brightline Civic` and `Old Transit`.
- Added four support hubs: `Northline Crossdock`, `Compliance Gate`, `Relay Yard`, and `Service Apron`.
- Added two new contracts, two new cargo types, new client/faction flavor, unlock-gated jobs, staged handoff jobs, schedule pressure, and cumulative credit tracking.
- Added `scripts/tests/world_expansion_probe.gd` and `scripts/validate-world-expansion.ps1` to verify the new staged/progression flow.
- Created asset-readiness and next-stage documentation:
  - `docs/WORLD_EXPANSION_REPORT.md`
  - `docs/PLAYTEST_NOTES.md`
  - `docs/READY_FOR_ASSETS.md`
  - `docs/ASSET_REQUIREMENTS.md`
  - `docs/NEXT_STAGE_PLAN.md`

### What was tested
- `.\scripts\validate-godot-setup.ps1`
- `.\scripts\validate-event-flow.ps1`
- `.\scripts\validate-world-expansion.ps1`
- `godot.exe --headless --path . --scene res://scenes/main.tscn --quit-after 1`
- `mcp__godot__godot_boot` on `res://scenes/main.tscn`
- `git diff --check`

### Notes
- The new world-expansion probe passed, confirming staged jobs, progression, and payout.
- Damage remains intentionally disabled for playtesting by explicit user request.
- The known `ObjectDB instances leaked at exit` warning still appears on headless exits, but it remains non-blocking.
- The repo is now in a state where environment, truck, signage, UI-art, and audio asset production can start in parallel with continued systems work.

## 2026-04-02 - Cargo Families, Client Flavor, And Route Consequence Phase
### What changed
- Added reusable client profiles and cargo profiles to the data module so contracts can carry faction tone and freight identity without hard-coding everything in the main scene.
- Updated contract selection, driving HUD, and summary text to show client tone and cargo family instead of only raw labels.
- Gave cargo families real gameplay meaning by feeding cargo-specific handling, braking, acceleration, speed-cap, and payout adjustments into the shift loop.
- Extended the procedural audio layer so cargo family subtly changes engine/ambient character during driving.
- Kept the temporary no-damage playtest mode in place; the user explicitly asked not to re-enable damage yet.

### What was tested
- `.\scripts\validate-godot-setup.ps1`
- `.\scripts\validate-event-flow.ps1`
- `godot.exe --headless --path . --scene res://scenes/main.tscn --quit-after 1`
- `git diff --check`

### Notes
- The validations passed after the cargo/client feature batch.
- Damage remains disabled on purpose and should stay that way until the user explicitly changes course.
- The next sensible step after this batch is deeper district/client consequence work or route-memory tuning, not another general polish pass.

## 2026-04-01 - Repo Scaffold
### What changed
- Initialized the Godot project workspace.
- Created the project brain docs.
- Defined the milestone ladder and production roadmap.

### What was tested
- Git repository initialized.

### Notes
- No gameplay systems existed yet at the start of this batch.

## 2026-04-01 - Core Prototype Batch 1
### What changed
- Added a working Godot project with a procedural first scene.
- Implemented a drivable Shift Hauler truck prototype.
- Added contract selection for three starter deliveries.
- Added cargo pressure, delivery zones, district mood, reputation, and shift summaries.
- Added a basic failure state when cargo stability hits zero.

### What was tested
- `godot.exe --headless --path . --scene res://scenes/main.tscn --quit-after 1`

### Notes
- The first playable loop now boots cleanly.
- This batch uses primitive procedural placeholders for the world and UI.
- Next work should deepen route logic, district reactions, and event pressure.

## 2026-04-01 - Core Prototype Batch 2
### What changed
- Added route memory tracking by district.
- Repeated districts now influence cargo sensitivity and shift messaging.
- Shift summaries now show route familiarity history.
- Contract selection now surfaces whether a route is first-time, familiar, known, or watched.

### What was tested
- `godot.exe --headless --path . --scene res://scenes/main.tscn --quit-after 1`

### Notes
- The core prototype now has a basic city-memory hook.
- Next batch should introduce explicit road events and district mood changes that are visible during a shift.

## 2026-04-01 - Migration and Capability Inheritance Audit
### What changed
- Audited the archived House Is Listening repository for reusable workflow, tool, hook, and automation patterns.
- Copied the inherited workflow stack into the new repo: Codex config, bootstrap validation, Godot smoke testing, Discord PR notifications, helper scripts, and the repo-local `godot_mcp` addon.
- Created the migration memory file and the project tool capability file for the new repo.
- Updated project documentation to treat the House Is Listening workflow as inherited capability rather than dead history.
- Began renaming script temp paths and repo-local comments away from House Is Listening identifiers.
- Patched `project.godot` to enable the inherited Godot MCP plugin.
- Hardened `scripts/validate-godot-setup.ps1` so it handles the repo path with spaces and uses clean exit-code validation.
- Renamed helper-script temp folders away from House Is Listening identifiers.

### What was tested
- `.\scripts\validate-bootstrap.ps1`
- `.\scripts\validate-dev-capabilities.ps1`
- `.\scripts\validate-godot-setup.ps1`
- `.\scripts\godot-headless.ps1`
- Direct Godot scene boot: `godot.exe --headless --path . --scene res://scenes/main.tscn --quit-after 1`
- Direct Godot editor startup: `godot.exe --editor --headless --path . --quit-after 1`

### Notes
- The Godot editor startup log showed the inherited MCP bridge loading and the server starting successfully.
- The editor log also emitted Unicode parsing warnings to stderr, but the process still exited successfully and the bridge initialized.
- The archive was preserved; nothing was deleted.
- The tool-capability file should now treat the Godot bridge and the local environment audit as verified, not merely copied.

## 2026-04-01 - Route Pressure Event Batch
### What changed
- Added contract-specific timed events for road closure, inspection stop, weather change, and traffic pileup pressure.
- Wired event start/end handling into the shift loop.
- Added truck handling modifiers so events actually change route feel.
- Added event banners to the HUD and event history to the shift summary.
- Added inspector-style reputation and mood consequences when the cargo looks rough during a checkpoint.

### What was tested
- `.\scripts\validate-godot-setup.ps1`
- `godot.exe --headless --path . --scene res://scenes/main.tscn --quit-after 1`

### Notes
- The prototype boots cleanly after the event batch.
- The new event system is verified at compile/scene-boot level; a longer playthrough would be useful to observe the timed events in motion.
- Next work should deepen how events feed district mood, route memory, and cargo-specific reactions.

## 2026-04-01 - Route Consequence Depth
### What changed
- Added cargo-specific reactions to route events so the same event feels different for medpacks, generator cargo, and dry goods.
- Made road closures, weather changes, and traffic pileups influence district mood more explicitly when the cargo type supports it.
- Upgraded inspection outcomes so successful stops can improve reputation instead of only serving as a blocker.

### What was tested
- `godot.exe --headless --path . --scene res://scenes/main.tscn --quit-after 1`
- `.\scripts\validate-godot-setup.ps1`

### Notes
- The prototype still boots cleanly after the consequence pass.
- This moves the city reaction layer closer to the demo requirement because events now create readable reputation and mood swings.

## 2026-04-01 - Deterministic Event Probe
### What changed
- Added `scripts/tests/event_flow_probe.gd` as a deterministic gameplay probe for timed event flow.
- Added `scripts/validate-event-flow.ps1` to run the probe through Godot headlessly.
- Verified that the probe can fast-forward a shift, trigger timed events, and reach the delivery summary path without manual input.

### What was tested
- `.\scripts\validate-event-flow.ps1`

### Notes
- The probe passed and reported the expected traffic and weather events on the orientation contract.
- This is a useful new QA capability for future event logic changes and is worth keeping in the repo brain.

## 2026-04-01 - Demo Readability Polish
### What changed
- Added a visible shift phase banner to the HUD so players can tell whether they are selecting, driving, or reviewing a summary.
- Updated the main loop to keep the phase banner in sync with state transitions.

### What was tested
- `.\scripts\validate-event-flow.ps1`
- `.\scripts\validate-godot-setup.ps1`
- `godot.exe --headless --path . --scene res://scenes/main.tscn --quit-after 1`

### Notes
- This improves first-hour readability and makes the prototype easier to stream and easier to understand quickly.
- The event probe still passes after the UI polish.

## 2026-04-01 - Control Axis Fix
### What changed
- Flipped the truck movement axis so `W` now drives the truck forward as the player expects and `S` drives backward.

### What was tested
- `godot.exe --headless --path . --scene res://scenes/main.tscn --quit-after 1`
- `.\scripts\validate-godot-setup.ps1`
- `.\scripts\validate-event-flow.ps1`

### Notes
- The scene still boots cleanly after the movement-axis fix.
- This should resolve the reversed W/S behavior the playtest surfaced.

## 2026-04-01 - Automation And Research Memory
### What changed
- Audited the automation storage surface and confirmed there is no live Codex automation path exposed from this shell.
- Created `docs/AUTOMATION_RESEARCH_SPEC.md` so the recurring research automation has a durable repo-local definition.
- Created `docs/RESEARCH_LOG.md` and `docs/CAPABILITY_EXPANSION_PLAN.md` to store recurring research findings and capability ideas.
- Used browser-based research on onboarding and HUD readability to inform demo polish.

### What was tested
- Repository inspection for automation storage
- Web-based source inspection of onboarding and HUD guidance

### Notes
- The recurring automation remains a manual Codex-app setup step for now.
- Research findings point toward compact onboarding, readable phase banners, and glanceable HUD state as the next demo-polish priorities.

## 2026-04-01 - HUD Onboarding Help Overlay
### What changed
- Added a compact on-screen help reference to the HUD with the current control legend.
- Added a `toggle_help` input action so the player can hide or restore the help view with `H` or `F1`.
- Made the help view context-sensitive so it is visible during selection and summary, and hidden while driving unless the player toggles it back on.

### What was tested
- `.\scripts\validate-bootstrap.ps1`
- `.\scripts\validate-godot-setup.ps1`
- `.\scripts\validate-event-flow.ps1`

### Notes
- This is a small but useful demo-polish improvement that follows the onboarding/HUD research.
- The help overlay should make the first minute of play easier to understand without turning the prototype into a tutorial wall.

## 2026-04-01 - Skill And Tool Troubleshooting Pass
### What changed
- Verified that Playwright works through the CLI wrapper even though the local `playwright` Node package is not installed.
- Verified `gh` authentication and confirmed GitHub CLI access is active on the machine.
- Reviewed the project-facing skill stack and recorded that Game Studio / Playtest skills are available but only secondary support tools for this Godot project.
- Updated `docs/TOOLS_CAPABILITY.md` so future runs know the difference between verified, active, and non-primary tooling.

### What was tested
- `gh auth status`
- `npx --yes --package @playwright/cli playwright-cli --help`
- `npx --yes --package @playwright/cli playwright-cli open https://www.twitch.tv/ninry_`
- `npx --yes --package @playwright/cli playwright-cli snapshot`
- `npx --yes --package @playwright/cli playwright-cli screenshot`

### Notes
- The only real issue found was the missing local `playwright` Node package, and it is not a blocker because the wrapper path works.
- GitHub CLI is active and authenticated, so GitHub-side work can continue without extra setup.

## 2026-04-01 - Krita Verification
### What changed
- Verified Krita is installed at `C:\Program Files\Krita (x64)\bin\krita.exe`.
- Confirmed Krita reports version `5.3.1 (git 9069dbc)`.
- Promoted Krita from inherited-but-unverified to a verified local asset tool in `docs/TOOLS_CAPABILITY.md`.

### What was tested
- `Get-Command krita`
- `Get-Command krita.exe`
- `C:\Program Files\Krita (x64)\bin\krita.exe` file metadata and version info

### Notes
- Krita is ready to use for image or asset work if the project needs painted UI, mockups, or sprite edits.

## 2026-04-01 - Adjacent Design Tool Verification
### What changed
- Verified Blender is installed at `C:\Program Files\Blender Foundation\Blender 4.5\blender.exe` and reports `Blender 4.5.5 LTS`.
- Verified FFmpeg is installed at `C:\ffmpeg\bin\ffmpeg.exe` and reports version `8.0-essentials_build-www.gyan.dev`.
- Verified Audacity is installed at `C:\Program Files\Audacity\Audacity.exe` and reports version `3.7.5.0`.
- Confirmed GIMP and Inkscape were not found in the standard scan paths.
- Updated `docs/TOOLS_CAPABILITY.md` to reflect the installed asset-design tooling more precisely.

### What was tested
- `Get-Command blender`, `Get-Command ffmpeg`, `Get-Command gimp`, `Get-Command inkscape`, `Get-Command audacity`
- Direct executable path checks for Blender, Audacity, and FFmpeg

### Notes
- The asset stack now has a verified model/editor tool, a verified image tool, a verified audio editor, and a verified media encoder.
- GIMP and Inkscape remain unavailable from the current machine scan and should not be assumed present.

## 2026-04-01 - District Consequence Readability
### What changed
- Added a second district status line to the HUD so the player can see mood, reputation, and visit memory at a glance.
- Added district mood labels in code so city reaction reads as `Cold`, `Uneasy`, `Neutral`, `Warm`, or `Welcoming`.
- Wired the district status line into both selection and driving states.

### What was tested
- `.\scripts\validate-godot-setup.ps1`
- `.\scripts\validate-event-flow.ps1`
- `godot.exe --headless --path . --scene res://scenes/main.tscn --quit-after 1`

### Notes
- This is a strong demo-polish improvement because the player can now read city consequence without opening a menu or reading the summary first.
- The event probe still passes after the HUD change, so timed route pressure remains stable.

## 2026-04-02 - Final Logistics Demo Polish Sweep
### What changed
- Research confirmed the demo needed logistics-specific polish, not horror-style pacing.
- Hid the contract list during driving so the live HUD focuses on route, cargo, district, and event feedback instead of selection clutter.
- Reformatted contract lines to read more like a route advisor card with cargo, district, and reward value.
- Added screen-flash feedback for selection, shift start, route arrival, event triggers, successful delivery, and failure states.
- Added stronger atmospheric setup in the world lighting/fog and a few more landmark blocks and route markers.
- Added truck body/cab sway and camera FOV/spring response so speed and cargo pressure feel more present.
- Added pulsing, rotating delivery-zone beacons so drop-offs read better from a distance.

### What was tested
- `.\scripts\validate-godot-setup.ps1`
- `.\scripts\validate-event-flow.ps1`
- `godot.exe --headless --path . --scene res://scenes/main.tscn --quit-after 1`

### Notes
- This pass materially improves the first minute, the live-driving readability, and the delivery payoff.
- The event probe still passes after the logistics polish sweep, so the core loop remains intact.

## 2026-04-02 - Route Profiles, Delivery Spaces, And Procedural Audio
### What changed
- Split route, cargo, and district definitions into a dedicated data module so future contracts and district flavor are easier to add.
- Added real route tradeoffs for safe, fast, and rough routes so selection now meaningfully affects handling, braking, recovery, and payout.
- Added cargo notes, route notes, and a stronger shift brief so the job wrapper feels like a logistics shift instead of a menu.
- Added a procedural audio director with synthesized engine hum, ambient drone, and cue sounds for selection, shift start, arrivals, events, success, and failure.
- Added visible truck wheels, a cargo bed, headlights, and brake lights to make the vehicle feel heavier and more machine-like.
- Added district-specific loading spaces, bay pads, barriers, and beacon lighting so delivery locations read like actual work sites.
- Tightened the truck camera response and clamped the FOV so the driving feel is more stable and less prototype-like.

### What was tested
- `.\scripts\validate-godot-setup.ps1`
- `.\scripts\validate-event-flow.ps1`
- `godot.exe --headless --path . --scene res://scenes/main.tscn --quit-after 1`
- `git diff --check`

### Notes
- The event probe passed again after the route/district/audio batch.
- The headless run still reports the usual object-leak warning at exit, but the scene boots and the shift probe completes.
- This is a real feature-phase leap, not more open-ended polish.

## 2026-04-02 - Final Demo Readability And Logistics Presentation Sweep
### What changed
- Separated live-driving HUD content from the longer route/cargo brief so the on-road screen reads more like a game UI and less like a debug overlay.
- Kept the detailed route brief, cargo brief, and shift brief available for selection and summary while hiding them from the default driving state.
- Added a depot yard composition so the start of the shift feels like a real logistics base instead of an empty spawn area.
- Added more street lighting, sign frames, cone lines, and container stacks to push the world toward industrial believability.
- Gave the truck visible steering pivots on the front wheels so the vehicle reads more like a machine with steering geometry.
- Kept the demo focused on logistics presentation rather than generic cosmetic polish.

### What was tested
- `.\scripts\validate-godot-setup.ps1`
- `.\scripts\validate-event-flow.ps1`
- `godot.exe --headless --path . --scene res://scenes/main.tscn --quit-after 1`
- `git diff --check`

### Notes
- The event probe still passes after the readability sweep.
- The demo now has a stronger route-advisor style separation between live driving and deeper shift context.
- The next sensible move is feature expansion, not another broad realism pass.

## 2026-04-02 - Spawn Safety And Recovery Fix
### What changed
- Added a dedicated spawn-safe zone and forward exit corridor so the truck has a guaranteed clear launch path from the start of the shift.
- Moved depot dressing outward and converted spawn-near visuals to non-blocking props so the start lot cannot soft-lock the truck.
- Added a spawn validation pass that checks candidate spawn points before finalizing the truck position.
- Added a fallback spawn selection path so an invalid spawn can be recovered automatically.
- Added a temporary development reset key and a debug overlay for the spawn safe zone, exit corridor, and nearby blockers.
- Disabled prototype cargo damage failure for playtesting so the flow can be tested without the truck dying to cargo ruin.

### What was tested
- `.\scripts\validate-godot-setup.ps1`
- `.\scripts\validate-event-flow.ps1`
- `godot.exe --headless --path . --scene res://scenes/main.tscn --quit-after 1`
- `git diff --check`

### Notes
- The event probe still passes after the spawn fix.
- The build still reports the known object-leak warning at exit, but the scene boot and validation checks pass.
