# Godot To Roblox Mapping

| Godot source | Roblox-native target | Notes |
| --- | --- | --- |
| `main.tscn` + `main.gd` | `WorldStateService`, `ContractService`, client controllers, Studio-authored world | Split the monolith into server/client/shared responsibilities. |
| `logistics_defs.gd` | `roblox/src/ReplicatedStorage/Shared/Config/*.lua` | This is the primary gameplay-data port source. |
| `truck_controller.gd` | `VehicleController.lua` plus future vehicle/chassis work | Preserve feel goals, not 1:1 math. |
| `delivery_zone.gd` | tagged pickup/handoff/delivery nodes with prompts | Node roles are now explicit. |
| `hud.gd` | `HudController.lua` + Roblox ScreenGui | Compact live HUD, richer board/summary views. |
| `logistics_audio.gd` | `AudioController.lua` | Placeholder scaffolding for Roblox-side cue playback. |
| `ambient_actor.gd` | `AmbientLifeService.lua` | Early world-life and visible parallel activity. |
| Godot validation probes | `roblox/tools/validate-roblox-scaffold.ps1` plus future Studio/MCP checks | Active validation is now Roblox-facing. |

## Do Not Port Directly
- Godot scene files
- Godot editor settings
- `.godot` cache
- `godot_mcp` addon runtime
- headless Godot validation scripts as active tools
