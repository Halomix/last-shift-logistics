# Vehicle Implementation Notes

## Current Baseline
The first Roblox-native truck layer lives in:
- `roblox/src/ReplicatedStorage/Shared/Config/VehicleConfig.lua`
- `roblox/src/ServerScriptService/Services/VehicleService.lua`
- `roblox/src/StarterPlayer/StarterPlayerScripts/Controllers/VehicleController.lua`

## Current Design
- one company truck per player
- assigned to depot truck bays
- prompt-based entry
- `F` exit on client
- `R` reset through the existing reset flow
- route/cargo-aware handling modifiers
- public owner/fleet billboard on the truck
- headlights and brake-light feedback

## Why This Shape Was Chosen
- safe first production step without depending on Studio-side authoring
- easy to extend with progression tiers
- easy to extend with cargo and route effects
- solo-first while still multiplayer-safe
- fits the existing shared depot and public progression loop

## Current Limitations
- not yet tuned from a real live Roblox drive
- currently uses a controlled anchored-movement baseline, not a full physical chassis
- needs live validation for seating feel, turning radius, and collision feel
- needs later upgrade hooks for true vehicle classes, cosmetics, and district traversal specializations

## Next Vehicle Questions
1. Does the baseline truck feel readable and satisfying in a real Studio playtest?
2. Should the next iteration stay controlled/arcade or move toward a more physical chassis?
3. Which upgrade axis matters most first:
   - speed
   - brake control
   - cargo stability
   - turning
   - district traversal bonuses
