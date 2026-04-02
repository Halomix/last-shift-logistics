# Automation Research Spec

## Purpose
This document is the durable specification for the recurring Codex Automation that should keep researching useful development improvements and capability expansions for Last Shift Logistics.

If the live automation cannot be created from the current shell, this file is the source of truth for manual creation later.

## Automation Title
Game Dev Research and Capability Expansion

## Cadence
Every 2 hours

## Project Target
Repository: `C:\CodexSandbox\Job app`

Target focus:
- Last Shift Logistics
- the current project brain
- recurring research and capability scouting

## Environment Expectation
The automation should run in the same Codex execution environment that has access to:
- the project repo
- repo brain files
- browser/research capabilities when available
- the ability to update durable markdown files in the repo

If the automation runs in a different environment, it must still write its findings back into the repo brain.

## Exact Automation Prompt
Recurring development research for this game project.

Read the project brain first:

* AGENTS.md
* docs/GAME_VISION.md
* docs/PRODUCTION_PLAN.md
* docs/MILESTONES.md
* docs/TASK_BOARD.md
* docs/DECISIONS.md
* docs/BUILD_LOG.md
* docs/BLOCKERS.md
* docs/NEXT_ACTIONS.md
* docs/TOOLS_CAPABILITY.md
* docs/RESEARCH_LOG.md
* docs/CAPABILITY_EXPANSION_PLAN.md
* docs/MIGRATION_FROM_HOUSE_IS_LISTENING.md if present

Then:

1. identify the current milestone,
2. choose one bounded high-value research topic that helps current or near-future development,
3. choose a 30-minute or 60-minute research budget based on topic value,
4. perform practical research only,
5. use Playwright or browser automation whenever direct website navigation, documentation inspection, storefront comparison, or visual/source review would produce better findings than text-only research,
6. extract actionable findings,
7. classify them as APPLY NOW / SCHEDULE SOON / WATCH FOR LATER / NICE TO HAVE / NOT WORTH IT / BLOCKED BY EXTERNAL NEED,
8. update docs/RESEARCH_LOG.md,
9. update docs/CAPABILITY_EXPANSION_PLAN.md,
10. update other project-brain files if the findings materially change execution,
11. avoid duplicate or low-value research,
12. keep findings useful for an actively developed commercial game.

Focus on research that improves:

* implementation quality
* tool/capability leverage
* milestone readiness
* UX
* performance
* pipeline efficiency
* market competitiveness
* distinctive game quality

Do not drift into vague brainstorming.
Do not replace implementation with theory.
Do not flood the repo with filler.
Be practical, durable, and prioritized.

## Manual Step Required
The recurring automation is not live yet from this shell.

To enable it in the Codex app:
1. create a recurring automation named `Game Dev Research and Capability Expansion`,
2. point it at `C:\CodexSandbox\Job app`,
3. set it to run every 2 hours,
4. paste the automation prompt above,
5. keep it active,
6. ensure it writes its findings back into the repo brain files.

## Recovery Notes
- If the automation is later created successfully, record the creation in `docs/BUILD_LOG.md`.
- If the cadence proves too noisy, reduce it to every 2 hours rather than removing it.
- If the automation becomes live, future sessions should treat this file as the recovery spec and `docs/RESEARCH_LOG.md` / `docs/CAPABILITY_EXPANSION_PLAN.md` as the living outputs.
