# Tools Capability

## 1. Purpose
This file is the durable source of truth for project tooling, MCPs, validation workflows, automation, and external capabilities.

Future runs must read this file at session start and use it to answer:
- what runtime is active
- what tools are genuinely usable
- what is legacy-only
- what is blocked
- what should be used first

## 2. Capability Summary
The project is now **Roblox-first**.

Active strengths:
- durable repo brain and migration memory
- Roblox-native Luau scaffold under `roblox/`
- active Roblox scaffold validator
- shared depot / public progression / social-safe runtime scaffolding
- Playwright research capability
- GitHub + GitHub CLI workflow support
- local asset tools: Blender, Krita, FFmpeg, Audacity
- Roblox Studio installed locally

Legacy strengths still worth preserving:
- the full Godot prototype under `legacy/godot/`
- old Godot validation and probes as design/reference history
- inherited workflow and CI patterns from House Is Listening

Biggest gaps:
- `roblox_studio` MCP is configured but not healthy in this session
- no chosen Roblox repo-sync pipeline yet (`rojo` missing)
- no persistence/DataStore layer yet
- no real Roblox vehicle/chassis implementation yet

## 3. Capability Inventory

| Name | Category | Status | Evidence | What It Does | How It Helps | When To Use | Notes / Risks |
|---|---|---|---|---|---|---|---|
| `AGENTS.md` | Operating rules | ACTIVE | Present and Roblox-updated | Defines session rules and continuity expectations | Prevents drift and one-patch-stop behavior | At every session start | Must stay aligned with current runtime target |
| `docs/**` project brain | Repo memory | ACTIVE | Present and updated | Holds game vision, production plan, decisions, blockers, next actions, migration state | Keeps work durable across sessions | Before planning and after each meaningful batch | Treat repo memory as source of truth |
| `legacy/godot/**` | Legacy runtime archive | LEGACY REFERENCE | Archived from active root | Preserves Godot prototype scenes, scripts, tools, and addon history | Supplies design/runtime reference during Roblox porting | When mapping old behavior or extracting design intent | Do not treat as active runtime |
| `roblox/default.project.json` | Roblox project scaffold | ACTIVE | Present in repo | Defines the active Roblox source tree layout | Makes Roblox the canonical runtime structure | Always for active implementation | Rojo-ready structure, even without Rojo installed |
| `roblox/src/ReplicatedStorage/Shared/Config/*.lua` | Shared gameplay data | ACTIVE | Present in repo | Districts, routes, cargo, clients, contracts, economy, progression, world blueprints | Keeps gameplay data modular and portable across services/UI | For all content/system expansion | Primary successor to old `logistics_defs.gd` |
| `roblox/src/ServerScriptService/Services/*.lua` | Server gameplay services | ACTIVE | Present in repo | Owns world state, contracts, delivery flow, progression, economy, ambient life | Forms the authoritative Roblox loop | For all active gameplay implementation | Still scaffold-first; needs Studio verification |
| `roblox/src/StarterPlayer/StarterPlayerScripts/Controllers/*.lua` | Client controllers | ACTIVE | Present in repo | HUD, dispatch, interaction, vehicle placeholder, audio placeholder | Makes the first playable Roblox loop readable and social-aware | For active client-side implementation | Vehicle and audio are still lightweight |
| `roblox/src/WorkspaceTemplates/HubLayout.lua` | World authoring reference | ACTIVE | Present in repo | Encodes shared hub intent and layout conventions | Helps Studio graybox replacement stay aligned | During Studio world authoring | Use as template guidance, not final art |
| `roblox/tools/validate-roblox-scaffold.ps1` | Validation script | ACTIVE | Passes locally | Verifies the active Roblox scaffold, key files, and migration structure | Fast confidence check after Roblox-side changes | After meaningful Roblox batches | Current primary runtime validator |
| `MIGRATION_PLAN.md` | Migration plan | ACTIVE | Present in repo | Defines migration phases and acceptance checks | Keeps the port structured | At session start during migration | Update when migration scope changes |
| `GODOT_TO_ROBLOX_MAPPING.md` | Mapping memory | ACTIVE | Present in repo | Maps Godot systems to Roblox-native equivalents | Prevents blind porting | When translating legacy behavior | Keep focused on systems, not line-by-line code |
| `ROBLOX_ARCHITECTURE.md` | Architecture spec | ACTIVE | Present in repo | Describes source tree, services, remotes, replication boundaries, and tags | Anchors Roblox-native implementation decisions | Before adding services/controllers | Keep authoritative as architecture evolves |
| `LEGACY_GODOT_ARCHIVE_PLAN.md` | Archive policy | ACTIVE | Present in repo | Explains what was archived, kept, or discarded | Prevents accidental loss of reference value | When touching legacy files | Preserve Godot history as reference |
| `docs/AUTOMATION_RESEARCH_SPEC.md` | Automation spec | ACTIVE | Present in repo | Stores the intended recurring Codex research automation | Prevents automation setup from being forgotten | When recreating or updating automation | Manual app-side step still required |
| `roblox_studio` MCP entry | Codex MCP config | REGISTERED BUT NOT LIVE | Registered in `C:\Users\chizz\.codex\config.toml` | Intended live Roblox Studio inspection/debug bridge | Unlocks Studio-aware inspection and safe iteration | After fresh Codex restart with Studio open | Not usable in this session yet |
| `StudioMCP.exe` | Local Roblox MCP binary | VERIFIED INSTALLED | Present beside Roblox Studio, responds to `--help`, `--version`, `--stdio` | Built-in Studio MCP server | Simplest supported Roblox MCP bootstrap path | For future MCP-backed Studio work | Handshake still unconfirmed |
| Roblox Studio | Local engine/tool | VERIFIED INSTALLED | Installed locally and launchable | Native Roblox authoring/runtime environment | Required for real world grayboxing and live testing | During Studio validation and authoring | MCP still needs healthy connection |
| Playwright CLI | Browser research | ACTIVE | Verified via `npx --yes --package @playwright/cli playwright-cli` | Browser automation, screenshots, research inspection | Useful for docs research, UI references, and web workflows | When direct browsing adds value | Prefer direct `npx` path on this machine |
| Git + GitHub CLI | Source control / repo ops | ACTIVE | Available and authenticated | Version control, PR/CI inspection, repo ops | Supports disciplined iteration and publishing | Always for repo work | Use non-destructive git flows |
| `.github/workflows/*.yml` | CI / automation | PARTIALLY ACTIVE | Present in repo | Bootstrap validation and PR notification workflows | Useful repo hygiene and notification layer | When CI/publishing matters | Some workflows still reflect legacy/runtime transitions and secrets |
| Blender | Local asset tool | VERIFIED INSTALLED | Installed locally | 3D modeling and cleanup | Future truck/environment asset production | When creating 3D assets | Not yet wired into a repo pipeline |
| Krita | Local asset tool | VERIFIED INSTALLED | Installed locally | 2D painting and UI/mockup work | Future UI art / signage / texture work | When creating 2D art | Not yet wired into a repo pipeline |
| FFmpeg | Local media tool | VERIFIED INSTALLED | Installed locally | Capture conversion and media processing | Useful for clips, review, and trailer support later | When working with recordings/media | Explicit path may still be safest |
| Audacity | Local audio tool | VERIFIED INSTALLED | Installed locally | Audio editing and cleanup | Useful once placeholder Roblox audio gets replaced | When preparing sound assets | Not yet wired into a repo pipeline |
| Godot validation scripts and probes | Legacy validation | LEGACY REFERENCE | Archived in `legacy/godot/tools` and `legacy/godot/scripts/tests` | Old deterministic checks for the legacy prototype | Useful reference for behavior parity | Only when referencing old prototype behavior | Do not treat as active runtime validation |

