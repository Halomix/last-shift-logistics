# Research Log

## 2026-04-02 - Route Advisor And Cargo-Family HUD Follow-Up
### Why This Topic Was Chosen
The next feature-phase batch needed confirmation that the HUD should stay compact in motion while the shift brief, cargo family, and client tone carry more of the job context outside the driving view.

### Time Budget Used
30 minutes

### Methods Used
- Web search for trucking HUD and route-advisor presentation
- Playwright CLI inspection of an official trucking-sim UI article

### Playwright / Browser Automation
Used Playwright browser automation via the CLI wrapper to inspect a route-advisor article and confirm the pattern of keeping live driving HUD elements compact while job context stays in selection/briefing views.

### Sources Reviewed
- SCS Software route-advisor article / trucking-sim UI presentation reference
- Prior logistics demo research already captured in this log

### Key Findings
- Trucking/sim UI works best when live driving feedback stays compact and the heavier job context lives in selection or briefing views.
- Cargo families are a useful way to make freight feel distinct without adding a new system for every cargo type.
- Client/faction tone belongs in the shift wrapper and summary, not as a constant wall of text during driving.
- Route and cargo flavor become more believable when they influence handling, sound, and payout instead of only changing a label.

### What Is Relevant Now
- The current feature batch is moving in the exact direction the research supports: cargo families, client flavor, compact driving HUD, and louder pre-shift context.

### APPLY NOW
- Keep the driving HUD compact.
- Show cargo family and client tone in selection and summary.
- Let cargo type affect handling/audio/payout instead of only text.

### SCHEDULE SOON
- Check whether the updated cargo-family feel is readable in a real playtest.
- Capture a short gameplay clip after the next feature batch to confirm the compact HUD still reads well in motion.

### WATCH FOR LATER
- More elaborate route-advisor mapping or route-planning layers if the demo later needs deeper logistics strategy.

### NICE TO HAVE
- A slightly richer pre-shift briefing card if the contract flow still feels too plain after the current batch.

### NOT WORTH IT
- Bringing back a dense driving HUD just to show more context.

### BLOCKED BY EXTERNAL NEED
- None current.

### What Should Change Because Of This Research
- The game should continue splitting job context between selection/summary and live driving, while using cargo families and client tone to make the shift wrapper feel more like a real logistics job.

## 2026-04-01 - Demo Readability and Event Feedback Research
### Why This Topic Was Chosen
The current milestone is moving from core prototype toward demo polish, so the highest-value research topic was how to make onboarding, HUD, and event feedback clearer in the first minutes of play.

### Time Budget Used
30 minutes

### Methods Used
- Web search for onboarding, HUD, and vehicle-display guidance
- Direct inspection of official and research sources

### Playwright / Browser Automation
Used browser-based web inspection via the web research tool.

### Sources Reviewed
- Apple Developer, “Onboarding for Games”
- Accessible Game Design, “HUD Guidelines”
- arXiv, “An Eye Gaze Heatmap Analysis of Uncertainty Head-Up Display Designs for Conditional Automated Driving”

### Key Findings
- Onboarding should teach the core loop in small steps, with short clear instructions and gameplay-first guidance.
- Players should be able to start playing quickly, skip introductory friction when appropriate, and revisit help/tutorial content later.
- HUD elements for important state should be glanceable, high-contrast, and readable at a speed appropriate to the game.
- Secondary stats work better when they combine concise visuals with audio/diegetic feedback instead of forcing constant reading.
- Timed or uncertain state changes are more effective when they interrupt attention at the right moment rather than relying only on a peripheral UI element.

### What Is Relevant Now
- Phase banners, event banners, and concise objective text are the right demo-polish direction.
- The prototype should keep onboarding contextual and short instead of adding long tutorial text.
- The HUD should prioritize readable state changes over dense information.

### APPLY NOW
- Keep the shift phase banner.
- Keep the event banner and concise objective copy.
- Keep route, cargo, and district state readable at a glance.
- Prefer brief contextual instructions over long tutorial blocks.

### SCHEDULE SOON
- Add a small in-game help/reference view for controls and core loop reminders.
- Consider screenshot-based UI review before the demo polish pass is complete.
- Use a short event playtest checklist to confirm state changes read clearly in motion.

