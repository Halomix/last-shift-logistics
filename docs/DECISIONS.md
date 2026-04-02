# Decisions

## Engine
- Roblox-native Luau is now the active runtime target.
- Godot 4.6.1 is no longer the active runtime target; it is preserved under `legacy/godot` as a design and implementation reference only.
- The project remains 3D first and built around a truck-driving delivery fantasy, but the live product direction is now Roblox-first.

## Platform
- Roblox platform first.
- The first Roblox-native version must be solo-completable while visibly supporting shared-world presence.
- Future gameplay, progression, and UX choices should favor sticky repeatable sessions, readable return-value, public progression, and fair monetization hooks.

## Scope
- Solo-first with multiplayer-safe scaffolding.
- Immediate light social value is required in the first Roblox-native implementation:
  - shared central hub
  - visible active crews
  - public progression signals
  - lightweight leaderboard metrics
- Deep co-op is deferred, but the contract system must stay future-ready for shared jobs and convoy work.

## Production Style
- Build small, verifiable batches.
- Favor systems that change play over systems that only add content.
- Procedural primitive level pieces are acceptable for the scaffold and first playable prototype.
- Reuse proven workflow and validation patterns from House Is Listening instead of recreating them from scratch.
- Preserve archival history instead of deleting source capability before it is documented and verified.

## UI Style
- Logistics software tone.
- Readable during motion.
- Dispatch, cargo, route, and district information should be compact and obvious.

## Art Style
- Wet urban night scenes.
- Distinct district identity.
- Primitive placeholder art is acceptable until systems prove themselves.

## Prototype Scene Structure
- Main scene is built procedurally in script for speed during the scaffold/core prototype phase.

## Audio Style
- Engine, cargo, radio, weather, and dispatch audio are core feel elements.

