# AGENTS.md

## Operating Rules
- Read `AGENTS.md`, `docs/MIGRATION_FROM_HOUSE_IS_LISTENING.md`, `docs/TOOLS_CAPABILITY.md`, and every file under `docs/` before starting work.
- If present, read `docs/AUTOMATION_RESEARCH_SPEC.md`, `docs/RESEARCH_LOG.md`, and `docs/CAPABILITY_EXPANSION_PLAN.md` before planning work.
- Treat the repo as durable memory; treat chat as temporary.
- Work milestone-first. Do not stop after a single patch if the next batch is clear.
- Default to continued implementation until a true blocker exists.
- Update `docs/BUILD_LOG.md`, `docs/TASK_BOARD.md`, `docs/NEXT_ACTIONS.md`, and `docs/BLOCKERS.md` after each meaningful batch.
- Prefer the highest-leverage playable improvement over cosmetic churn.
- Do not overwrite user changes or unrelated work.
- Use small, reviewable batches with honest validation.

## Project Intent
This repository builds **Last Shift Logistics**, an indie action simulation and strategy game about night delivery driving through a reactive city.

Current strategic direction:
- the active runtime target is now Roblox-native Luau under `roblox/`
- Godot is a legacy reference archive under `legacy/godot/`
- future runs should favor repeatable session loops, readable progression, fair monetization hooks, shared-hub social presence, and multiplayer-safe scaffolding without dropping the core logistics fantasy

The project inherits durable workflow, validation, and automation patterns from the archived **House Is Listening** repository. Future runs must preserve those inherited capabilities, adapt them to this project, and avoid reintroducing House-specific naming except where the migration docs intentionally reference the source project.

The default milestone ladder is:
1. scaffold
2. core prototype
3. vertical slice
4. first playable demo
5. alpha
6. beta
7. release candidate
8. full release

## Execution Rule
When a batch finishes, immediately identify the next batch and begin it unless blocked.

## Validation Rule
Prefer real validation:
- Roblox scaffold validation
- Studio-side read-only MCP checks when available
- Git diff review
- targeted runtime checks

## Continuity Rule
Future agents must continue milestone-driven execution. "One patch and stop" behavior is not acceptable unless there is a real blocker.

## Capability Rule
Future agents must read `docs/TOOLS_CAPABILITY.md` at session start, treat it as the source of truth for tools and integrations, and actively use verified tooling before inventing new workflows. If `roblox_studio` is healthy, use it as a first-class inspection/debug capability before guessing about Studio state.

## Automation Rule
If the Codex Automation for recurring research is not live yet, future agents must keep the automation spec current and treat enabling it in the Codex app as an outstanding capability task.