### WATCH FOR LATER
- Adaptive HUD sizing or configurability.
- More advanced attention management systems for route uncertainty.
- Telemetry-driven onboarding refinement once there is enough player data.

### NICE TO HAVE
- Lightweight tutorial replay access from the pause or settings flow.
- Optional high-contrast UI mode.

### NOT WORTH IT
- Heavy multi-step onboarding gates before first play.
- Complex adaptive HUD systems before the base HUD is proven readable.
- Overly elaborate uncertainty visualization that competes with the driving view.

### BLOCKED BY EXTERNAL NEED
- Any real retention-analysis loop depends on analytics/telemetry that this prototype does not yet have.

### What Should Change Because Of This Research
- Demo polish should continue focusing on compact, contextual guidance and readable state banners.
- The next UX pass should prioritize first-minute clarity rather than adding more systems.

## 2026-04-01 - HUD Onboarding Follow-Through
### Why This Topic Was Chosen
The earlier research pointed to a small, contextual help surface as the most practical next demo-polish improvement, so this follow-through pass checked whether the prototype should add one now.

### Time Budget Used
30 minutes

### Methods Used
- Web search and direct reading of HUD/readability guidance
- Repo inspection of the existing HUD and main-loop flow

### Playwright / Browser Automation
Used browser-based research via the web tool.

### Sources Reviewed
- Microsoft Game Dev accessibility guidance on readable UI/HUD state
- Prior onboarding and HUD research already captured in this log

### Key Findings
- A compact help reference is worth shipping now because the prototype already has a simple core loop and the demo needs better first-minute readability.
- The help surface should stay contextual, small, and easy to hide so it does not fight the driving view.
- The best pattern for this prototype is a short control legend plus a toggle, not a large tutorial wall.

### What Is Relevant Now
- The prototype benefits from a small, on-screen reference that helps the player remember select/start/drive/deliver controls.
- The help surface should be visible during selection and summary, then get out of the way while driving.

### APPLY NOW
- Keep the compact help overlay in the prototype.
- Keep the control legend short and direct.
- Keep the help surface toggleable so the driving view stays readable.

### SCHEDULE SOON
- Use a short playtest to confirm the help panel does not clutter the active driving view.
- Capture a screenshot or short clip of the HUD for later visual review.

### WATCH FOR LATER
- Adaptive help or onboarding only if repeated playtests show the current help view is still insufficient.

### NICE TO HAVE
- A richer in-game reference menu once more systems are added.

### NOT WORTH IT
- Long tutorial sequences before the player reaches the truck.

### BLOCKED BY EXTERNAL NEED
- Analytics-driven onboarding tuning is still blocked by the lack of telemetry.

### What Should Change Because Of This Research
- The prototype should keep the help overlay and use it as a light onboarding aid, not as a replacement for the core loop.

## 2026-04-02 - Logistics Demo Polish Research
### Why This Topic Was Chosen
The demo polish pass needed to be logistics-specific rather than horror-specific, so the highest-value research topic was what makes truck, delivery, and route-planning games feel polished and readable in motion.

### Time Budget Used
30 minutes

### Methods Used
- Web search for logistics and truck-sim UX/presentation references
- Direct reading of logistics, route-planning, and environmental storytelling sources

### Playwright / Browser Automation
Used browser-based research via the web tool.

### Sources Reviewed
- Euro Truck Simulator 2 analysis PDF noting route planning, environmental realism, soundscapes, weather, and delivery deadlines
- Environmental storytelling chapter describing how world objects and layout suggest story to the player
- Contested Route Planning arXiv paper on route choice under disruption and environment-driven route unpredictability

### Key Findings
- Logistics demos benefit from separating detailed job selection/context from the active driving HUD so the player can focus on the road once the shift begins.
- Environmental storytelling matters in delivery games because landmarks, lane shapes, and signage can communicate place and function without extra text.
- Weather, traffic, and route disruption work best when they support route planning and not just as isolated effects.
- Visual and audio realism are most valuable when they reinforce the player's operational decisions: efficiency, safety, and delivery timing.

### What Is Relevant Now
- Hiding the contract list during driving and keeping only the live route/cargo/district readouts supports a cleaner logistics HUD.
- Delivery zones should read like destinations through motion and beaconing rather than being static trigger spots.
- Truck feel and camera motion should communicate speed, cargo weight, and route pressure.

