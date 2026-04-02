# Production Plan

## Phase 1 - Migration Scaffold
Freeze Godot as legacy reference, stand up the Roblox-native repo tree, port shared gameplay data into Luau, and build the first depot-hub contract loop.

## Tooling And Workflow Support
The inherited House Is Listening workflow stack is part of the production plan for this project.

Use the following capability layers to increase development speed and continuity:
- `AGENTS.md` for persistent operating rules
- `docs/MIGRATION_FROM_HOUSE_IS_LISTENING.md` for source-project inheritance tracking
- `docs/TOOLS_CAPABILITY.md` for verified and inherited tool state
- `roblox/tools/validate-roblox-scaffold.ps1` for active runtime scaffold validation
- `.github/workflows/bootstrap-validation.yml` for CI continuity checks
- `.github/workflows/discord-pr-notifications.yml` for PR-status notifications when the webhook secret is present

Tooling rule:
- verify inherited capabilities before assuming they are active
- prefer repo-local validation scripts over ad hoc one-off commands
- keep CI workflows aligned with the current repo brain
- update tool docs whenever a capability moves between active, inherited-but-unverified, blocked, or deprecated
- keep Roblox-side service boundaries clean enough that Studio inspection and later persistence work stay safe
- keep a recurring Codex research automation spec current so future runs can scout useful capabilities and research without losing continuity
- keep route, cargo, district, and monetization definitions modular so future content work stays fast
- use a shared depot hub, public progression, and active crew visibility as baseline Roblox-facing UX
- keep the contract loop solo-completable while leaving clean extension points for co-op, convoy, and company systems

## Phase 2 - Core Roblox Prototype
Prove the main loop in Roblox:
- spawn into a shared depot
- see public progression and active crews
- pick a contract
- start a shift
- clear pickup / handoff / delivery stages
- earn credits and visible rank progress

## Phase 3 - Roblox Vertical Slice
Add real district kits, actual vehicle/chassis work, stronger cargo behavior, public leaderboards, and the first save-backed company progression.

The slice should now build on:
- data-driven route profiles and cargo notes
- procedural logistics audio cues
- district-specific delivery-space dressing
- stronger shift wrappers and route tradeoff communication
- cargo-family and client-profile hooks
- route-memory consequences that are visible in the city and summary flow
- a larger district/hub graybox with staged logistics jobs and schedule pressure

## Phase 4 - First Playable Roblox Demo
Polish the shared hub, district graybox, contract readability, and the first social-stickiness layer so the game feels like a place worth returning to.

## Asset Production Entry
Asset work should now target the Roblox-native runtime and replace the placeholder shared hub, district blocks, public boards, and future vehicle shells.

Asset-production order:
1. truck exterior kit
2. district environment kits
3. delivery-space and hub kits
4. signage and wayfinding kit
5. UI-art and audio replacement pass

## Roblox-Native Rule
The active executable target is now Roblox-based, and the product design should bias toward Roblox-suitable strengths:
- sticky repeatable jobs
- short readable sessions with reasons to continue
- rotating contract variation
- visible company growth and district mastery
- fair monetization hooks based on cosmetics, branding, and convenience
- immediate light social value through shared hubs and public progression
- future co-op, convoy, and company extensions

## Phase 5 - Alpha
Expand district content, cargo families, faction interactions, route memory, persistence, and social-company systems.

## Phase 6 - Beta
Balance, optimize, improve UI clarity, and harden the experience.

## Research And Capability Expansion
Maintain a recurring research loop for:
- onboarding and HUD clarity
- gameplay QA and regression prevention
- capability scouting that materially improves development speed or game quality
- browser-based inspection of docs, comparable games, and relevant tool workflows when useful

## Build Order
1. Roblox repo scaffold and migration docs
2. Shared gameplay config modules
3. World bootstrap and shared depot hub
4. Contract board and assignment flow
5. Public progression and leaderstats
6. Pickup / handoff / delivery stage logic
7. Shared-world visibility and ambient activity
8. Vehicle/chassis implementation
9. Persistence and company progression
10. District art kits and audio replacement
