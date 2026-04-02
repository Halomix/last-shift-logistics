# Roblox Transition Readiness

## Verdict
`ROBLOX RUNTIME MIGRATION IN PROGRESS`

## What This Means
The project is no longer just planning the transition.
It now has:
- a Roblox-native source tree under `roblox/`
- first-pass Luau config modules
- first-pass server services and client controllers
- a shared depot hub, crew board, showcase pads, and public progression scaffold in code
- a baseline company-truck runtime with prompt entry, reset-to-bay, and cargo/route-aware handling hooks
- the Godot runtime archived under `legacy/godot`

## What Is Ready
- contract and district structure
- route-risk and cargo logic
- a baseline Roblox truck runtime architecture
- session-to-session progression goals at a design level
- fair monetization direction at a design level
- world kits and delivery-space categories for art planning
- visible shared-hub social signaling from the first Roblox scaffold

## What Is Not Ready Yet
- persistent Roblox data model
- first full pickup / handoff / delivery completion in the live place
- live-tuned vehicle feel based on a real Roblox drive
- a chosen repo-sync/build pipeline such as `rojo`
- a stable long-lived Roblox Studio MCP session

## Recommended Transition Planning Topics
1. Persistence model
   - credits
   - district mastery
   - streak replacement or daily-chain logic
   - unlock tracking
2. Social layer
   - parallel crews
   - co-op contracts
   - company identity
   - visible hub presence
3. Fair monetization
   - vehicle skins
   - company branding
   - planner UI upgrades
   - convenience-only passes
4. Roblox UX mapping
   - onboarding
   - contract board presentation
   - input simplification
   - mobile readability
5. Tooling pipeline
   - decide whether to standardize on `rojo`
   - verify whether `StudioMCP.exe` is usable
   - define source-of-truth folder structure for Roblox content

## Roblox MCP Bootstrap Status
- `Configured in Codex`: Yes
- `Configured server name`: `roblox_studio`
- `Configured command`: `cmd.exe /c %LOCALAPPDATA%\Roblox\mcp.bat --stdio`
- `Current-session visibility`: Confirmed; the bridge supports live place inspection, script reads, script edits, play mode, and console checks
- `Studio-side connection`: Confirmed in the blank logistics place now being used as the live project foundation
- `Current live limitation`: the vehicle baseline works, but the first full route-node / delivery proof is still pending

## Exact Remaining Human Step
1. Keep the MCP toggle enabled in Studio settings.
2. If the session drops again, reopen Studio and re-select the active instance before continuing live playtests.
3. No extra place-alignment step is needed now; the active blank place is the project place.

## Manual Studio-Side Requirements
- Separate plugin install: not currently indicated.
  - The strongest upstream signal says the primary MCP path is the built-in server that ships directly with Roblox Studio.
  - No separate plugin was found in `C:\Users\chizz\AppData\Local\Roblox\Plugins`.
- Studio-side HTTP/security toggle: not currently indicated by the verified binary path.
  - No manual HTTP-enablement step was discovered during this bootstrap.
  - If the first post-restart connection fails, the next check should be whether Studio exposes a built-in MCP/Assistant toggle in its UI.

## Honest Read
The migration is now real both on disk and in the live blank-place Studio world.
The right immediate capability step is completing the first full contract route in Studio and then tuning feel and progression around that proven loop.
