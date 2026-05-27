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

## 9) Known-Good Entry Points (Start Here)

When onboarding into this repo, start in this order:

1. `mira/scenes/fresh/fresh_movement_only.tscn` (movement feel sandbox)
2. `mira/scripts/fresh/fresh_player_controller.gd` (jump/dash/slide tuning)
3. `mira/scripts/fresh/movement_metrics.gd` (formula helpers for jump distance recalculation)
4. `mira/scenes/mira_game.tscn` (runtime game loop)
5. `mira/scripts/mira_game.gd` (level load, pulse, HUD, input mapping)
6. `mira/scripts/mira_levels.gd` + `mira/scripts/scene_level_spec.gd` (level definitions and scene bridge)

---

## 10) Definition of Done (Per Section / Milestone)

A section is complete only when all are true:

1. Feature behavior works in intended scene(s).
2. Relevant smoke/regression checklist passes.
3. Known limitations are documented.
4. `README.md` is updated with behavior/control/workflow changes.
5. A git commit includes code + README updates.
6. Changes are pushed to `origin/main`.
7. If uncertainty remains, it is explicitly noted with verification steps.

---

## 11) Movement Tuning Log Template

When changing movement feel, append an entry to `CHANGELOG_AI.md` using this structure:

```md
## YYYY-MM-DD - Movement Pass Name
- Scene: `res://mira/scenes/fresh/fresh_movement_only.tscn`
- Goal: short statement
- Parameters changed:
  - `jump_velocity`: old -> new
  - `gravity_force`: old -> new
  - `dash_speed`: old -> new
  - `slide_kick_speed`: old -> new
- Why: short rationale
- Result: what improved / what regressed
- Next test: one concrete follow-up
```

---

## 12) Branch + Commit Conventions

Branch naming (recommended):

- `feat/<area>-<short-purpose>`
- `fix/<area>-<short-purpose>`
- `docs/<scope>`

Examples:

- `feat/movement-jump-pass`
- `fix/skybox-fresh-scene`
- `docs/readme-handoff-update`

Commit message style:

- `<type>: <what changed and why>`

Examples:

- `feat: improve dash-to-slide carry consistency`
- `fix: lock fresh scene camera to startup state`
- `docs: update README with movement tuning workflow`

---

## 13) Regression / Smoke Checklist

Run this checklist after movement or scene changes:

1. Scene loads without parse errors:
   - `res://mira/scenes/fresh/fresh_movement_only.tscn`
   - `res://mira/scenes/mira_game.tscn`
2. Mouse capture/release works (`Esc`, click recapture).
3. Jump is reproducible and apex feels unchanged unless intentionally tuned.
4. Dash triggers on press and cooldown feels consistent.
5. Slide triggers reliably (`C`/`Alt`) and carry works after dash.
6. Camera behavior is stable during sprint/slide.
7. Reset (`R`) and fall reset work.
8. If skybox changed: sky renders and is not black.
9. README + changelog updated, committed, and pushed.

---

## 14) Collaboration Rules for Future AIs

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
5. Always provide the user with recommended file paths/scenes/scripts to edit for the requested task.
6. If any answer is uncertain, explicitly say what is uncertain, why, and how to verify it.
7. Explain industry-standard implementation patterns when proposing architecture or system design.
8. Ask relevant architecture questions before major builds (ownership boundaries, scene vs code, data model, and extensibility expectations).

### 9.1 Mandatory README + Commit Cadence

For every completed work section/milestone:

1. Update `README.md` with what changed.
2. Commit the README update in that same change set.
3. Push so collaborators and future AIs are synced.

Do not leave README updates only in local working state after a section is complete.

---

## 15) Git / Cloud Sync Workflow

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

## 16) Living Doc Policy

This README is intended to stay current.  
Any future assistant modifying gameplay, controls, scene layout, or workflow should update this file in the same change set.

Additional non-optional policy:

- After each completed section/milestone, update and commit the README, then push.
- Include clear recommended paths in guidance to the user.
- Be explicit about uncertainty instead of presenting guesses as facts.
- Use and explain industry-standard approaches for implementation choices.
- Ask architecture questions when scope affects long-term structure.