## 4. MCP And External Resource Map

| Resource | Connects To | Status | Intended Use | Remaining Setup |
|---|---|---|---|---|
| `roblox_studio` | Roblox Studio via built-in `StudioMCP.exe` | REGISTERED BUT BLOCKED | Live Studio inspection, safe debugging, future in-Studio verification | Fresh Codex run, Studio open, confirm handshake |
| Playwright CLI | Local browser automation | ACTIVE | Research, docs lookup, visual inspection, screenshots | None beyond direct `npx` invocation |
| GitHub CLI / workflows | GitHub remote + CI | ACTIVE / PARTIAL | Repo ops, CI visibility, PR notifications | Discord workflow still needs secret confirmation |
| Codex research automation spec | Codex app automation system | SPEC READY / NOT LIVE | Recurring research and capability scouting | Manual Codex-app enablement |
| Legacy Godot MCP addon | Archived Godot editor bridge | LEGACY REFERENCE | Historical/reference only | No active use planned unless explicitly needed for reference |

## 5. Project Work Already Enabled By These Tools
- Godot is no longer the active runtime; the repo now has a real Roblox-native source tree.
- The active Roblox scaffold already supports:
  - shared depot spawning
  - dispatch-board contract flow
  - pickup / handoff / final-delivery stage logic
  - visible leaderstats and player billboards
  - public crew board, leaderboard board, and showcase pads
  - ambient worker / courier presence hooks
- The migration docs and repo brain now describe the Roblox-native architecture directly instead of treating Roblox as hypothetical.
- The validator can already confirm that the active Roblox scaffold is intact after changes.
- Playwright is already proven usable for research, which means Roblox reference research can keep informing implementation without waiting for a separate setup pass.

## 6. Recommended Tool Usage Policy
- Read `AGENTS.md`, this file, and the migration/architecture docs first.
- Treat `roblox/` as the active runtime and `legacy/godot/` as read-only reference.
- Run `roblox/tools/validate-roblox-scaffold.ps1` after meaningful Roblox batches.
- Use Playwright for bounded research when direct browsing improves decisions.
- Use `roblox_studio` only after a fresh run confirms it is healthy.
- Keep Roblox gameplay data in shared config modules, not scattered through monolithic scripts.
- Keep world authoring Studio-friendly: geometry in Studio, logic/data in Luau modules.
- Preserve social-safe scaffolding from the start:
  - shared depot
  - public progression
  - visible active crews
  - future shared-job hooks

## 7. Gaps / Repairs / Next Tool Actions
- Verify `roblox_studio` in a fresh Codex run with Studio open.
- Decide whether to adopt `rojo` or another repo-sync workflow for Roblox.
- Add a live Roblox smoke-check path once Studio-side validation is healthy.
- Build persistence/DataStore scaffolding after the first playable Roblox slice is verified.
- Keep the automation spec current until the recurring Codex automation is live.

## 8. Future Agent Instructions
- Start every session by reading this file and the migration docs.
- Do not treat legacy Godot files as the active runtime.
- Do not assume `roblox_studio` is healthy until it is verified in that session.
- Prefer verified repo-local validation over guesswork.
- Keep docs honest: separate active, legacy, blocked, and planned capabilities clearly.
