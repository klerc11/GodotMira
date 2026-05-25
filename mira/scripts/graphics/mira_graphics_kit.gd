class_name MiraGraphicsKit
extends RefCounted

const PLATFORM_MODULE_SCENE: PackedScene = preload("res://mira/graphics/modules/PlatformModule.tscn")
const WALL_MODULE_SCENE: PackedScene = preload("res://mira/graphics/modules/WallModule.tscn")
const TRIM_MODULE_SCENE: PackedScene = preload("res://mira/graphics/modules/TrimModule.tscn")
const RAIL_MODULE_SCENE: PackedScene = preload("res://mira/graphics/modules/RailModule.tscn")
const MIRROR_FRAME_MODULE_SCENE: PackedScene = preload("res://mira/graphics/modules/MirrorFrameModule.tscn")
const HAZARD_BLOCKER_MODULE_SCENE: PackedScene = preload("res://mira/graphics/modules/HazardBlockerModule.tscn")

const FX_BEAM_PARTICLES_SCENE: PackedScene = preload("res://mira/graphics/fx/FX_BeamParticles.tscn")
const FX_PULSE_TRAIL_SCENE: PackedScene = preload("res://mira/graphics/fx/FX_PulseTrail.tscn")
const FX_RECEPTOR_GLOW_SCENE: PackedScene = preload("res://mira/graphics/fx/FX_ReceptorGlow.tscn")
const FX_START_ZONE_STRIP_SCENE: PackedScene = preload("res://mira/graphics/fx/FX_StartZoneStrip.tscn")

const M_BASE_METAL_DARK: Material = preload("res://mira/graphics/materials/M_BaseMetalDark.tres")
const M_BASE_PANEL: Material = preload("res://mira/graphics/materials/M_BasePanel.tres")
const M_NEON_CYAN: Material = preload("res://mira/graphics/materials/M_NeonCyan.tres")
const M_NEON_AMBER: Material = preload("res://mira/graphics/materials/M_NeonAmber.tres")
const M_NEON_MAGENTA: Material = preload("res://mira/graphics/materials/M_NeonMagenta.tres")
const M_GLASS_ENERGY: Material = preload("res://mira/graphics/materials/M_GlassEnergy.tres")

const ENV_NIGHTSCIFI_A: Environment = preload("res://mira/graphics/environments/Env_NightSciFi_A.tres")
const ENV_NIGHTSCIFI_HIGHFOG: Environment = preload("res://mira/graphics/environments/Env_NightSciFi_HighFog.tres")
const ENV_NIGHTSCIFI_CLEAR: Environment = preload("res://mira/graphics/environments/Env_NightSciFi_Clear.tres")


static func instantiate_module(scene: PackedScene) -> Node:
	return scene.instantiate()


static func copy_material(source: Material) -> Material:
	return source.duplicate(true) if source != null else null


static func environment_from_key(key: String) -> Environment:
	match key:
		"high_fog":
			return ENV_NIGHTSCIFI_HIGHFOG.duplicate(true)
		"clear":
			return ENV_NIGHTSCIFI_CLEAR.duplicate(true)
		_:
			return ENV_NIGHTSCIFI_A.duplicate(true)
