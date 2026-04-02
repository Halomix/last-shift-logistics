# AGENTS.md

## Operating Rules
- Read `AGENTS.md` and every file under `docs/` before starting work.
- Treat the repo as durable memory; treat chat as temporary.
- Work milestone-first. Do not stop after a single patch if the next batch is clear.
- Default to continued implementation until a true blocker exists.
- Update `docs/BUILD_LOG.md`, `docs/TASK_BOARD.md`, `docs/NEXT_ACTIONS.md`, and `docs/BLOCKERS.md` after each meaningful batch.
- Prefer the highest-leverage playable improvement over cosmetic churn.
- Do not overwrite user changes or unrelated work.
- Use small, reviewable batches with honest validation.

## Project Intent
This repository builds **Last Shift Logistics**, an indie action simulation and strategy game about night delivery driving through a reactive city.

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
- Godot scene boot
- script parse checks
- Git diff review
- targeted runtime checks

## Continuity Rule
Future agents must continue milestone-driven execution. "One patch and stop" behavior is not acceptable unless there is a real blocker.

