# CHANGELOG_AI

This file is a concise running log for AI-delivered implementation passes.

Use this log for:

- movement tuning history
- architecture decisions
- behavior regressions and fixes
- what was changed and why

---

## 2026-05-25 - Initial Baseline + Documentation Contract

- Scene focus: `res://mira/scenes/fresh/fresh_movement_only.tscn`
- Goal: establish stable movement sandbox and durable collaboration handoff.
- Key outcomes:
  - standalone third-person movement sandbox established
  - camera behavior stabilized (no slide/sprint modulation)
  - slide/sprint base particles added
  - fresh sky environment resource added and wired for sandbox scene
  - README expanded to full living handoff and AI collaboration contract
- Documentation/process outcomes:
  - mandatory README update + commit cadence added
  - known-good entry points documented
  - DoD, tuning template, branch/commit conventions, and regression checklist added
- Next target:
  - jump/dash/slide tuning pass with measured value tracking

## 2026-05-26 - Movement Formula Helper Added

- Added: `res://mira/scripts/fresh/movement_metrics.gd`
- Purpose:
  - recalculate jump/airtime/distance quickly when tuning values change
  - provide reusable formulas for walk/sprint jump ranges and dash/slide extra distance
- Includes:
  - `jump_air_time(...)`
  - `flat_gap_distance_constant_speed(...)`
  - `flat_gap_distance_with_accel(...)`
  - `dash_extra_distance(...)`
  - `slide_extra_distance(...)`
  - `profile_summary(...)`