### APPLY NOW
- Keep detailed contract info off the driving HUD.
- Use pulsing delivery-zone beacons and stronger landmark silhouettes.
- Keep the camera and truck body responsive to speed and steering.
- Use strong but compact state flashes for arrival, events, completion, and failure.

### SCHEDULE SOON
- Capture screenshots or short video clips of the current demo for visual QA once the presentation is stable.
- Consider a small route-advisor style info panel later if the selection screen still feels too dense.

### WATCH FOR LATER
- More advanced route-map, traffic, or cargo visualization layers if the game needs deeper planning later.

### NICE TO HAVE
- Additional environmental signage, district decoration sets, or truck interior polish once the next feature phase starts.

### NOT WORTH IT
- Overcomplicated driving HUD overlays that compete with route readability.

### BLOCKED BY EXTERNAL NEED
- Nothing current; the logistics research is actionable now.

### What Should Change Because Of This Research
- The demo should feel like a compact, operational delivery game: clear job selection, clear in-motion feedback, clear arrival feedback, and a stronger sense of place through landmarks and zone beacons.

## 2026-04-02 - Logistics Route And Delivery-Space Research
### Why This Topic Was Chosen
The next feature-phase batch needed guidance on what makes route tradeoffs, cargo pressure, industrial spaces, and truck audio feel real in a logistics demo.

### Time Budget Used
30 minutes

### Methods Used
- Web search for logistics/truck presentation references
- Browser-based inspection of public trucking-game presentation pages with Playwright CLI

### Playwright / Browser Automation
Used Playwright browser automation via the CLI wrapper to inspect public truck-sim presentation pages and support the research pass.

### Sources Reviewed
- Public trucking-game presentation pages and route-advisor style UI references
- Logistics/world-dressing references from search results and official game pages

### Key Findings
- Route tradeoffs should be visible before the shift and felt during the drive, not just listed in a menu.
- Cargo notes and route notes help the player understand why a shift matters.
- Delivery spaces feel more believable when they include bay pads, barriers, signage, and district-specific industrial clutter.
- Logistics audio should reinforce machine mass and route pressure with engine, ambience, and cue sounds rather than only with music or dialogue.
- Small district identity markers, lighting, and operational props do a lot of world-building work in a demo.

### What Is Relevant Now
- The route and cargo data module, the shift brief, the procedural audio layer, and the delivery-space dressing all map directly to the current feature batch.

### APPLY NOW
- Keep route tradeoffs mechanical and visible.
- Keep cargo notes and route notes in the shift wrapper.
- Keep delivery spaces dressed like work sites instead of empty trigger zones.
- Keep the audio layer informative and lightweight.

### SCHEDULE SOON
- Tune the audio mix and cue timing after a human playtest.
- Add more route memory or cargo specialization once the current routes are balanced.

### WATCH FOR LATER
- More advanced ambient layers or voice work if the demo needs stronger production value later.

### NICE TO HAVE
- Clip capture of the route/audio pass for future review.

### NOT WORTH IT
- A full music system before the core route and cargo feedback is proven.

### BLOCKED BY EXTERNAL NEED
- None current; the route/audio findings were actionable immediately.

### What Should Change Because Of This Research
- The current batch should prioritize real route tradeoffs, physical delivery-space dressing, and procedural audio cues over purely decorative polish.

## 2026-04-02 - Route Advisor HUD Separation And Logistics Presentation
### Why This Topic Was Chosen
The current demo recording still read as prototype-heavy because the driving HUD was carrying too much explanatory text. I needed a reference for how a serious logistics game separates live driving information from deeper job context.

### Time Budget Used
30 minutes

### Methods Used
- Web search for trucking/logistics UI references
- Playwright CLI inspection of an official trucking-sim route-advisor post

### Playwright / Browser Automation
Used Playwright browser automation via the CLI wrapper to inspect the SCS Software route advisor article and confirm how a polished trucking HUD separates live driving feedback from deeper info.

### Sources Reviewed
- SCS Software blog post on the new Route Advisor

### Key Findings
- The strongest pattern is separation: driving HUD should stay compact and immediate, while detailed job information lives elsewhere.
- Delivery and truck-sim UIs work best when they show only driving-critical info in motion and keep more explanatory context in a quick-info or selection layer.
- Notifications should be single-purpose and color-coded by importance instead of stacked into multiple competing text blocks.
- The demo should not try to explain itself with a wall of text while the player is driving.

