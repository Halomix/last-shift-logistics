# Final Game Target

## What The Docs Say The Final Game Should Be
**Last Shift Logistics** is a Roblox-native, replayable night-shift logistics game set in Gloam City. The player is a known after-hours courier keeping a damaged, bureaucratic, slightly absurd city alive through contract work, route choices, cargo handling, and district consequence.

The final game is not a generic tycoon and not a pure driving sandbox. It is a social-feeling shared-city logistics game built around:
- a shared central depot
- visible public progression
- repeatable but story-rich contract runs
- route pressure and cargo pressure
- distinct districts with strong identity
- staged pickup / handoff / final-delivery chains
- visible company growth and return value

## Non-Negotiable Identity Pillars
1. **The truck matters**
- Vehicle feel must support freight work, staging, route choice, and city traversal.
- Truck classes, upgrades, and cosmetics matter later, but the baseline hauler must already feel like a working machine.

2. **Route choice matters**
- Routes are not flavor text.
- Safe, fast, and rough lanes must feel mechanically and visually different.
- District pressure, staged jobs, and route-memory consequences should make route choice part of the fantasy.

3. **Cargo matters**
- Cargo families must drive behavior.
- Freight identity affects handling, payout, route suitability, and the tone of the job.

4. **The city matters**
- Gloam City is reactive, district-based, wet, neon, tired, practical, and funny.
- Districts are supposed to feel like recognizable logistics territories, not generic map zones.
- The hub and districts should create stories worth remembering.

5. **The shift matters**
- The game should feel like clocking into a real night shift.
- Dispatch boards, contract framing, staged stops, schedule pressure, payout, and summary feedback must all reinforce that.

6. **The shared depot matters**
- The depot is not a menu room.
- It is the emotional and social center of the game.
- Players should spawn there, see status, read aspirations, grab jobs, and want to return.

7. **Public progression matters**
- Visible rank, deliveries, trucks, active jobs, and status signals are part of the intended Roblox-facing feel.
- The world should feel shared from the first playable version, even before deep co-op.

## World Structure
- **Central shared depot / hub**
  - dispatch board
  - crew board
  - public leaderboard / showcase pads
  - truck bays
  - wayfinding to route exits
  - social readability and status display
- **District network**
  - Market Nine
  - Floodline
  - Dockside Ring
  - Brightline Civic
  - Old Transit
- **Support hubs**
  - Northline Crossdock
  - Compliance Gate
  - Relay Yard
  - Service Apron

The city is meant to feel larger than the current loop and ready for layered content, not solved in one short session.

## District Identity Targets
- **Market Nine**
  - tight commercial streets
  - stacked signage
  - short-turn pressure
  - lively urban logistics energy
- **Floodline**
  - weather-damaged roads
  - warning lamps
  - unstable surfaces
  - civic urgency and storm pressure
- **Dockside Ring**
  - freight-first lanes
  - container stacks
  - yard discipline
  - industrial scale
- **Brightline Civic**
  - permit gates
  - formal handoffs
  - compliance framing
  - structured civic loading
- **Old Transit**
  - relay yards
  - dead rail cuts
  - shadowed service corridors
  - risky shortcut identity

## Progression And Replayability Target
- repeatable contract board with nightly variation
- featured-district incentives
- dispatch streak momentum
- district mastery growth
- company level progression
- future truck upgrades and class differentiation
- future persistence / save-backed progression
- reasons to run “one more shift”

## Economy And Job Structure Target
- jobs expose:
  - client
  - cargo
  - district
  - route type
  - ETA / schedule pressure
  - reward / payout logic
- contracts scale from:
  - direct drop jobs
  - to pickup + handoff + final-delivery chains
- economy should reward readable risk/reward decisions, not just mileage

## Social And Public Progression Target
- public leaderboards
- overhead player status
- visible truck ownership/status
- active crew visibility
- showcase pads / aspiration displays
- future co-op/convoy/company hooks

The final game should feel socially alive even when solo-completable.

## UI / HUD Expectations
- compact driving HUD
- richer dispatch and summary surfaces
- board rows that are readable at a glance
- route/cargo/client/district identity without debug clutter
- clear “what do I do next?” objective support

## Tone, Mood, And Visual Target
- stylized social logistics city
- wet urban night
- practical and slightly absurd
- cozy-industrial rather than sterile
- readable, photogenic, and Roblox-native
- strong landmarking and signage
- busy but not cluttered

## Monetization Boundaries
- cosmetics
- company branding
- convenience / planning tools
- no pay-to-win gameplay power

## Most Important Missing Details Still Not Implemented
- first full pickup / handoff / delivery proof in live Studio
- persistence / DataStore layer
- stronger physical district differentiation in the live place
- more visible route-memory and district-mood physicalization
- deeper social/company layer
- art-ready asset swap pipeline

## What This Run Added To Move Closer
- the final-game target has now been made explicit in repo memory for live Roblox development
- the blank Studio place has been confirmed and used as the real logistics project foundation
- the live place now contains the first real shared depot, dispatch board, crew board, showcase pads, route signage, logistics nodes, and ambient workers
- the first live dispatch/job loop is partially playable:
- the first live dispatch/job loop is now functionally playable:
  - board opens
  - jobs are readable
  - contracts can be accepted
  - shifts can be started
  - the player can seat into the truck
- the live truck now assembles as a visible machine with cab, bed, wheels, seat, and lighting instead of only a placeholder model stub
- the live truck now moves under the Roblox-native baseline input path in the blank-place project
- the most important missing implementation is now the first full route-node and delivery proof, which is the next step needed to make the Roblox slice feel like the actual final game