## Tooling And Workflow
- `.github/workflows/bootstrap-validation.yml` is the canonical repo continuity check.
- `.github/workflows/godot-smoke-test.yml` is the canonical headless scene boot check.
- `.github/workflows/discord-pr-notifications.yml` remains the canonical PR notification workflow if `DISCORD_WEBHOOK_URL` exists in GitHub secrets.
- `roblox/tools/validate-roblox-scaffold.ps1` is the active runtime scaffold check.
- Nothing from the archived House Is Listening repo was deleted in the migration pass; the archive remains the preservation source.
- The Godot MCP bridge is legacy-only now because Godot is archived.
- The local environment currently verifies Git, GitHub CLI, Godot 4.6.1, Node, npm, Python, Playwright, Blender, and Krita.
- Discord PR notifications are still externally dependent on `DISCORD_WEBHOOK_URL` and remain partially configured until GitHub secrets are confirmed.
- `scripts/validate-event-flow.ps1` and `scripts/tests/event_flow_probe.gd` are the preferred repeatable check for timed route-event behavior.
- The recurring research automation is required conceptually, but it must be enabled manually in the Codex app because this shell cannot create it directly.
- Browser-based research should be used for onboarding, HUD, and comparable-game inspection when it materially informs demo polish.
- The prototype now uses a compact, toggleable help overlay that is visible during selection and summary but hidden during driving by default.
- Playwright is considered verified through the `npx --package @playwright/cli playwright-cli` wrapper; the local Node package is absent but not required.
- The GitHub CLI is verified and authenticated, so GitHub-side checks and PR workflows can rely on it.
- Game Studio / Playtest skills remain support tools, not the primary implementation path, because this project is a Godot build rather than a browser-game stack.
- Krita is verified at `C:\Program Files\Krita (x64)\bin\krita.exe` and can be used for future art, UI mockup, or asset-editing tasks.
- Blender is verified at `C:\Program Files\Blender Foundation\Blender 4.5\blender.exe` and is the main 3D asset authoring tool available here.
- FFmpeg is verified at `C:\ffmpeg\bin\ffmpeg.exe` and is available for capture/transcode workflows.
- Audacity is verified at `C:\Program Files\Audacity\Audacity.exe` and is available for audio cleanup and editing.
- GIMP and Inkscape were not found in the standard machine scan and should not be assumed available.
- The driving HUD should stay compact: the contract list is selection-only, while route, cargo, district, event, and objective feedback stay visible in motion.
- The route brief and cargo brief should be visible in selection and summary but hidden from the default driving HUD to preserve readability while moving.
- Delivery zones should be visually active through pulsing beacons and stronger signage instead of relying on a flat trigger volume.
- Screen-flash feedback is accepted for selection, event start, arrival, delivery success, and failure because it improves game feel without adding new assets.
- Truck body sway and camera response are part of the demo polish baseline now; future changes should preserve that sense of motion unless a stronger driving model replaces it.
- Route styles now have mechanical meaning: safe, fast, and rough routes use different handling, braking, recovery, and payout profiles.
- Cargo and route notes are part of the shift wrapper because the demo needs stronger logistics-job framing.
- Front-wheel steering pivots are an acceptable lightweight way to make the truck read more like a machine with real vehicle geometry.
- A temporary no-damage playtest mode is acceptable while we fix route, spawn, and early-flow issues, provided it is logged and not forgotten.
- The spawn lot should be protected by a validated safe zone and exit corridor rather than relying on the player to thread a needle through props.
- Procedural synth audio is acceptable for this prototype and should be used as a bridge until a fuller asset pipeline exists.
- District delivery spaces should be dressed with primitive industrial props and lighting rather than left as empty trigger zones.
- The route, cargo, and district definition tables belong in a dedicated data module so future content additions are faster and less centralized.
- Damage stays disabled in the current playtest mode until the user explicitly asks for it to be re-enabled.
- Cargo families now affect handling, audio, and payout even while the damage system stays off, so the next feature phase can deepen freight identity without waiting for failure-state reactivation.
- Client/faction tone belongs in the shift wrapper and summary, not as constant driving clutter.
- The city graybox now includes five delivery districts and support hubs; future art should replace these layouts rather than redesign their broad footprint unless playtests surface a real navigation problem.
- Staged handoff jobs and schedule pressure are now part of the core logistics fantasy and should be preserved as the project moves toward the vertical slice.
- The project is ready to begin asset production for truck, environment kit, signage, delivery-space, UI-art, and audio categories while systems work continues in parallel.
- Multi-stop chain jobs with pickup, handoff, and final delivery are now part of the intended loop and should be preserved.
- Dispatch streak bonuses, rotating offer boards, and featured-district incentives are now part of the replay/retention layer.
- Roblox Studio is installed locally at `C:\Users\chizz\AppData\Local\Roblox\Versions\version-ac9bdbe6aedb4e5e\RobloxStudioBeta.exe`.
- The built-in Roblox Studio MCP binary at `C:\Users\chizz\AppData\Local\Roblox\Versions\version-ac9bdbe6aedb4e5e\StudioMCP.exe` is the preferred bootstrap path over the deprecated open-source reference server.
- `roblox_studio` has been registered into `C:\Users\chizz\.codex\config.toml` as the Codex MCP name for Roblox Studio.
- No local `rojo` executable was found, so direct Roblox repo-sync workflows are not yet available from this machine.
- The first Roblox-native implementation should expose a shared depot hub and public progression from day one, even before deep co-op lands.
- The shared depot now needs three public visibility layers by default:
  - dispatch board
  - crew activity board
  - public progression/showcase pads
- The dispatch board and top-bar HUD should surface route type, cargo family, client badge, next unlock pressure, and public queue state so the first Roblox loop reads clearly without long tutorial text.
- Public progression signals should update live when rank or delivery count changes; they should not wait for character respawn.
- Public progression should also surface current active-shift stage on player and truck billboards when possible so the hub feels observably busy.
- The dispatch board should toggle open and closed on `B` so the hub loop feels cleaner and more game-like.
- The first Roblox truck phase uses an anchored, prompt-entry company-hauler baseline so we can tune logistics feel safely before deciding whether a more physical chassis is worth the complexity.
- Truck handling should already respond to cargo and route profile in the baseline implementation, even before the final vehicle model exists.
- The confirmed blank Studio place is now the intended logistics place and may be edited directly through the MCP as long as the repo remains the source of truth.
- Do not write blind Studio edits into an unrelated place; that rule is now satisfied because the active blank place is the approved project foundation.
- Prefer direct `npx --yes --package @playwright/cli playwright-cli` usage on this machine; the packaged wrapper script currently has line-ending issues under bash.
- Truck-bay visual markers must remain non-blocking; depot readability props cannot obstruct the vehicle baseline.
- The Roblox truck baseline now uses an explicit `UpdateVehicleInput` remote path in addition to the seat/prompt flow, because reliable logistics movement matters more than pretending the initial anchored-seat path is sufficient.
- Overhead depot landmarks such as the dispatch canopy and gate beam should stay non-colliding in the graybox so they support identity without blocking the route out of the hub.
