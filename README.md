# Godot Codex Testbed

This project now contains the earlier sandbox prototypes plus a new production-path **MIRA** vertical slice.

Graphics workflow now uses a hybrid Scene+Kit path under:

`res://mira/graphics/`

See:

`res://mira/graphics/WORKFLOW.md`

And canonical art direction:

`res://mira/graphics/ART_DIRECTION.md`

## Run

Open the project in Godot and press Play. The current main scene is:

`res://mira/scenes/mira_game.tscn`

The earlier tests are still available at:

`res://scenes/main.tscn`

`res://scenes/three_d_test.tscn`

`res://scenes/procedural_world.tscn`

## Controls

MIRA vertical slice:

- Start / relaunch: Enter or Left Click / X
- Move: WASD or left stick
- Look: Mouse or right stick
- Sprint: Ctrl / left shoulder
- Jump: Space / A
- Dash: Shift / right shoulder
- Slide: C or Alt / B
- Launch or reflect: Left Click / X
- Reset attempt: R / Y
- Procedural level (first pass): G
- Save metrics report: F6 (writes `user://mira_metrics_latest.json`)
- Release / recapture cursor: Escape

Procedural world (first person):

- Look: Mouse
- Move: WASD or arrow keys (camera-relative)
- Sprint: Shift
- Jump: Space
- Respawn: R
- Generate new world: Enter
- Release / recapture cursor: Escape (click in window to recapture)

3D arena test:

- Move: WASD or arrow keys
- Sprint: Shift
- Jump: Space
- Reset: R

2D test:

- Start/resume: Enter
- Move: WASD or arrow keys
- Dash: Space
- Pause: P or Escape
- Toggle sound: M
- Restart after a run: R

## What It Tests

- Project main scene wiring
- GDScript gameplay loop
- Runtime input bindings
- Code-drawn 2D visuals
- HUD labels and meters
- Spawning, collision checks, scoring, combo timing, screen shake
- Chasing enemy AI
- Hull health, invulnerability, and knockback
- Auto-granted upgrades
- Generated sound effects
- Start, pause, resume, and game-over overlays
- 3D camera follow
- 3D lights, materials, mesh primitives, and glow
- CharacterBody3D movement, jumping, gravity, and static-body collisions
- Moving 3D hazards and collectible pickups
- Runtime noise terrain mesh generation
- Generated terrain collision
- Procedural trees, rocks, ruin blocks, water, and collectible beacons
- Seeded regeneration from inside the running scene
- Separate `mira/` production path with authored relay nodes, first-person controller, pulse runtime, title shell, HUD, and Golden Route level
