# Mechanics Upgrade Report

## Sprint Focus
Push the graybox toward a stickier, Roblox-facing logistics loop without abandoning the existing city-driving fantasy.

## What Changed
- Added rotating offer-board modifiers so the same contract list has nightly variation.
- Added a featured-district bonus so the board encourages travel across the full city instead of repeating one safest route.
- Added dispatch streak bonuses so successful consecutive shifts have a stronger "one more run" pull.
- Added district mastery progression so repeated deliveries create a visible relationship with specific neighborhoods.
- Upgraded late-game jobs into multi-stop logistics chains with:
  - pickup stop
  - optional handoff stop
  - final delivery
- Extended summary feedback so the player can see:
  - board used
  - pickup/handoff history
  - mastery state
  - dispatch streak
  - company rank

## Why It Matters
- The larger map now creates better decisions instead of only more travel time.
- Higher-tier jobs feel more like logistics operations instead of longer single-point drives.
- Repetition now produces progression signals the player can feel inside the session.
- The loop is closer to a return-value structure that can survive in a Roblox-style environment later.

## What Is Still Missing
- persistent save/meta progression
- upgrade tree
- real social/company systems
- true traffic AI
- deeper economy sinks

## Immediate Design Read
The core loop is no longer just:
- pick contract
- drive
- deliver

It is now closer to:
- read the live board
- choose a valuable job
- account for route, board, and district pressure
- complete one or more logistics stops
- gain credits, mastery, streak, and rank momentum
- repeat with a better reason to continue
