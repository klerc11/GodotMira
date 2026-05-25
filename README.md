# MIRA (Godot) - Living Project README

This is the primary handoff document for humans and AI collaborators working in this repository.

Last updated: 2026-05-25
Repo: https://github.com/klerc11/GodotMira
Project root: `C:\SkillGap\template`

---

## 1) Project Intent

MIRA is a high-speed 3D relay platformer prototype focused on:

- movement feel (jump / dash / slide)
- readable routing
- interception timing
- rapid retry loops

Core loop: `fire -> move -> meet -> reflect -> recover`

This repo currently contains:

1. **Production-path MIRA systems** under `mira/`
2. **Legacy sandbox prototypes** under root `scenes/` and `scripts/`
3. **A fresh standalone movement sandbox** used for direct feel tuning

---

## 2) Current Main Scene

Godot project main scene:

- `res://mira/scenes/mira_game.tscn`

Configured in:

- `project.godot` -> `run/main_scene="res://mira/scenes/mira_game.tscn"`

---

## 3) Scene Map (What Exists)

### Production / MIRA scenes

- `mira/scenes/mira_game.tscn`  
  Runtime MIRA game scene (loads level specs, player, pulse, HUD)

- `mira/scenes/levels/authoring_template.tscn`  
  Scene-authorable template level (platform groups, bounds, helpers)

- `mira/scenes/levels/lab_three_course.tscn`  
  3-lane platforming lab scene

- `mira/scenes/levels/golden_route.tscn`  
  Golden Route style content scene

### Fresh movement sandbox (current movement tuning sandbox)

- `mira/scenes/fresh/fresh_movement_only.tscn`
- `mira/scenes/fresh/fresh_sky_env.tres`
- Controller: `mira/scripts/fresh/fresh_player_controller.gd`

This scene is standalone and intentionally simple for movement testing.

### Legacy sandbox scenes (kept for reference)

- `scenes/main.tscn`
- `scenes/three_d_test.tscn`
- `scenes/procedural_world.tscn`

---

## 4) Current Control Schemes

## 4.1 Fresh movement sandbox controls

Scene: `mira/scenes/fresh/fresh_movement_only.tscn`

- Move: `WASD` or arrow keys
- Look: mouse
- Jump: `Space`
- Dash: `Shift`
- Sprint: `Ctrl`
- Slide: `C` or `Alt`
- Respawn: `R`
- Mouse capture toggle: `Esc` (click window to recapture)

Notes:

- Camera is intentionally fixed (no speed/slide camera modulation).
- Slide particles emit during slide and also when sprinting (`Ctrl`) while grounded/moving.

## 4.2 MIRA runtime controls

Scene: `mira/scenes/mira_game.tscn`

- Move: `WASD` / left stick
- Look: mouse / right stick
- Jump: `Space` / `A`
- Dash: `Shift` / right shoulder
- Sprint: `Ctrl` / left shoulder
- Slide: `C` or `Alt` / `B`
- Pulse action (launch/reflect): left click / `X`
- Reset: `R` / `Y`
- Next / previous level: `N` / `P`
- Procedural generate: `G`
- Metrics report save: `F6`
- Scene parity check: `F7`

---

## 5) Architecture Summary

## 5.1 Runtime MIRA core

- `mira/scripts/mira_game.gd`  
  Main runtime owner: input map binding, level load, pulse runtime, geometry attach/build, HUD updates.

- `mira/scripts/mira_levels.gd`  
  Level list / level dictionaries.

- `mira/scripts/mira_player.gd`  
  Main MIRA player controller (third-person style with full movement stack).

- `mira/scripts/mira_procgen.gd`  
  Procedural level generator utility.

## 5.2 Scene-driven level data bridge

- `mira/scripts/scene_level_spec.gd`  
  Converts level scene markers/groups into a runtime dictionary (`build_level_spec`).

Supports:

- spawn/source/target markers
- bounds markers
- platform/absorber collection
- toggles for using scene-owned geometry vs runtime-generated visuals
- optional handoff to `mira_game.tscn` when launching level scenes directly

## 5.3 Graphics kit and presets

Under `mira/graphics/`:

- `materials/` shared materials
- `modules/` reusable scene modules (platform/wall/trim/rail/mirror/blocker)
- `fx/` shared FX scenes
- `environments/` shared environment/sky resources
- `ART_DIRECTION.md` and `WORKFLOW.md`

---

## 6) Authoring Workflow (Current Recommended)

For level building in editor:

1. Duplicate `mira/scenes/levels/authoring_template.tscn`
2. Edit marker nodes:
   - `SpawnPoint`, `SourcePoint`, `TargetPoint`
   - `WorldBounds/Min`, `WorldBounds/Max`
3. Build collision/layout in:
   - `Platforms`
   - `Absorbers`
4. Add art/readability shapes in:
   - `EnvironmentShapes/Geometry`
   - `EnvironmentShapes/Backdrop`
   - `EnvironmentShapes/Guide`
5. Add scene path to `mira/scripts/mira_levels.gd` as `scene_override_path`
6. Run from `mira/scenes/mira_game.tscn`

---

## 7) Known Gotchas / Troubleshooting

1. **Skybox looks black**  
   - Ensure texture is imported (`--import` or reopen project).
   - Fresh sandbox uses `mira/scenes/fresh/fresh_sky_env.tres`.
   - If replacing sky files, verify `.import` is generated.

2. **Scene looks different between editor and runtime**  
   - Use `F7` parity check in `mira_game`.
   - Ensure level uses `scene_override_path`.
   - Confirm `SceneLevelSpec` toggles for scene-owned nodes are enabled.

3. **Mesh collision not auto-linked to geometry changes**  
   - Collision generated from mesh is a snapshot; regenerate after mesh edits.

4. **Mouse weirdness after tabbing or uncapturing**  
   - Press `Esc`, then click window to recapture.

---

## 8) Current Priority (Next Session)

Primary focus:

- **Nail jump, dash, slide feel**

Suggested pass order:

1. jump consistency and measurable apex
2. dash distance and cooldown feel
3. slide entry reliability + dash-to-slide carry
4. landing forgiveness and recovery flow

Use the fresh sandbox (`mira/scenes/fresh/fresh_movement_only.tscn`) for fast iteration.

---

## 9) Collaboration Rules for Future AIs

Before changing systems:

1. Read:
   - `README.md` (this file)
   - `mira/graphics/ART_DIRECTION.md`
   - `mira/graphics/WORKFLOW.md`
   - `mira/scripts/mira_levels.gd`
   - `mira/scripts/scene_level_spec.gd`
2. Prefer editing `mira/` production path over legacy root sandboxes.
3. Keep changes scoped and test scene load after edits.
4. Update this README when behavior, controls, architecture, or workflow changes.

---

## 10) Git / Cloud Sync Workflow

This project is connected to:

- `origin/main` -> `https://github.com/klerc11/GodotMira.git`

Standard routine:

1. `git pull`
2. Make changes
3. `git add .`
4. `git commit -m "message"`
5. `git push`

Current `.gitignore` includes:

- `.godot/`
- `/android/`
- `sessions/`
- `.git_broken_sandbox/`

---

## 11) Living Doc Policy

This README is intended to stay current.  
Any future assistant modifying gameplay, controls, scene layout, or workflow should update this file in the same change set.

