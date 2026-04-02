# Roblox Architecture

## Runtime Root
- `roblox/default.project.json`
- `roblox/src/ReplicatedStorage/Shared/Config`
- `roblox/src/ReplicatedStorage/Shared/Types`
- `roblox/src/ReplicatedStorage/Net`
- `roblox/src/ServerScriptService/Services`
- `roblox/src/StarterPlayer/StarterPlayerScripts/Controllers`
- `roblox/src/StarterGui/HUD`
- `roblox/src/WorkspaceTemplates`

## Server Responsibilities
- `WorldStateService`
  - shared depot hub
  - roads, nodes, boards, spawn pads
- `ProgressionService`
  - leaderstats
  - public progression signals
  - overhead player status
- `ContractService`
  - board state
  - contract acceptance
  - active crew visibility
  - remote orchestration
- `DeliveryService`
  - pickup, handoff, delivery stages
- `EconomyService`
  - payout and schedule resolution
- `RouteService`
  - board offer summaries and objective text
- `AmbientLifeService`
  - world-life and visible parallel activity

## Client Responsibilities
- `HudController`
  - compact status HUD
  - dispatch-board UI
  - active crews and top couriers
- `DispatchController`
  - board requests
  - contract acceptance
  - shift start
- `InteractionController`
  - prompt-driven node interactions
- `VehicleController`
  - reset-to-hub and future vehicle hooks
- `AudioController`
  - placeholder cue layer

## Shared Rules
- Solo-first, multiplayer-safe scaffolding
- Public progression visible from the first playable Roblox version
- Shared depot hub is a real space, not a menu room
- Future co-op and convoy jobs should slot into the existing assignment model
- Monetization hooks remain cosmetic or convenience only
