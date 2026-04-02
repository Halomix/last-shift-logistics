# Migration From House Is Listening

## 1. What Was Found
The archived `House Is Listening` repository contained a stronger continuity stack than the new project had on its own. The most useful items were:
- a repo-level `AGENTS.md` with explicit continuation rules
- a durable project brain pattern centered on milestone, task, blocker, and build-log files
- a `TOOL_CAPABILITY_REFERENCE.md` that recorded local and external capability state
- GitHub Actions for bootstrap validation, Godot smoke testing, and Discord PR notifications
- repo-local Godot tooling, including a `godot_mcp` addon and validation scripts
- Codex configuration in `.codex/config.toml`
- repository helper scripts for bootstrap, environment validation, and Godot validation
- evidence of a workflow discipline based on small batches, validation, and patch-note style logging

## 2. What Is Being Reused
The following were copied into the new repo and are intended to remain in use:
- `.editorconfig`
- `.gitattributes`
- `CODEOWNERS`
- `.codex/config.toml` as a base configuration pattern
- `.github/workflows/bootstrap-validation.yml`
- `.github/workflows/godot-smoke-test.yml`
- `.github/workflows/discord-pr-notifications.yml`
- `scripts/godot-headless.ps1`
- `scripts/godot-editor.ps1`
- `scripts/validate-bootstrap.ps1`
- `scripts/validate-godot-setup.ps1`
- `scripts/validate-dev-capabilities.ps1`
- `addons/godot_mcp/` as a repo-local Godot editor bridge

## 3. What Is Being Adapted
These items are being preserved in spirit but renamed or rewritten for Last Shift Logistics:
- AGENTS rules now point to the Last Shift Logistics project brain instead of the House archive
- bootstrap validation now checks the new project docs and inherited workflow files
- Godot setup validation now reflects the Last Shift Logistics project identity
- temp paths and log labels in helper scripts are being renamed away from House Is Listening identifiers
- the capability doc now distinguishes active, inherited-but-unverified, and blocked tooling in the new repo context
- the production-plan and decisions docs now treat the inherited workflow stack as part of the new project instead of as a separate archive

## 4. What Is Being Discarded
The House Is Listening game-specific content is not being migrated:
- horror narrative content
- house-specific worldbuilding
- patch-note history that only describes the old game
- old milestone names and hold-state text
- any file references that would confuse the new project if copied verbatim

## 5. What Still Needs Verification
The following items are inherited and useful, but still need active confirmation in this repo:
- the copied Godot MCP addon loading from `project.godot`
- headless Godot boot in the new project path
- editor startup with the inherited `godot_mcp` bridge
- the bootstrap validation script against the new project docs
- the dev capability validation script against the current machine
- Discord PR notification delivery once a real GitHub secret is present

## 6. What Was Archived
No source material from the archived repository was deleted during this migration pass.

The archived repo remains the preservation copy for historical reference and future comparisons.

## 7. What Was Safely Deleted
Nothing was deleted from the archived House Is Listening repository during this pass.

That was intentional. The migration preserved first and deferred deletion until the inherited capability stack is fully verified in the new repo.

## 8. What Naming Was Changed
The following naming changes were made or are being enforced:
- `House Is Listening` project references are being replaced by `Last Shift Logistics` in the new repo
- helper script temp folders are being renamed away from `the_house_is_listening_*`
- migration docs are now explicit about the source project so future runs do not confuse source and target identity
- future docs and logs must use the new project identity except when explicitly referring to the archived source

## 9. Migration Judgment
The most valuable inherited capability is not content. It is the workflow:
- durable repo memory
- automated validation
- Godot bridge support
- GitHub-based reporting
- honest build logs
- milestone-driven execution

That workflow is now part of the new repository state and should be treated as a permanent operational advantage.