### What Is Relevant Now
- The HUD restructure should keep route/cargo/district brief text available in selection and summary, but not continuously on the live driving screen.
- The current pass should favor compact readability, route-advisor style separation, and strong delivery feedback over more text.

### APPLY NOW
- Keep the live driving HUD compact.
- Keep route and cargo briefing available before and after the shift, not as a constant wall of text during driving.
- Use the driving screen for route state, cargo state, district state, and event feedback.
- Keep summary screens detailed so the player still feels the job context at the end of the run.

### SCHEDULE SOON
- Revisit notification styling after human playtest.
- Consider a more icon/badge-based route HUD in a later feature phase if the current labels still feel too textual.

### WATCH FOR LATER
- More advanced widget-style HUD composition if future content needs additional live driving data.

### NICE TO HAVE
- Capture a fresh demo recording after the HUD separation lands to verify the screen reads more like a game and less like a debug overlay.

### NOT WORTH IT
- Reintroducing multiple long-form text panels into the live driving view.

### BLOCKED BY EXTERNAL NEED
- None current; the research directly informed code changes.

### What Should Change Because Of This Research
- The demo should preserve information richness but move that richness into the right place: compact live HUD for driving, deeper context in shift brief and summary.

## 2026-04-02 - Roblox Discovery, Retention, And Transition Readiness
### Why This Topic Was Chosen
The project direction is now Roblox-facing, so the sprint needed real guidance on what Roblox discovery and return-value reward, plus a concrete local capability check for whether transition planning can begin now.

### Time Budget Used
30 minutes

### Methods Used
- Playwright CLI inspection of Roblox Creator Hub discovery docs
- web search for official Roblox Creator Hub surfaces related to discovery and monetization
- local capability audit for Roblox Studio / transition tooling

### Playwright / Browser Automation
Used Playwright CLI directly with `npx --yes --package @playwright/cli playwright-cli` to inspect the Roblox Creator Hub discovery docs and verify the kinds of metrics and loops Roblox emphasizes.

### Sources Reviewed
- [Roblox Creator Hub - Discovery](https://create.roblox.com/docs/discovery)
- Roblox Creator Hub references surfaced from discovery around events, notifications, passes, and subscriptions
- local machine check for `RobloxStudioBeta.exe`, `StudioMCP.exe`, and `rojo`

### Key Findings
- Roblox discovery favors experiences that improve engagement, repeat play, monetization quality, and intentional co-play.
- Event surfaces, groups, notifications, and repeat session behavior matter for return-value.
- A fair monetization direction for this project is cosmetics, company branding, and convenience tools, not power or core-loop gating.
- Roblox Studio is installed locally, which is enough to begin grounded transition planning.
- `rojo` is not installed, so actual repo-sync conversion work should wait until the pipeline choice is explicit.

### What Is Relevant Now
- The project should keep emphasizing repeatable contracts, rotating job boards, visible mastery, and reasons to keep taking one more shift.
- Transition planning can begin now because the gameplay/world reference is strong enough and the machine already has Roblox Studio.

### APPLY NOW
- Add rotating offer-board pressure and featured-district incentives.
- Add more visible company progression signals such as streaks and mastery.
- Keep monetization planning cosmetic/convenience based.
- Document Roblox transition readiness without pretending the conversion pipeline is already set up.

### SCHEDULE SOON
- Plan save/meta progression and social/company loops for the Roblox version.
- Decide whether `rojo` or another Roblox content pipeline should be the repo standard before conversion work starts.

### WATCH FOR LATER
- Creator-events, notifications, and deeper social loops once the core Roblox plan is locked.

### NICE TO HAVE
- A later research pass on Roblox-specific onboarding UX and session-length tuning once the persistence plan exists.

### NOT WORTH IT
- Starting direct Roblox conversion before the persistence/data model and pipeline are chosen.

### BLOCKED BY EXTERNAL NEED
- No hard blocker for planning; direct implementation is blocked by the missing repo-level Roblox pipeline choice.

### What Should Change Because Of This Research
- The Godot prototype should now act as a reference vertical slice for asset production and Roblox transition planning, with retention loops that already resemble a viable Roblox game shape.
