# Legacy Godot Archive Plan

## Purpose
Keep the Godot implementation as a read-only prototype reference while preventing it from acting like the active runtime.

## Archived Paths
- `legacy/godot/project.godot`
- `legacy/godot/scenes/**`
- `legacy/godot/scripts/**`
- `legacy/godot/tools/**`
- `legacy/godot/addons/**`

## Archive Rules
- Do not delete the archive unless a separate explicit archive/export exists.
- Do not patch the archive for new features.
- Use it only for:
  - design reference
  - tuning reference
  - data extraction
  - behavior comparison

## Removed From Active Root
- root `project.godot`
- root Godot scene/script runtime
- generated Godot/editor/playtest artifacts

## Current Active Runtime
- Roblox-native Luau code under `roblox/`
