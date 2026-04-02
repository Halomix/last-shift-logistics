# Capability Expansion Plan

## 1. Recurring Codex Research Automation
- **What it does:** Runs recurring research on the current milestone, useful tools, and capability improvements.
- **Why it matters:** Keeps research durable instead of ad hoc, and prevents capability opportunities from being forgotten.
- **Already exists:** Spec only, not live from this shell.
- **Needs verification:** Yes, once the Codex app automation is created.
- **Needs credentials or external setup:** No external credentials, but it needs manual setup in the Codex app.
- **Helps milestone:** Demo, alpha, beta, and release.
- **Recommendation status:** APPLY / ENABLE SOON
- **Priority:** High

## 2. Screenshot Or Video Capture Workflow
- **What it does:** Captures visual proof of HUD, onboarding, and event readability.
- **Why it matters:** Makes demo QA and iteration much faster.
- **Already exists:** Not yet.
- **Needs verification:** Yes, once added.
- **Needs credentials or external setup:** No.
- **Helps milestone:** Demo and alpha.
- **Recommendation status:** SCHEDULE SOON
- **Priority:** Medium

## 3. Deterministic Event Flow Probe
- **What it does:** Fast-forwards a shift and confirms event timing and summary completion.
- **Why it matters:** Protects the route-pressure system from regressions.
- **Already exists:** Yes, active and verified.
- **Needs verification:** Should be re-run after event changes.
- **Needs credentials or external setup:** No.
- **Helps milestone:** Core prototype, vertical slice, demo.
- **Recommendation status:** APPLY NOW
- **Priority:** High

## 4. Stronger Gameplay Regression Probe Suite
- **What it does:** Adds more scripted checks for route, cargo, and district behavior.
- **Why it matters:** Keeps the prototype stable as systems expand.
- **Already exists:** Partially, via the event probe and the world-expansion probe.
- **Needs verification:** Keep re-running after staged-contract or progression changes.
- **Needs credentials or external setup:** No.
- **Helps milestone:** Demo and alpha.
- **Recommendation status:** APPLY NOW
- **Priority:** Medium

## 5. Discord PR Notification Verification
- **What it does:** Posts PR updates to Discord from GitHub Actions.
- **Why it matters:** Supports external visibility and collaboration.
- **Already exists:** Workflow exists.
- **Needs verification:** Yes, but only with a real GitHub secret.
- **Needs credentials or external setup:** Yes, `DISCORD_WEBHOOK_URL`.
- **Helps milestone:** All milestones that use collaboration workflows.
- **Recommendation status:** BLOCKED BY EXTERNAL NEED
- **Priority:** Low

## 6. Asset / Audio Pipeline Helper
- **What it does:** Assists with imported art, audio, and build-time asset checks.
- **Why it matters:** Could reduce friction once content volume increases.
- **Already exists:** Not yet.
- **Needs verification:** N/A until added.
- **Needs credentials or external setup:** No.
- **Helps milestone:** Vertical slice onward.
- **Recommendation status:** WATCH FOR LATER
- **Priority:** Low

## 7. Procedural Logistics Audio Layer
- **What it does:** Synthesizes engine hum, ambient city drone, and short in-game cue sounds without external assets.
- **Why it matters:** Fills a major production gap in the current demo and makes the truck/shift fantasy feel more alive.
- **Already exists:** Yes, active in the current build.
- **Needs verification:** Should be tuned by human playtest for mix and timing.
- **Needs credentials or external setup:** No.
- **Helps milestone:** Demo and alpha.
- **Recommendation status:** APPLY NOW
- **Priority:** High

## 8. Modular Route / Cargo / District Data
- **What it does:** Keeps contract and district definitions in a dedicated data module instead of hard-coding everything in the main scene script.
- **Why it matters:** Makes future cargo, route, and district expansion faster and less error-prone.
- **Already exists:** Yes, active in the current build.
- **Needs verification:** Should be extended as new content is added.
- **Needs credentials or external setup:** No.
- **Helps milestone:** Demo, alpha, beta.
- **Recommendation status:** APPLY NOW
- **Priority:** High

## 9. Browser-Based Logistics UI Research Loop
- **What it does:** Uses Playwright/browser inspection to study trucking HUD, route-advisor, and delivery-presentation references when the current batch needs a design decision.
- **Why it matters:** Keeps the demo grounded in real logistics presentation patterns instead of generic game UI assumptions.
- **Already exists:** Yes, available and used intermittently.
- **Needs verification:** Should be re-run whenever the HUD, briefing flow, or route presentation changes materially.
- **Needs credentials or external setup:** No.
- **Helps milestone:** Demo and alpha.
- **Recommendation status:** APPLY NOW
- **Priority:** Medium

## 10. Roblox Transition Tooling Baseline
- **What it does:** Verifies whether the machine has the right local tools to begin Roblox transition planning and, later, implementation.
- **Why it matters:** Prevents the project from guessing about Roblox readiness.
- **Already exists:** Partially; Roblox Studio is installed locally, but no repo sync pipeline is set.
- **Needs verification:** Yes, for any Studio-side MCP/bridge tooling and any future sync tool.
- **Needs credentials or external setup:** No credentials yet, but a repo-level pipeline decision is needed.
- **Helps milestone:** Asset production follow-through, Roblox transition planning, alpha.
- **Recommendation status:** SCHEDULE SOON
- **Priority:** Medium
