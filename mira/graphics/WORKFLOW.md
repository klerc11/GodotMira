# MIRA Graphics Workflow (Hybrid Scene+Kit)

Reference direction:
- `res://mira/graphics/ART_DIRECTION.md`

## Authoring Model
- Gameplay stays code-driven in `res://mira/scripts/mira_game.gd`.
- Visual construction uses modular scene kit assets in `res://mira/graphics/modules`.
- Runtime-only visuals are limited to pulse/FX and HUD updates.

## Kit Contents
- Modules:
  - `PlatformModule.tscn`
  - `WallModule.tscn`
  - `TrimModule.tscn`
  - `RailModule.tscn`
  - `MirrorFrameModule.tscn`
  - `HazardBlockerModule.tscn`
- Materials:
  - `M_BaseMetalDark.tres`
  - `M_BasePanel.tres`
  - `M_NeonCyan.tres`
  - `M_NeonAmber.tres`
  - `M_NeonMagenta.tres`
  - `M_GlassEnergy.tres`
- Environment presets:
  - `Env_NightSciFi_A.tres`
  - `Env_NightSciFi_HighFog.tres`
  - `Env_NightSciFi_Clear.tres`
- FX presets:
  - `FX_PulseTrail.tscn`
  - `FX_BeamParticles.tscn`
  - `FX_ReceptorGlow.tscn`
  - `FX_StartZoneStrip.tscn`

## Level Visual Pass Order
1. Gameplay blockout (collision and routing first).
2. Readability pass (main routes brighter than optional routes).
3. Style pass (trim, rails, accents).
4. FX pass (pulse-reactive cues and endpoint glow).
5. Performance pass (light count, particles, culling sanity).

## Non-Negotiable Visual Rules
- The beam is the detail.
- Architecture stays restrained (no decorative neon drift).
- Use giant forms and negative space before micro-detail.
- Purple is atmosphere-only.
- Activation should be local to transmission and decay back to silence.
- If readability and style conflict, choose readability.

## Environment Selection
- Set `env_preset` in a level dictionary:
  - `"default"` -> `Env_NightSciFi_A`
  - `"high_fog"` -> `Env_NightSciFi_HighFog`
  - `"clear"` -> `Env_NightSciFi_Clear`
