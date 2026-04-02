# Roblox Migration Plan

## Objective
Move **Last Shift Logistics** from an active Godot prototype into an active Roblox-native implementation while keeping the Godot runtime as a legacy reference archive.

## Classification
- Keep as shared memory:
  - `AGENTS.md`
  - `PLAN.md`
  - `docs/**`
  - `assets/**`
- Archive as Godot legacy:
  - `legacy/godot/project.godot`
  - `legacy/godot/scenes/**`
  - `legacy/godot/scripts/**`
  - `legacy/godot/tools/**`
  - `legacy/godot/addons/**`
- Active Roblox runtime:
  - `roblox/**`
- Discarded generated artifacts:
  - `.godot/**`
  - `.playwright-cli/**`
  - `_playtest_frames/**`
  - `_review_frames/**`
  - `_review_frames_spawn/**`
  - transient Godot logs

## Phases
1. Archive Godot runtime and remove it from the active repo root.
2. Create Roblox-native source tree and project file.
3. Port shared gameplay data into Luau config modules.
4. Implement first server/client contract loop.
5. Build shared depot hub, public progression, and early social visibility.
6. Continue into real Studio-connected implementation once `roblox_studio` is healthy.

## Acceptance
- Godot is no longer the active runtime target.
- Roblox source lives under `roblox/`.
- Shared config, services, and controllers exist in Luau.
- The first Roblox version is solo-completable but socially legible from the start.
- Repo docs clearly describe the migration and the remaining blockers.
