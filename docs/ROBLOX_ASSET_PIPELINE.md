# Roblox Asset Pipeline

## Principle
Use Roblox-native primitives and materials first to prove layout, readability, and gameplay. Replace with custom or curated assets only when the gameplay role is already stable.

## Asset Sources
### Built-In Roblox First
- hub layout
- road layout
- truck baseline
- signage placement
- boards
- bay compounds

### Creator Store Selectively
- only when clearly useful
- inspect before trusting
- avoid script-heavy or suspicious inserts
- prefer static or easily auditable assets

### Custom Later
- truck exterior
- district hero pieces
- branded signage
- UI art
- iconography
- special landmark silhouettes

## Import Safety Rules
- no random packs
- no script-heavy inserts without inspection
- no aesthetic clutter that harms route readability

## Pipeline Stages
1. graybox prove-out
2. gameplay readability check
3. asset-group priority selection
4. custom / reviewed insert pass
5. polish + optimization

## Current Recommendation
- keep world generation and layout modular in Luau
- keep reusable structural builders
- preserve current proportions when swapping art
- prioritize:
  1. depot kit
  2. signage kit
  3. truck kit
  4. first two district kits
