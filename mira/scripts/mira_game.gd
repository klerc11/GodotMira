class_name MiraGame
extends Node3D

const MIRA_LEVELS_SCRIPT = preload("res://mira/scripts/mira_levels.gd")
const MIRA_PLAYER_SCRIPT = preload("res://mira/scripts/mira_player.gd")
const MIRA_AUDIO_SCRIPT = preload("res://mira/scripts/mira_audio.gd")
const MIRA_GRAPHICS_KIT_SCRIPT = preload("res://mira/scripts/graphics/mira_graphics_kit.gd")
const MIRA_PROCGEN_SCRIPT = preload("res://mira/scripts/mira_procgen.gd")
const MIRA_METRICS_SCRIPT = preload("res://mira/scripts/mira_metrics.gd")

const MIRROR_SPEED_RAMP: float = 1.1
const PLAYER_REFLECT_SPEED_RAMP: float = 1.18
const DEFAULT_BASE_SPEED_MULTIPLIER: float = 1.0
const DEFAULT_SPEED_DECAY_RATE: float = 0.18
const DEFAULT_INTERCEPT_RADIUS: float = 2.15
const DEFAULT_PLAYER_REFLECT_STABILITY_RATIO: float = 0.45
const DEFAULT_MAX_PULSE_SPEED_MULTIPLIER: float = 1.75
const LEVEL_YAW_CORRECTION: float = -PI
const PRESSURE_FAIL_GRACE: float = 0.32

var level_specs: Array[Dictionary] = MIRA_LEVELS_SCRIPT.get_levels()
var active_level_index: int = 0
var procedural_level_index: int = -1
var procedural_seed: int = 2401

var world_root: Node3D
var backdrop_root: Node3D
var geometry_root: Node3D
var guide_root: Node3D
var pulse_root: Node3D
var ui_layer: CanvasLayer
var ui_root: Control
var hud_label: Label
var prompt_label: Label
var world_environment: Environment
var world_environment_node: WorldEnvironment
var graphics_kit
var metrics
var sun_light: DirectionalLight3D
var fill_light: OmniLight3D
var rim_light: OmniLight3D

var player
var audio_bus

var world_bounds: AABB = AABB(Vector3(-20.0, -4.0, -150.0), Vector3(40.0, 18.0, 172.0))
var source_position: Vector3 = Vector3.ZERO
var source_floor_center: Vector3 = Vector3.ZERO
var fire_zone_radius: float = 2.25
var fire_zone_size: Vector2 = Vector2(0.0, 0.0)
var target_position: Vector3 = Vector3.ZERO
var target_radius: float = 2.0
var level_spawn_yaw: float = PI
var level_spawn_pitch: float = 0.08

var source_group: Node3D
var target_group: Node3D

var solids: Array[Dictionary] = []
var reflector_runtime: Array[Dictionary] = []

var pulse_active: bool = false
var pulse_position: Vector3 = Vector3.ZERO
var pulse_direction: Vector3 = Vector3.FORWARD
var pulse_age: float = 0.0
var pulse_ttl: float = 8.0
var pulse_stability: float = 0.0
var pulse_max_stability: float = 7.0
var pulse_base_speed: float = 10.0
var pulse_speed: float = 10.0
var pulse_bounces: int = 0
var pulse_trail_history: Array[Vector3] = []
var base_pulse_speed_multiplier: float = DEFAULT_BASE_SPEED_MULTIPLIER
var pulse_speed_decay_rate: float = DEFAULT_SPEED_DECAY_RATE
var player_reflect_stability_ratio: float = DEFAULT_PLAYER_REFLECT_STABILITY_RATIO
var max_pulse_speed_multiplier: float = DEFAULT_MAX_PULSE_SPEED_MULTIPLIER
var intercept_radius: float = DEFAULT_INTERCEPT_RADIUS
var intercept_cooldown: float = 0.0

var pulse_mesh: MeshInstance3D
var pulse_shell: MeshInstance3D
var pulse_light: OmniLight3D
var pulse_beam_particles: GPUParticles3D
var pulse_beam_process: ParticleProcessMaterial
var pulse_hum: AudioStreamPlayer3D
var trail_meshes: Array[MeshInstance3D] = []
var player_bounds_margin: float = 2.5
var pressure_beam_enabled: bool = true
var pressure_beam_node: Node3D
var pressure_beam_mesh: MeshInstance3D
var pressure_beam_light: OmniLight3D
var transmission_activation_light: OmniLight3D
var pressure_axis_origin: Vector3 = Vector3.ZERO
var pressure_axis_dir: Vector3 = Vector3(0.0, 0.0, -1.0)
var pressure_progress: float = -7.0
var pressure_speed: float = 9.5
var pressure_max_speed: float = 18.5
var pressure_accel: float = 2.2
var pressure_catch_tolerance: float = 0.7
var pressure_catch_grace_timer: float = 0.0
var pressure_width: float = 40.0
var pressure_height: float = 6.2
var relay_checkpoint_position: Vector3 = Vector3.ZERO
var relay_checkpoint_active: bool = false
var platform_support_towers_enabled: bool = false
var platform_support_ground_y: float = -1.0


func _ready() -> void:
	graphics_kit = MIRA_GRAPHICS_KIT_SCRIPT
	metrics = MIRA_METRICS_SCRIPT.new()
	_configure_input_map()
	_build_scene_roots()
	_build_lighting()
	_build_ui()
	_build_runtime_nodes()
	_load_level(0)


func _exit_tree() -> void:
	if pulse_hum != null:
		pulse_hum.stop()
		pulse_hum.stream = null
		pulse_hum.queue_free()
		pulse_hum = null
	if audio_bus != null and audio_bus.has_method("release_cached_streams"):
		audio_bus.release_cached_streams()


func _physics_process(delta: float) -> void:
	player.physics_step(delta)
	_capture_metrics_sample(delta)
	if _check_player_out_of_bounds():
		return
	_update_pressure_beam(delta)
	if pulse_active:
		_update_pulse(delta)
	_update_pulse_audio()
	_update_ui()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pulse_action"):
		_pulse_action()
	elif event.is_action_pressed("restart"):
		if metrics != null:
			metrics.mark_reset()
		_finalize_metrics_attempt(false, "manual_reset")
		_reset_player_to_start()
		_deactivate_pulse()
		_start_metrics_attempt(level_specs[active_level_index])
	elif event.is_action_pressed("procedural_generate"):
		_generate_procedural_level(true)
	elif event.is_action_pressed("metrics_report"):
		if metrics != null:
			metrics.save_last_report()
			prompt_label.text = metrics.latest_summary_line()
	elif event.is_action_pressed("parity_check"):
		_run_scene_parity_check()
	elif event.is_action_pressed("next_level"):
		_load_level(active_level_index + 1)
	elif event.is_action_pressed("prev_level"):
		_load_level(active_level_index - 1)


func _build_scene_roots() -> void:
	world_root = Node3D.new()
	add_child(world_root)
	backdrop_root = Node3D.new()
	geometry_root = Node3D.new()
	guide_root = Node3D.new()
	pulse_root = Node3D.new()
	world_root.add_child(backdrop_root)
	world_root.add_child(geometry_root)
	world_root.add_child(guide_root)
	world_root.add_child(pulse_root)


func _build_lighting() -> void:
	_build_environment()

	sun_light = DirectionalLight3D.new()
	sun_light.rotation_degrees = Vector3(-39.0, 30.0, 0.0)
	sun_light.light_energy = 1.22
	sun_light.light_color = Color(0.79, 0.82, 0.88, 1.0)
	sun_light.shadow_enabled = true
	world_root.add_child(sun_light)

	fill_light = OmniLight3D.new()
	fill_light.position = Vector3(-10.0, 6.5, 8.0)
	fill_light.light_color = Color(0.26, 0.28, 0.36, 1.0)
	fill_light.light_energy = 0.86
	fill_light.omni_range = 48.0
	world_root.add_child(fill_light)

	rim_light = OmniLight3D.new()
	rim_light.position = Vector3(10.0, 5.0, -24.0)
	rim_light.light_color = Color(0.2902, 0.2627, 0.3765, 1.0)
	rim_light.light_energy = 0.24
	rim_light.omni_range = 30.0
	world_root.add_child(rim_light)


func _build_environment() -> void:
	world_environment = graphics_kit.environment_from_key("default")
	world_environment_node = WorldEnvironment.new()
	world_environment_node.environment = world_environment
	world_root.add_child(world_environment_node)


func _build_ui() -> void:
	ui_layer = CanvasLayer.new()
	add_child(ui_layer)

	ui_root = Control.new()
	ui_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(ui_root)

	var hud_back: ColorRect = ColorRect.new()
	hud_back.position = Vector2(12.0, 12.0)
	hud_back.size = Vector2(500.0, 58.0)
	hud_back.color = Color(0.01, 0.04, 0.08, 0.58)
	ui_root.add_child(hud_back)

	hud_label = Label.new()
	hud_label.position = Vector2(20.0, 16.0)
	hud_label.size = Vector2(488.0, 52.0)
	hud_label.add_theme_font_size_override("font_size", 14)
	hud_label.add_theme_color_override("font_color", Color(0.5608, 1.0, 0.8196, 1.0))
	hud_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.88))
	hud_label.add_theme_constant_override("shadow_offset_x", 1)
	hud_label.add_theme_constant_override("shadow_offset_y", 1)
	ui_root.add_child(hud_label)

	prompt_label = Label.new()
	prompt_label.position = Vector2(270.0, 682.0)
	prompt_label.size = Vector2(540.0, 24.0)
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.add_theme_font_size_override("font_size", 14)
	prompt_label.add_theme_color_override("font_color", Color(0.8392, 0.6431, 0.3529, 1.0))
	ui_root.add_child(prompt_label)


func _build_runtime_nodes() -> void:
	audio_bus = MIRA_AUDIO_SCRIPT.new()
	add_child(audio_bus)

	player = MIRA_PLAYER_SCRIPT.new()
	world_root.add_child(player)

	source_group = Node3D.new()
	target_group = Node3D.new()
	world_root.add_child(source_group)
	world_root.add_child(target_group)

	pulse_mesh = MeshInstance3D.new()
	var pulse_geo: SphereMesh = SphereMesh.new()
	pulse_geo.radius = 0.11
	pulse_geo.height = 0.22
	pulse_mesh.mesh = pulse_geo
	pulse_root.add_child(pulse_mesh)

	pulse_shell = MeshInstance3D.new()
	var shell_geo: SphereMesh = SphereMesh.new()
	shell_geo.radius = 0.24
	shell_geo.height = 0.48
	pulse_shell.mesh = shell_geo
	pulse_root.add_child(pulse_shell)

	pulse_light = OmniLight3D.new()
	pulse_light.omni_range = 8.0
	pulse_root.add_child(pulse_light)

	pulse_beam_particles = graphics_kit.instantiate_module(graphics_kit.FX_BEAM_PARTICLES_SCENE) as GPUParticles3D
	pulse_beam_process = pulse_beam_particles.process_material as ParticleProcessMaterial
	pulse_root.add_child(pulse_beam_particles)

	pulse_hum = audio_bus.create_pulse_hum_player()
	pulse_root.add_child(pulse_hum)
	pulse_hum.play()
	pulse_hum.stream_paused = true

	for index in range(12):
		var trail_mesh: MeshInstance3D = graphics_kit.instantiate_module(graphics_kit.FX_PULSE_TRAIL_SCENE) as MeshInstance3D
		trail_mesh.visible = false
		pulse_root.add_child(trail_mesh)
		trail_meshes.append(trail_mesh)

	pressure_beam_node = Node3D.new()
	world_root.add_child(pressure_beam_node)

	pressure_beam_mesh = MeshInstance3D.new()
	var pressure_mesh: BoxMesh = BoxMesh.new()
	pressure_mesh.size = Vector3(pressure_width, pressure_height, 0.28)
	pressure_beam_mesh.mesh = pressure_mesh
	pressure_beam_mesh.material_override = _make_material(Color(0.5608, 1.0, 0.8196, 0.2), Color(0.9373, 1.0, 0.9725, 1.0), 0.44, 0.08, 0.05)
	pressure_beam_node.add_child(pressure_beam_mesh)

	pressure_beam_light = OmniLight3D.new()
	pressure_beam_light.light_color = Color(0.5608, 1.0, 0.8196, 1.0)
	pressure_beam_light.light_energy = 0.34
	pressure_beam_light.omni_range = 17.0
	pressure_beam_node.add_child(pressure_beam_light)
	pressure_beam_node.visible = false

	transmission_activation_light = OmniLight3D.new()
	transmission_activation_light.light_color = Color(0.5608, 1.0, 0.8196, 1.0)
	transmission_activation_light.light_energy = 0.0
	transmission_activation_light.omni_range = 10.5
	transmission_activation_light.shadow_enabled = false
	world_root.add_child(transmission_activation_light)

	_hide_pulse_visuals()


func _load_level(index: int) -> void:
	active_level_index = wrapi(index, 0, level_specs.size())
	var level: Dictionary = _resolve_level_spec(level_specs[active_level_index])
	_clear_world_geometry()

	source_position = level.get("source", Vector3.ZERO) as Vector3
	source_floor_center = Vector3(source_position.x, 0.0, source_position.z)
	fire_zone_radius = float(level.get("fire_zone_radius", 2.25))
	target_position = level.get("target", Vector3.ZERO) as Vector3
	target_radius = float(level.get("target_radius", 2.0))
	player_reflect_stability_ratio = float(level.get("player_reflect_stability_ratio", DEFAULT_PLAYER_REFLECT_STABILITY_RATIO))
	max_pulse_speed_multiplier = float(level.get("max_pulse_speed_multiplier", DEFAULT_MAX_PULSE_SPEED_MULTIPLIER))
	world_bounds = AABB(
		level.get("world_bounds_min", Vector3(-20.0, -4.0, -150.0)) as Vector3,
		(level.get("world_bounds_max", Vector3(20.0, 12.0, 22.0)) as Vector3) - (level.get("world_bounds_min", Vector3(-20.0, -4.0, -150.0)) as Vector3)
	)
	var bounds_width: float = maxf(4.0, world_bounds.size.x - 2.0)
	var default_strip_depth: float = maxf(4.4, fire_zone_radius * 2.2)
	fire_zone_size = level.get("fire_zone_size", Vector2(bounds_width, default_strip_depth)) as Vector2
	level_spawn_yaw = float(level.get("yaw", PI)) + LEVEL_YAW_CORRECTION
	level_spawn_pitch = float(level.get("pitch", 0.08))
	platform_support_towers_enabled = bool(level.get("platform_support_towers", false))
	platform_support_ground_y = float(level.get("platform_support_ground_y", source_floor_center.y - 1.0))
	_apply_level_environment(level)
	_apply_runtime_global_lighting(level)
	_configure_pressure_beam_for_level(level)
	_attach_scene_environment_shapes(level)

	var using_scene_platforms: bool = _attach_scene_collision_nodes(level, "use_scene_platform_nodes", "scene_platforms_root_path", "platform")
	if not using_scene_platforms:
		_build_platforms(level.get("platforms", []) as Array)
	if bool(level.get("build_runtime_world_boundaries", true)):
		_build_world_boundaries()
	var using_scene_absorbers: bool = _attach_scene_collision_nodes(level, "use_scene_absorber_nodes", "scene_absorbers_root_path", "absorber")
	if not using_scene_absorbers:
		_build_absorbers(level.get("absorbers", []) as Array)
	_build_reflectors(level.get("reflectors", []) as Array)
	_build_channels(level.get("channels", []) as Array)
	_build_appointments(level.get("appointments", []) as Array)
	if bool(level.get("build_runtime_backdrop", true)):
		_build_city_backdrop()
	if bool(level.get("build_runtime_source_zone_visuals", true)):
		_build_source_zone()
	if bool(level.get("build_runtime_target_zone_visuals", true)):
		_build_target_zone(level.get("target_visual_radius", 0.8) as float)
	if bool(level.get("build_runtime_level_art", true)):
		_build_level_specific_art(level)

	var spawn: Vector3 = level.get("spawn", Vector3.ZERO) as Vector3
	player.reset_to(spawn, level_spawn_yaw, level_spawn_pitch)
	player.set_input_enabled(true)
	relay_checkpoint_position = spawn
	relay_checkpoint_active = true
	_start_metrics_attempt(level)
	_deactivate_pulse()


func _resolve_level_spec(base_level: Dictionary) -> Dictionary:
	var resolved: Dictionary = base_level.duplicate(true)
	var override_scene_path: String = str(base_level.get("scene_override_path", ""))
	if override_scene_path.is_empty():
		return resolved

	var packed_scene: PackedScene = load(override_scene_path) as PackedScene
	if packed_scene == null:
		push_warning("Could not load scene_override_path: %s" % override_scene_path)
		return resolved

	var scene_instance: Node = packed_scene.instantiate()
	if scene_instance == null:
		push_warning("Could not instantiate scene_override_path: %s" % override_scene_path)
		return resolved

	if scene_instance.has_method("build_level_spec"):
		var override_spec_variant: Variant = scene_instance.call("build_level_spec")
		if override_spec_variant is Dictionary:
			var override_spec: Dictionary = override_spec_variant as Dictionary
			for key_variant in override_spec.keys():
				if key_variant is String:
					var key: String = key_variant
					resolved[key] = override_spec[key]

	scene_instance.free()
	return resolved


func _apply_runtime_global_lighting(level: Dictionary) -> void:
	var use_runtime_lighting: bool = bool(level.get("build_runtime_global_lighting", true))
	if sun_light != null:
		sun_light.visible = use_runtime_lighting
	if fill_light != null:
		fill_light.visible = use_runtime_lighting
	if rim_light != null:
		rim_light.visible = use_runtime_lighting


func _attach_scene_environment_shapes(level: Dictionary) -> void:
	if not bool(level.get("include_scene_environment_shapes", false)):
		return
	var override_scene_path: String = str(level.get("scene_override_path", ""))
	if override_scene_path.is_empty():
		return

	var packed_scene: PackedScene = load(override_scene_path) as PackedScene
	if packed_scene == null:
		return
	var scene_instance: Node = packed_scene.instantiate()
	if scene_instance == null:
		return

	var environment_root_path: String = str(level.get("scene_environment_root_path", "EnvironmentShapes"))
	var env_root: Node = scene_instance.get_node_or_null(NodePath(environment_root_path))
	if env_root == null:
		scene_instance.free()
		return

	_move_scene_children(env_root.get_node_or_null("Geometry"), geometry_root, scene_instance)
	_move_scene_children(env_root.get_node_or_null("Backdrop"), backdrop_root, scene_instance)
	_move_scene_children(env_root.get_node_or_null("Guide"), guide_root, scene_instance)
	_move_scene_children(env_root.get_node_or_null("SourceVisuals"), source_group, scene_instance)
	_move_scene_children(env_root.get_node_or_null("TargetVisuals"), target_group, scene_instance)

	scene_instance.free()


func _move_scene_children(from_root: Node, to_root: Node, scene_root: Node) -> void:
	if from_root == null or to_root == null:
		return
	var children: Array = from_root.get_children()
	for child in children:
		if child is Node3D:
			var node3d_child: Node3D = child as Node3D
			var scene_space_transform: Transform3D = _transform_relative_to_ancestor(node3d_child, scene_root)
			from_root.remove_child(child)
			child.owner = null
			to_root.add_child(child)
			if to_root is Node3D:
				var to_root_3d: Node3D = to_root as Node3D
				node3d_child.transform = to_root_3d.global_transform.affine_inverse() * scene_space_transform
			else:
				node3d_child.transform = scene_space_transform
		else:
			from_root.remove_child(child)
			child.owner = null
			to_root.add_child(child)


func _attach_scene_collision_nodes(level: Dictionary, enabled_key: String, root_path_key: String, solid_kind: String) -> bool:
	if not bool(level.get(enabled_key, false)):
		return false
	var override_scene_path: String = str(level.get("scene_override_path", ""))
	if override_scene_path.is_empty():
		return false

	var packed_scene: PackedScene = load(override_scene_path) as PackedScene
	if packed_scene == null:
		return false
	var scene_instance: Node = packed_scene.instantiate()
	if scene_instance == null:
		return false

	var root_path_string: String = str(level.get(root_path_key, ""))
	var source_root: Node = scene_instance.get_node_or_null(NodePath(root_path_string))
	if source_root == null:
		scene_instance.free()
		return false

	var moved_any: bool = false
	var source_children: Array = source_root.get_children()
	for child in source_children:
		if child is Node3D:
			var node3d_child: Node3D = child as Node3D
			var scene_space_transform: Transform3D = _transform_relative_to_ancestor(node3d_child, scene_instance)
			source_root.remove_child(child)
			child.owner = null
			geometry_root.add_child(child)
			node3d_child.transform = geometry_root.global_transform.affine_inverse() * scene_space_transform
		else:
			source_root.remove_child(child)
			child.owner = null
			geometry_root.add_child(child)
		_register_solid_from_node(child, solid_kind)
		moved_any = true

	scene_instance.free()
	return moved_any


func _transform_relative_to_ancestor(node3d: Node3D, ancestor: Node) -> Transform3D:
	var result: Transform3D = node3d.transform
	var current_parent: Node = node3d.get_parent()
	while current_parent != null and current_parent != ancestor:
		if current_parent is Node3D:
			result = (current_parent as Node3D).transform * result
		current_parent = current_parent.get_parent()
	return result


func _register_solid_from_node(root_node: Node, solid_kind: String) -> void:
	if root_node == null:
		return
	var collider_nodes: Array = root_node.find_children("*", "CollisionShape3D", true, false)
	for collider_variant in collider_nodes:
		var collider: CollisionShape3D = collider_variant as CollisionShape3D
		if collider == null:
			continue
		var box_shape: BoxShape3D = collider.shape as BoxShape3D
		if box_shape == null:
			continue
		var scale_value: Vector3 = collider.global_transform.basis.get_scale()
		var scaled_size: Vector3 = Vector3(
			absf(box_shape.size.x * scale_value.x),
			absf(box_shape.size.y * scale_value.y),
			absf(box_shape.size.z * scale_value.z)
		)
		var center: Vector3 = collider.global_transform.origin
		var box: AABB = AABB(center - scaled_size * 0.5, scaled_size)
		solids.append({"box": box, "kind": solid_kind})


func _clear_world_geometry() -> void:
	for child in backdrop_root.get_children():
		child.queue_free()
	for child in geometry_root.get_children():
		child.queue_free()
	for child in guide_root.get_children():
		child.queue_free()
	for child in source_group.get_children():
		child.queue_free()
	for child in target_group.get_children():
		child.queue_free()
	solids.clear()
	reflector_runtime.clear()


func _build_city_backdrop() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 7000 + active_level_index * 971

	var min_x: float = world_bounds.position.x
	var max_x: float = world_bounds.end.x
	var min_z: float = world_bounds.position.z
	var max_z: float = world_bounds.end.z

	for index in range(11):
		var side_pick: float = rng.randf()
		var x: float = 0.0
		var z: float = 0.0
		if side_pick < 0.25:
			x = min_x - rng.randf_range(3.0, 10.0)
			z = rng.randf_range(min_z - 20.0, max_z + 20.0)
		elif side_pick < 0.5:
			x = max_x + rng.randf_range(3.0, 10.0)
			z = rng.randf_range(min_z - 20.0, max_z + 20.0)
		elif side_pick < 0.75:
			x = rng.randf_range(min_x - 22.0, max_x + 22.0)
			z = min_z - rng.randf_range(3.0, 12.0)
		else:
			x = rng.randf_range(min_x - 22.0, max_x + 22.0)
			z = max_z + rng.randf_range(3.0, 12.0)

		var width: float = rng.randf_range(3.6, 8.4)
		var depth: float = rng.randf_range(3.6, 8.8)
		var height: float = rng.randf_range(14.0, 42.0)
		var center: Vector3 = Vector3(x, height * 0.5 - 0.4, z)
		var rubble_color: Color = Color(0.0863, 0.0941, 0.1098, 1.0).lerp(Color(0.1647, 0.1922, 0.2196, 1.0), rng.randf())
		_add_ruin_block(center, Vector3(width, height, depth), rubble_color, rng.randf_range(-14.0, 14.0))

	for trench_index in range(2):
		var lane_x: float = rng.randf_range(min_x + 3.0, max_x - 3.0)
		var lane_z: float = rng.randf_range(min_z + 4.0, max_z - 4.0)
		var lane_len: float = rng.randf_range(22.0, 48.0)
		var lane: MeshInstance3D = MeshInstance3D.new()
		var lane_mesh: BoxMesh = BoxMesh.new()
		lane_mesh.size = Vector3(0.22, 0.025, lane_len)
		lane.mesh = lane_mesh
		lane.position = Vector3(lane_x, 0.02, lane_z)
		lane.rotation.y = rng.randf_range(-PI, PI)
		lane.material_override = _make_material(Color(0.1647, 0.1922, 0.2196, 0.26), Color(0.2902, 0.2627, 0.3765, 1.0), 0.03)
		backdrop_root.add_child(lane)


func _add_ruin_block(center: Vector3, size: Vector3, color: Color, yaw_degrees: float) -> void:
	var block: MeshInstance3D = MeshInstance3D.new()
	var block_mesh: BoxMesh = BoxMesh.new()
	block_mesh.size = size
	block.mesh = block_mesh
	block.position = center
	block.rotation_degrees.y = yaw_degrees
	block.material_override = _make_material(color, Color(0.0, 0.0, 0.0, 1.0), 0.0)
	backdrop_root.add_child(block)


func _build_platforms(platforms: Array) -> void:
	for platform in platforms:
		var center: Vector3 = platform["center"] as Vector3
		var size: Vector3 = platform["size"] as Vector3
		var body: StaticBody3D = StaticBody3D.new()
		body.position = center
		geometry_root.add_child(body)

		var shape: BoxShape3D = BoxShape3D.new()
		shape.size = size
		var collider: CollisionShape3D = CollisionShape3D.new()
		collider.shape = shape
		body.add_child(collider)

		var base_mesh: MeshInstance3D = MeshInstance3D.new()
		var base_box: BoxMesh = BoxMesh.new()
		base_box.size = size
		base_mesh.mesh = base_box
		base_mesh.material_override = graphics_kit.copy_material(graphics_kit.M_BASE_METAL_DARK)
		body.add_child(base_mesh)

		var trim_mesh: MeshInstance3D = MeshInstance3D.new()
		var trim_box: BoxMesh = BoxMesh.new()
		trim_box.size = Vector3(size.x * 0.94, maxf(0.04, size.y * 0.18), size.z * 0.94)
		trim_mesh.mesh = trim_box
		trim_mesh.position = Vector3(0.0, size.y * 0.42, 0.0)
		trim_mesh.material_override = graphics_kit.copy_material(graphics_kit.M_BASE_PANEL)
		body.add_child(trim_mesh)

		var seam: MeshInstance3D = MeshInstance3D.new()
		var seam_box: BoxMesh = BoxMesh.new()
		seam_box.size = Vector3(size.x * 0.92, 0.02, 0.04)
		seam.mesh = seam_box
		seam.position = Vector3(0.0, size.y * 0.5 + 0.01, 0.0)
		seam.material_override = graphics_kit.copy_material(graphics_kit.M_BASE_PANEL)
		body.add_child(seam)

		var edge_material: Material = graphics_kit.copy_material(graphics_kit.M_BASE_PANEL)
		var edge_x: BoxMesh = BoxMesh.new()
		edge_x.size = Vector3(size.x * 0.94, 0.03, 0.06)
		var edge_z: BoxMesh = BoxMesh.new()
		edge_z.size = Vector3(0.06, 0.03, size.z * 0.94)

		var edge_front: MeshInstance3D = MeshInstance3D.new()
		edge_front.mesh = edge_x
		edge_front.position = Vector3(0.0, size.y * 0.5 + 0.02, size.z * 0.47)
		edge_front.material_override = edge_material
		body.add_child(edge_front)

		var edge_back: MeshInstance3D = MeshInstance3D.new()
		edge_back.mesh = edge_x
		edge_back.position = Vector3(0.0, size.y * 0.5 + 0.02, -size.z * 0.47)
		edge_back.material_override = edge_material.duplicate(true)
		body.add_child(edge_back)

		var edge_left: MeshInstance3D = MeshInstance3D.new()
		edge_left.mesh = edge_z
		edge_left.position = Vector3(-size.x * 0.47, size.y * 0.5 + 0.02, 0.0)
		edge_left.material_override = edge_material.duplicate(true)
		body.add_child(edge_left)

		var edge_right: MeshInstance3D = MeshInstance3D.new()
		edge_right.mesh = edge_z
		edge_right.position = Vector3(size.x * 0.47, size.y * 0.5 + 0.02, 0.0)
		edge_right.material_override = edge_material.duplicate(true)
		body.add_child(edge_right)

		var box: AABB = AABB(center - size * 0.5, size)
		solids.append({"box": box, "kind": "platform"})
		_add_platform_support_tower(center, size)


func _add_platform_support_tower(platform_center: Vector3, platform_size: Vector3) -> void:
	if not platform_support_towers_enabled:
		return
	if platform_size.x > 20.0 and platform_size.z > 20.0:
		return

	var platform_bottom: float = platform_center.y - platform_size.y * 0.5
	if platform_bottom <= platform_support_ground_y + 0.08:
		return

	var support_height: float = platform_bottom - platform_support_ground_y
	if support_height < 1.15:
		return

	var support_size: Vector3 = Vector3(
		clampf(platform_size.x * 0.42, 1.8, 3.4),
		support_height,
		clampf(platform_size.z * 0.42, 1.8, 3.4)
	)
	var support_center: Vector3 = Vector3(platform_center.x, platform_support_ground_y + support_height * 0.5, platform_center.z)

	var support_body: StaticBody3D = StaticBody3D.new()
	support_body.position = support_center
	geometry_root.add_child(support_body)

	var support_shape: BoxShape3D = BoxShape3D.new()
	support_shape.size = support_size
	var support_collision: CollisionShape3D = CollisionShape3D.new()
	support_collision.shape = support_shape
	support_body.add_child(support_collision)

	var support_mesh: MeshInstance3D = MeshInstance3D.new()
	var support_box: BoxMesh = BoxMesh.new()
	support_box.size = support_size
	support_mesh.mesh = support_box
	support_mesh.material_override = graphics_kit.copy_material(graphics_kit.M_BASE_METAL_DARK)
	support_body.add_child(support_mesh)

	var core_mesh: MeshInstance3D = MeshInstance3D.new()
	var core_box: BoxMesh = BoxMesh.new()
	core_box.size = Vector3(support_size.x * 0.84, support_size.y * 0.96, support_size.z * 0.84)
	core_mesh.mesh = core_box
	core_mesh.material_override = graphics_kit.copy_material(graphics_kit.M_BASE_PANEL)
	support_body.add_child(core_mesh)

	var rail_depth: float = support_size.z * 0.78
	var rail_width: float = 0.08
	var rail_height: float = maxf(0.12, support_size.y * 0.92)
	var support_sides: Array[float] = [-1.0, 1.0]
	for side in support_sides:
		var rail_module: Node3D = graphics_kit.instantiate_module(graphics_kit.RAIL_MODULE_SCENE) as Node3D
		if rail_module != null and rail_module.has_method("configure"):
			rail_module.call("configure", Vector3(rail_width, rail_height, rail_depth), graphics_kit.copy_material(graphics_kit.M_BASE_PANEL))
			rail_module.position = Vector3(side * (support_size.x * 0.46), 0.0, 0.0)
			support_body.add_child(rail_module)

	var support_box_aabb: AABB = AABB(support_center - support_size * 0.5, support_size)
	solids.append({"box": support_box_aabb, "kind": "platform"})


func _build_world_boundaries() -> void:
	var min_x: float = world_bounds.position.x
	var max_x: float = world_bounds.end.x
	var min_z: float = world_bounds.position.z
	var max_z: float = world_bounds.end.z
	var thickness: float = 1.6
	var collision_height: float = 7.5
	var wall_y: float = maxf(2.0, source_floor_center.y + collision_height * 0.5 - 0.25)
	var span_x: float = maxf(2.0, max_x - min_x)
	var span_z: float = maxf(2.0, max_z - min_z)

	_add_boundary_wall(Vector3(min_x - thickness * 0.5, wall_y, (min_z + max_z) * 0.5), Vector3(thickness, collision_height, span_z + thickness))
	_add_boundary_wall(Vector3(max_x + thickness * 0.5, wall_y, (min_z + max_z) * 0.5), Vector3(thickness, collision_height, span_z + thickness))
	_add_boundary_wall(Vector3((min_x + max_x) * 0.5, wall_y, min_z - thickness * 0.5), Vector3(span_x + thickness, collision_height, thickness))
	_add_boundary_wall(Vector3((min_x + max_x) * 0.5, wall_y, max_z + thickness * 0.5), Vector3(span_x + thickness, collision_height, thickness))


func _add_boundary_wall(center: Vector3, size: Vector3) -> void:
	var body: StaticBody3D = StaticBody3D.new()
	body.position = center
	geometry_root.add_child(body)

	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = size
	var collider: CollisionShape3D = CollisionShape3D.new()
	collider.shape = shape
	body.add_child(collider)

	var wall_mesh: MeshInstance3D = MeshInstance3D.new()
	var wall_box: BoxMesh = BoxMesh.new()
	wall_box.size = size
	wall_mesh.mesh = wall_box
	wall_mesh.material_override = graphics_kit.copy_material(graphics_kit.M_BASE_METAL_DARK)
	body.add_child(wall_mesh)

	var rail: MeshInstance3D = MeshInstance3D.new()
	var rail_box: BoxMesh = BoxMesh.new()
	rail_box.size = Vector3(size.x, maxf(0.18, size.y * 0.1), size.z)
	rail.mesh = rail_box
	rail.position = Vector3(0.0, -size.y * 0.45, 0.0)
	rail.material_override = graphics_kit.copy_material(graphics_kit.M_BASE_PANEL)
	body.add_child(rail)


func _build_absorbers(absorbers: Array) -> void:
	for absorber in absorbers:
		var center: Vector3 = absorber["center"] as Vector3
		var size: Vector3 = absorber["size"] as Vector3
		var body: StaticBody3D = StaticBody3D.new()
		body.position = center
		geometry_root.add_child(body)

		var shape: BoxShape3D = BoxShape3D.new()
		shape.size = size
		var collider: CollisionShape3D = CollisionShape3D.new()
		collider.shape = shape
		body.add_child(collider)

		var blocker_mesh: MeshInstance3D = MeshInstance3D.new()
		var blocker_box: BoxMesh = BoxMesh.new()
		blocker_box.size = size
		blocker_mesh.mesh = blocker_box
		blocker_mesh.material_override = graphics_kit.copy_material(graphics_kit.M_NEON_MAGENTA)
		body.add_child(blocker_mesh)

		var box: AABB = AABB(center - size * 0.5, size)
		solids.append({"box": box, "kind": "absorber"})


func _build_reflectors(reflectors: Array) -> void:
	for reflector in reflectors:
		var center: Vector3 = reflector["center"] as Vector3
		var from_point: Vector3 = reflector["from"] as Vector3
		var to_point: Vector3 = reflector["to"] as Vector3
		var width: float = float(reflector.get("width", 3.8))
		var height: float = float(reflector.get("height", 3.8))
		var label: String = str(reflector.get("label", "main"))

		var incoming: Vector3 = (center - from_point).normalized()
		var outgoing: Vector3 = (to_point - center).normalized()
		var normal: Vector3 = (incoming - outgoing).normalized()
		if normal.length() <= 0.001:
			normal = Vector3.FORWARD
		var up_hint: Vector3 = Vector3.UP if absf(normal.dot(Vector3.UP)) < 0.92 else Vector3.RIGHT
		var right: Vector3 = up_hint.cross(normal).normalized()
		var up: Vector3 = normal.cross(right).normalized()

		var plane_holder: Node3D = Node3D.new()
		plane_holder.position = center
		geometry_root.add_child(plane_holder)
		plane_holder.look_at_from_position(center, center + normal, Vector3.UP)
		_add_reflector_direction_cues(center, incoming, outgoing, width, height, label == "optional")

		reflector_runtime.append(
			{
				"center": center,
				"from": from_point,
				"to": to_point,
				"width": width,
				"height": height,
				"normal": normal,
				"right": right,
				"up": up,
				"output_direction": outgoing,
				"label": label,
				"node": plane_holder
			}
		)


func _build_channels(channels: Array) -> void:
	for channel in channels:
		var from_point: Vector3 = channel["from"] as Vector3
		var to_point: Vector3 = channel["to"] as Vector3
		var optional: bool = str(channel.get("label", "main")) == "optional"
		_add_channel_segment(from_point, to_point, optional)


func _build_appointments(appointments: Array) -> void:
	for appointment in appointments:
		var center: Vector3 = appointment["center"] as Vector3
		var pad: MeshInstance3D = MeshInstance3D.new()
		var pad_mesh: CylinderMesh = CylinderMesh.new()
		pad_mesh.top_radius = 0.74
		pad_mesh.bottom_radius = 0.74
		pad_mesh.height = 0.06
		pad.mesh = pad_mesh
		pad.position = Vector3(center.x, 0.03, center.z)
		pad.material_override = _make_material(Color(0.2941, 0.3294, 0.3647, 1.0), Color(0.0, 0.0, 0.0, 1.0), 0.0)
		guide_root.add_child(pad)

		var ring: MeshInstance3D = MeshInstance3D.new()
		var torus: TorusMesh = TorusMesh.new()
		torus.inner_radius = 0.82
		torus.outer_radius = 1.08
		ring.mesh = torus
		ring.position = Vector3(center.x, 0.06, center.z)
		ring.rotation_degrees = Vector3(90.0, 0.0, 0.0)
		ring.material_override = _make_material(Color(0.8392, 0.6431, 0.3529, 1.0), Color(0.8392, 0.6431, 0.3529, 1.0), 0.34)
		guide_root.add_child(ring)

		var slash: MeshInstance3D = MeshInstance3D.new()
		var slash_mesh: BoxMesh = BoxMesh.new()
		slash_mesh.size = Vector3(0.1, 0.03, 1.95)
		slash.mesh = slash_mesh
		slash.position = Vector3(center.x, 0.07, center.z)
		slash.rotation_degrees.y = 34.0
		slash.material_override = _make_material(Color(0.8392, 0.6431, 0.3529, 1.0), Color(0.8392, 0.6431, 0.3529, 1.0), 0.28)
		guide_root.add_child(slash)


func _build_source_zone() -> void:
	var half_x: float = fire_zone_size.x * 0.5
	var half_z: float = fire_zone_size.y * 0.5
	var line_height: float = 0.045
	var line_thickness: float = 0.08
	var y_pos: float = 0.03

	_add_start_zone_line(
		source_floor_center + Vector3(0.0, y_pos, -half_z),
		Vector3(fire_zone_size.x, line_height, line_thickness)
	)
	_add_start_zone_line(
		source_floor_center + Vector3(0.0, y_pos, half_z),
		Vector3(fire_zone_size.x, line_height, line_thickness)
	)
	_add_start_zone_line(
		source_floor_center + Vector3(-half_x, y_pos, 0.0),
		Vector3(line_thickness, line_height, fire_zone_size.y)
	)
	_add_start_zone_line(
		source_floor_center + Vector3(half_x, y_pos, 0.0),
		Vector3(line_thickness, line_height, fire_zone_size.y)
	)

	# Small center notch for orientation without painting a second floor plane.
	_add_start_zone_line(
		source_floor_center + Vector3(0.0, y_pos, 0.0),
		Vector3(minf(3.2, fire_zone_size.x * 0.22), line_height, 0.06)
	)


func _add_start_zone_line(center: Vector3, size: Vector3) -> void:
	var line_mesh: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = size
	line_mesh.mesh = box
	line_mesh.position = center
	line_mesh.material_override = graphics_kit.copy_material(graphics_kit.M_NEON_CYAN)
	source_group.add_child(line_mesh)


func _build_target_zone(visual_radius: float) -> void:
	var plinth: MeshInstance3D = MeshInstance3D.new()
	var plinth_mesh: CylinderMesh = CylinderMesh.new()
	plinth_mesh.top_radius = target_radius * 0.58
	plinth_mesh.bottom_radius = target_radius * 0.72
	plinth_mesh.height = 1.0
	plinth.mesh = plinth_mesh
	plinth.position = target_position + Vector3(0.0, -0.3, 0.0)
	plinth.material_override = graphics_kit.copy_material(graphics_kit.M_BASE_METAL_DARK)
	target_group.add_child(plinth)

	var receptor_glow: Node3D = graphics_kit.instantiate_module(graphics_kit.FX_RECEPTOR_GLOW_SCENE) as Node3D
	receptor_glow.position = target_position
	var receptor_scale: float = maxf(0.6, visual_radius / 0.8)
	receptor_glow.scale = Vector3.ONE * receptor_scale
	target_group.add_child(receptor_glow)

	var far_light: OmniLight3D = OmniLight3D.new()
	far_light.position = target_position + Vector3(0.0, 6.0, 0.0)
	far_light.light_color = Color(0.9373, 1.0, 0.9725, 1.0)
	far_light.light_energy = 2.35
	far_light.omni_range = 64.0
	target_group.add_child(far_light)


func _add_reflector_direction_cues(center: Vector3, incoming: Vector3, outgoing: Vector3, width: float, height: float, optional: bool) -> void:
	var in_dir: Vector3 = incoming.normalized()
	var out_dir: Vector3 = outgoing.normalized()
	var cue_y: float = center.y - height * 0.47
	var cue_origin: Vector3 = Vector3(center.x, cue_y, center.z)
	var travel_len: float = clampf(width * 0.46, 1.1, 2.2)

	var incoming_color: Color = Color(0.5608, 1.0, 0.8196, 1.0) if not optional else Color(0.8392, 0.6431, 0.3529, 1.0)
	var outgoing_color: Color = Color(0.9373, 1.0, 0.9725, 1.0) if not optional else Color(0.8392, 0.6431, 0.3529, 1.0)
	var incoming_start: Vector3 = cue_origin - in_dir * travel_len
	var incoming_end: Vector3 = cue_origin - in_dir * 0.26
	var outgoing_start: Vector3 = cue_origin + out_dir * 0.2
	var outgoing_end: Vector3 = cue_origin + out_dir * travel_len

	_add_world_line(incoming_start, incoming_end, 0.08, incoming_color, 0.55 if not optional else 0.24)
	_add_world_line(outgoing_start, outgoing_end, 0.1 if not optional else 0.08, outgoing_color, 0.88 if not optional else 0.38)

	var flat_out: Vector3 = Vector3(out_dir.x, 0.0, out_dir.z).normalized()
	if flat_out.length_squared() < 0.01:
		flat_out = out_dir
	var wing_right: Vector3 = flat_out.cross(Vector3.UP).normalized()
	if wing_right.length_squared() < 0.01:
		wing_right = Vector3.RIGHT
	var wing_len: float = 0.58 if not optional else 0.44
	var wing_base: Vector3 = outgoing_end
	var wing_a: Vector3 = wing_base + (-flat_out + wing_right * 0.62).normalized() * wing_len
	var wing_b: Vector3 = wing_base + (-flat_out - wing_right * 0.62).normalized() * wing_len
	_add_world_line(wing_base, wing_a, 0.08, outgoing_color, 0.9 if not optional else 0.4)
	_add_world_line(wing_base, wing_b, 0.08, outgoing_color, 0.9 if not optional else 0.4)


func _add_world_line(from_point: Vector3, to_point: Vector3, thickness: float, color: Color, emission: float) -> void:
	var delta: Vector3 = to_point - from_point
	var length: float = delta.length()
	if length < 0.05:
		return
	var line: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = Vector3(thickness, thickness, length)
	line.mesh = mesh
	line.position = from_point.lerp(to_point, 0.5)
	line.look_at_from_position(line.position, to_point, Vector3.UP)
	line.material_override = _make_material(color, color, emission, 0.12, 0.1)
	guide_root.add_child(line)


func _build_level_specific_art(level: Dictionary) -> void:
	var title: String = str(level.get("title", ""))
	if title == "Level 2: Chain Angle":
		_build_chain_angle_art(level)
	elif title == "Lab: 3-Course Platforming":
		_build_three_course_labels()
		_build_three_course_city_art(level)


func _build_chain_angle_art(level: Dictionary) -> void:
	var source: Vector3 = level.get("source", source_position) as Vector3
	var target: Vector3 = level.get("target", target_position) as Vector3
	var trim_height: float = 0.22
	var trim_color: Color = Color(0.5608, 1.0, 0.8196, 1.0)
	_add_world_line(Vector3(source.x, trim_height, source.z - 2.8), Vector3(source.x, trim_height, source.z - 7.2), 0.1, trim_color, 0.24)
	_add_world_line(Vector3(-4.5, trim_height, 0.5), Vector3(4.8, trim_height, -2.2), 0.09, trim_color, 0.22)
	_add_world_line(Vector3(4.8, trim_height, -2.2), Vector3(target.x, trim_height, target.z), 0.09, Color(0.8392, 0.6431, 0.3529, 1.0), 0.2)


func _build_three_course_labels() -> void:
	_add_course_label("LEFT COURSE", Vector3(-10.8, 2.55, 10.4), Color(0.5608, 1.0, 0.8196, 1.0))
	_add_course_label("CENTER COURSE", Vector3(0.0, 2.65, 10.4), Color(0.8392, 0.6431, 0.3529, 1.0))
	_add_course_label("RIGHT COURSE", Vector3(10.8, 2.55, 10.4), Color(0.2941, 0.3294, 0.3647, 1.0))


func _add_course_label(text: String, world_pos: Vector3, tint: Color) -> void:
	var sign_root: Node3D = Node3D.new()
	sign_root.position = world_pos
	guide_root.add_child(sign_root)

	var post: MeshInstance3D = MeshInstance3D.new()
	var post_mesh: BoxMesh = BoxMesh.new()
	post_mesh.size = Vector3(0.12, 1.2, 0.12)
	post.mesh = post_mesh
	post.position = Vector3(0.0, -0.62, 0.0)
	post.material_override = graphics_kit.copy_material(graphics_kit.M_BASE_PANEL)
	sign_root.add_child(post)

	var plate: MeshInstance3D = MeshInstance3D.new()
	var plate_mesh: BoxMesh = BoxMesh.new()
	plate_mesh.size = Vector3(3.6, 0.56, 0.08)
	plate.mesh = plate_mesh
	plate.position = Vector3(0.0, 0.0, 0.0)
	plate.material_override = _make_material(Color(0.08, 0.1, 0.14, 0.94), tint, 0.12, 0.25, 0.05)
	sign_root.add_child(plate)

	var label: Label3D = Label3D.new()
	label.text = text
	label.position = Vector3(0.0, 0.0, 0.07)
	label.font_size = 48
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = Color(0.95, 0.98, 1.0, 1.0)
	label.outline_size = 6
	label.outline_modulate = Color(0.0, 0.0, 0.0, 0.9)
	sign_root.add_child(label)


func _build_three_course_city_art(_level: Dictionary) -> void:
	var lane_colors: Array[Color] = [
		Color(0.5608, 1.0, 0.8196, 1.0),
		Color(0.8392, 0.6431, 0.3529, 1.0),
		Color(0.9373, 1.0, 0.9725, 1.0)
	]
	var lane_x: Array[float] = [-11.2, 0.0, 11.2]
	for lane_idx in range(lane_x.size()):
		var x: float = lane_x[lane_idx]
		var lane_color: Color = lane_colors[lane_idx]
		_add_world_line(
			Vector3(x, 0.09, 10.6),
			Vector3(x, 0.09, -121.0),
			0.1,
			lane_color,
			0.24
		)
		_add_world_line(
			Vector3(x, 0.03, 10.6),
			Vector3(x, 0.03, -121.0),
			0.05,
			lane_color.lerp(Color(0.1647, 0.1922, 0.2196, 1.0), 0.6),
			0.08
		)

	var left_tower_color: Color = Color(0.0863, 0.0941, 0.1098, 1.0)
	var right_tower_color: Color = Color(0.1647, 0.1922, 0.2196, 1.0)
	for ring_idx in range(6):
		var z: float = 6.0 - float(ring_idx) * 23.0
		var tall_height: float = 6.0 + float(ring_idx % 3) * 2.2
		_add_ruin_block(Vector3(-18.8, tall_height * 0.5 - 1.0, z), Vector3(3.2, tall_height, 3.2), left_tower_color, -4.0 + ring_idx * 3.0)
		_add_ruin_block(Vector3(18.8, (tall_height + 1.6) * 0.5 - 1.0, z - 3.2), Vector3(3.4, tall_height + 1.6, 3.0), right_tower_color, 6.0 - ring_idx * 2.8)

		var bridge_y: float = 1.4 + float(ring_idx % 2) * 0.35
		var bridge: MeshInstance3D = MeshInstance3D.new()
		var bridge_mesh: BoxMesh = BoxMesh.new()
		bridge_mesh.size = Vector3(24.0, 0.16, 0.42)
		bridge.mesh = bridge_mesh
		bridge.position = Vector3(0.0, bridge_y, z + 2.2)
		bridge.material_override = _make_material(Color(0.0863, 0.0941, 0.1098, 0.92), Color(0.2902, 0.2627, 0.3765, 1.0), 0.05, 0.3, 0.06)
		backdrop_root.add_child(bridge)

	var target_spire: MeshInstance3D = MeshInstance3D.new()
	var target_spire_mesh: CylinderMesh = CylinderMesh.new()
	target_spire_mesh.top_radius = 2.4
	target_spire_mesh.bottom_radius = 3.3
	target_spire_mesh.height = 9.6
	target_spire.mesh = target_spire_mesh
	target_spire.position = Vector3(0.0, 3.8, -120.0)
	target_spire.material_override = _make_material(Color(0.0863, 0.0941, 0.1098, 1.0), Color(0.2902, 0.2627, 0.3765, 1.0), 0.08, 0.28, 0.1)
	backdrop_root.add_child(target_spire)

	var target_ring: MeshInstance3D = MeshInstance3D.new()
	var ring_mesh: TorusMesh = TorusMesh.new()
	ring_mesh.inner_radius = 2.8
	ring_mesh.outer_radius = 3.2
	target_ring.mesh = ring_mesh
	target_ring.position = Vector3(0.0, 8.8, -120.0)
	target_ring.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	target_ring.material_override = _make_material(Color(0.5608, 1.0, 0.8196, 1.0), Color(0.9373, 1.0, 0.9725, 1.0), 0.28, 0.18, 0.02)
	backdrop_root.add_child(target_ring)


func _pulse_action() -> void:
	if pulse_active:
		_try_intercept()
	else:
		_shoot_pulse()


func _shoot_pulse() -> void:
	if not _is_player_in_fire_zone():
		prompt_label.text = "Return to source zone."
		return
	var level: Dictionary = level_specs[active_level_index]
	pulse_active = true
	pulse_position = player.get_eye_position() + player.get_horizontal_aim_direction() * 0.72
	pulse_position.y = source_position.y
	pulse_direction = player.get_horizontal_aim_direction()
	pulse_age = 0.0
	pulse_ttl = maxf(float(level.get("pulse_ttl", 8.0)), 60.0)
	pulse_max_stability = maxf(1.0, pulse_ttl)
	pulse_stability = pulse_max_stability
	pulse_base_speed = float(level.get("pulse_speed", 10.0)) * base_pulse_speed_multiplier
	pulse_speed = pulse_base_speed
	pulse_bounces = 0
	var player_progress: float = _pressure_progress_at_position(player.global_position)
	pressure_progress = minf(player_progress - 6.8, pressure_progress)
	pressure_catch_grace_timer = 0.0
	pulse_trail_history.clear()
	pulse_trail_history.append(pulse_position)
	audio_bus.play_launch(pulse_position)
	_update_pulse_visuals()


func _try_intercept() -> void:
	if not pulse_active:
		return
	if intercept_cooldown > 0.0:
		return
	intercept_cooldown = 0.08
	if not player.is_pulse_in_reflect_radius(pulse_position, intercept_radius):
		prompt_label.text = "Missed intercept."
		if metrics != null:
			metrics.mark_reflect(false)
		return

	var aim: Vector3 = player.get_horizontal_aim_direction()
	pulse_direction = aim
	pulse_position = player.get_eye_position() + aim * 1.05
	pulse_position.y = clampf(pulse_position.y, 1.3, 2.3)
	pulse_trail_history.clear()
	pulse_trail_history.append(pulse_position)
	pulse_age = maxf(0.0, pulse_age - 0.35)
	_refresh_pulse_stability(pulse_max_stability * player_reflect_stability_ratio)
	_ramp_pulse_speed(PLAYER_REFLECT_SPEED_RAMP)
	audio_bus.play_reflect_snap(pulse_position)
	if metrics != null:
		metrics.mark_reflect(true)
	_update_pulse_visuals()


func _update_pulse(delta: float) -> void:
	pulse_age += delta
	pulse_stability -= delta
	if pulse_stability <= 0.0:
		_fail_pulse("Collapsed")
		return
	if pulse_age >= pulse_ttl:
		_fail_pulse("Expired")
		return

	intercept_cooldown = maxf(0.0, intercept_cooldown - delta)
	_decay_pulse_speed(delta)

	var remaining: float = delta
	var guard: int = 0
	while remaining > 0.0001 and guard < 6 and pulse_active:
		guard += 1
		var start: Vector3 = pulse_position
		var end: Vector3 = start + pulse_direction * pulse_speed * remaining
		var hit: Dictionary = _find_pulse_collision(start, end)
		if hit.is_empty():
			pulse_position = end
			remaining = 0.0
			break

		var hit_kind: String = str(hit["kind"])
		var hit_t: float = float(hit["t"])
		var hit_point: Vector3 = hit["point"] as Vector3

		if hit_kind == "target":
			pulse_position = hit_point
			_complete_level()
			return

		if hit_kind == "absorb":
			pulse_position = hit_point
			_fail_pulse("Absorbed")
			return

		if hit_kind == "reflector":
			var reflector: Dictionary = hit["reflector"] as Dictionary
			pulse_position = hit_point + (reflector["output_direction"] as Vector3) * 0.08
			pulse_direction = reflector["output_direction"] as Vector3
			pulse_bounces += 1
			_set_relay_checkpoint(hit_point, pulse_direction)
			pulse_stability = pulse_max_stability
			_ramp_pulse_speed(MIRROR_SPEED_RAMP)
			audio_bus.play_mirror_ping(hit_point)
			prompt_label.text = "Relay synced."
			remaining *= maxf(0.0, 1.0 - hit_t)
			continue

		pulse_position = end
		remaining = 0.0

	_update_pulse_visuals()


func _find_pulse_collision(start: Vector3, end: Vector3) -> Dictionary:
	var best: Dictionary = {}
	var target_t: float = _segment_sphere_intersection(start, end, target_position, target_radius)
	if target_t >= 0.0:
		best = {"kind": "target", "t": target_t, "point": start.lerp(end, target_t)}

	for reflector in reflector_runtime:
		var collision: Dictionary = _segment_reflector_intersection(start, end, reflector)
		if collision.is_empty():
			continue
		if best.is_empty() or float(collision["t"]) < float(best["t"]):
			best = collision

	for solid in solids:
		var box: AABB = solid["box"] as AABB
		var absorb_t: float = _segment_aabb_intersection(start, end, box.grow(0.04))
		if absorb_t >= 0.0001 and absorb_t <= 1.0:
			if best.is_empty() or absorb_t < float(best["t"]):
				best = {"kind": "absorb", "t": absorb_t, "point": start.lerp(end, absorb_t)}

	if not world_bounds.has_point(end):
		var bounds_t: float = _segment_aabb_intersection(start, end, world_bounds)
		var clamped_t: float = 1.0 if bounds_t < 0.0 else clampf(bounds_t + 0.02, 0.0, 1.0)
		if best.is_empty() or clamped_t < float(best["t"]):
			best = {"kind": "absorb", "t": clamped_t, "point": start.lerp(end, clamped_t)}

	return best


func _segment_sphere_intersection(start: Vector3, end: Vector3, center: Vector3, radius: float) -> float:
	var delta: Vector3 = end - start
	var m: Vector3 = start - center
	var a: float = delta.dot(delta)
	var b: float = m.dot(delta)
	var c: float = m.dot(m) - radius * radius
	if c <= 0.0:
		return 0.0
	var discriminant: float = b * b - a * c
	if discriminant < 0.0 or a <= 0.000001:
		return -1.0
	var t: float = (-b - sqrt(discriminant)) / a
	return t if t >= 0.0 and t <= 1.0 else -1.0


func _segment_aabb_intersection(start: Vector3, end: Vector3, box: AABB) -> float:
	var direction: Vector3 = end - start
	var t_min: float = 0.0
	var t_max: float = 1.0
	for axis in 3:
		var origin: float = start[axis]
		var velocity_axis: float = direction[axis]
		var min_axis: float = box.position[axis]
		var max_axis: float = box.end[axis]
		if absf(velocity_axis) < 0.000001:
			if origin < min_axis or origin > max_axis:
				return -1.0
			continue
		var inv: float = 1.0 / velocity_axis
		var t1: float = (min_axis - origin) * inv
		var t2: float = (max_axis - origin) * inv
		if t1 > t2:
			var swap_t: float = t1
			t1 = t2
			t2 = swap_t
		t_min = maxf(t_min, t1)
		t_max = minf(t_max, t2)
		if t_min > t_max:
			return -1.0
	return t_min if t_min >= 0.0 and t_min <= 1.0 else -1.0


func _segment_reflector_intersection(start: Vector3, end: Vector3, reflector: Dictionary) -> Dictionary:
	var normal: Vector3 = reflector["normal"] as Vector3
	var center: Vector3 = reflector["center"] as Vector3
	var movement: Vector3 = end - start
	var denom: float = normal.dot(movement)
	if absf(denom) < 0.000001:
		return {}
	var t: float = normal.dot(center - start) / denom
	if t < 0.0001 or t > 1.0:
		return {}
	var point: Vector3 = start.lerp(end, t)
	var local: Vector3 = point - center
	var right: Vector3 = reflector["right"] as Vector3
	var up: Vector3 = reflector["up"] as Vector3
	var x: float = local.dot(right)
	var y: float = local.dot(up)
	var half_width: float = float(reflector["width"]) * 0.5
	var half_height: float = float(reflector["height"]) * 0.5
	if absf(x) > half_width or absf(y) > half_height:
		return {}
	return {"kind": "reflector", "t": t, "point": point, "reflector": reflector}


func _update_pulse_visuals() -> void:
	if not pulse_active:
		_hide_pulse_visuals()
		return

	var speed_ratio: float = _pulse_speed_ratio()
	var stability_ratio: float = clampf(pulse_stability / maxf(0.001, pulse_max_stability), 0.0, 1.0)
	var pulse_color: Color = _pulse_color(speed_ratio)
	pulse_color = pulse_color.lerp(Color(0.6078, 0.302, 0.3451, 1.0), 1.0 - stability_ratio)

	var material: StandardMaterial3D = _make_material(pulse_color, pulse_color, 1.28)
	pulse_mesh.material_override = material
	pulse_shell.material_override = _make_material(pulse_color, pulse_color, 0.55)
	pulse_light.light_color = pulse_color
	pulse_light.light_energy = 1.6 + speed_ratio * 1.8

	pulse_mesh.position = pulse_position
	pulse_shell.position = pulse_position
	pulse_light.position = pulse_position
	pulse_mesh.visible = true
	pulse_shell.visible = true
	pulse_light.visible = true
	pulse_hum.stream_paused = false
	if transmission_activation_light != null:
		transmission_activation_light.position = pulse_position + Vector3(0.0, 0.35, 0.0)
		transmission_activation_light.light_color = pulse_color
		transmission_activation_light.light_energy = 0.28 + speed_ratio * 0.42
	if pulse_beam_particles != null:
		pulse_beam_particles.global_position = pulse_position
		var look_target: Vector3 = pulse_position + (pulse_direction if pulse_direction.length_squared() > 0.001 else Vector3.FORWARD)
		pulse_beam_particles.look_at(look_target, Vector3.UP)
		pulse_beam_particles.amount_ratio = clampf(0.35 + speed_ratio * 0.55, 0.3, 1.0)
		pulse_beam_particles.emitting = true
	if pulse_beam_process != null:
		pulse_beam_process.initial_velocity_min = 0.45 + speed_ratio * 0.75
		pulse_beam_process.initial_velocity_max = 1.25 + speed_ratio * 1.1

	pulse_trail_history.push_front(pulse_position)
	if pulse_trail_history.size() > trail_meshes.size():
		pulse_trail_history.resize(trail_meshes.size())

	for index in range(trail_meshes.size()):
		var trail: MeshInstance3D = trail_meshes[index]
		if index >= pulse_trail_history.size():
			trail.visible = false
			continue
		trail.visible = true
		trail.position = pulse_trail_history[index]
		trail.material_override = _make_material(pulse_color, pulse_color, 0.48)
		var fade: float = 1.0 - float(index + 1) / float(trail_meshes.size() + 1)
		trail.scale = Vector3.ONE * (0.2 + 0.45 * fade)


func _hide_pulse_visuals() -> void:
	pulse_mesh.visible = false
	pulse_shell.visible = false
	pulse_light.visible = false
	pulse_hum.stream_paused = true
	if transmission_activation_light != null:
		transmission_activation_light.light_energy = 0.0
	if pulse_beam_particles != null:
		pulse_beam_particles.emitting = false
	for trail in trail_meshes:
		trail.visible = false


func _deactivate_pulse() -> void:
	pulse_active = false
	pulse_age = 0.0
	pulse_speed = 0.0
	pulse_stability = 0.0
	var level: Dictionary = level_specs[active_level_index]
	pressure_progress = float(level.get("pressure_start_offset", -8.0))
	pressure_speed = float(level.get("pressure_speed", maxf(8.2, float(level.get("pulse_speed", 10.0)) * 0.84)))
	pressure_catch_grace_timer = 0.0
	_update_pressure_beam_visual()
	pulse_trail_history.clear()
	_hide_pulse_visuals()


func _fail_pulse(reason: String) -> void:
	audio_bus.play_fail_drop(pulse_position)
	prompt_label.text = "%s. Back to relay." % reason
	if metrics != null:
		metrics.mark_reset()
	_finalize_metrics_attempt(false, reason)
	_deactivate_pulse()
	_reset_player_to_relay_checkpoint()
	_start_metrics_attempt(level_specs[active_level_index])


func _complete_level() -> void:
	audio_bus.play_complete(target_position)
	_finalize_metrics_attempt(true, "")
	_deactivate_pulse()
	var next_index: int = active_level_index + 1
	if next_index < level_specs.size():
		prompt_label.text = "Receptor linked. Loading next level..."
		var next_timer: SceneTreeTimer = get_tree().create_timer(0.7)
		next_timer.timeout.connect(func() -> void:
			_load_level(next_index)
		)
	else:
		prompt_label.text = "All levels cleared. Cycling back to Level 1..."
		var restart_timer: SceneTreeTimer = get_tree().create_timer(1.0)
		restart_timer.timeout.connect(func() -> void:
			_load_level(0)
		)


func _configure_pressure_beam_for_level(level: Dictionary) -> void:
	var source: Vector3 = level.get("source", source_position) as Vector3
	var target: Vector3 = level.get("target", target_position) as Vector3
	pressure_axis_origin = Vector3(source.x, 0.0, source.z)
	pressure_axis_dir = (Vector3(target.x, 0.0, target.z) - pressure_axis_origin).normalized()
	if pressure_axis_dir.length_squared() < 0.001:
		pressure_axis_dir = Vector3(0.0, 0.0, -1.0)

	pressure_speed = float(level.get("pressure_speed", maxf(8.2, float(level.get("pulse_speed", 10.0)) * 0.84)))
	pressure_max_speed = float(level.get("pressure_max_speed", pressure_speed + 7.5))
	pressure_accel = float(level.get("pressure_accel", 2.2))
	pressure_catch_tolerance = float(level.get("pressure_catch_tolerance", 0.7))
	pressure_progress = float(level.get("pressure_start_offset", -8.0))
	pressure_catch_grace_timer = 0.0
	pressure_beam_enabled = bool(level.get("pressure_beam_enabled", true))
	pressure_width = maxf(22.0, world_bounds.size.x + 8.0)
	pressure_height = clampf(world_bounds.size.y * 0.44, 4.6, 8.2)
	if pressure_beam_mesh != null:
		var mesh: BoxMesh = pressure_beam_mesh.mesh as BoxMesh
		if mesh != null:
			mesh.size = Vector3(pressure_width, pressure_height, 0.28)
	pressure_beam_node.visible = pressure_beam_enabled
	_update_pressure_beam_visual()


func _update_pressure_beam(delta: float) -> void:
	if not pressure_beam_enabled or pressure_beam_node == null:
		return
	if not pulse_active:
		_update_pressure_beam_visual()
		return

	pressure_speed = minf(pressure_max_speed, pressure_speed + pressure_accel * delta)
	pressure_progress += pressure_speed * delta

	var player_progress: float = _pressure_progress_at_position(player.global_position)
	if player_progress + pressure_catch_tolerance < pressure_progress:
		pressure_catch_grace_timer += delta
	else:
		pressure_catch_grace_timer = maxf(0.0, pressure_catch_grace_timer - delta * 2.0)

	if pressure_catch_grace_timer >= PRESSURE_FAIL_GRACE:
		prompt_label.text = "Transmission collapse. Back to relay."
		if metrics != null:
			metrics.mark_reset()
		_finalize_metrics_attempt(false, "pressure_collapse")
		_deactivate_pulse()
		_reset_player_to_relay_checkpoint()
		_start_metrics_attempt(level_specs[active_level_index])
		pressure_catch_grace_timer = 0.0
		return

	_update_pressure_beam_visual()


func _update_pressure_beam_visual() -> void:
	if pressure_beam_node == null:
		return
	pressure_beam_node.visible = pressure_beam_enabled
	if not pressure_beam_enabled:
		return
	var position_on_axis: Vector3 = pressure_axis_origin + pressure_axis_dir * pressure_progress
	pressure_beam_node.position = Vector3(position_on_axis.x, source_floor_center.y + pressure_height * 0.5 - 0.35, position_on_axis.z)
	pressure_beam_node.look_at_from_position(pressure_beam_node.position, pressure_beam_node.position + pressure_axis_dir, Vector3.UP)
	if pressure_beam_light != null:
		var chase_ratio: float = clampf((pressure_speed - 8.0) / maxf(0.001, pressure_max_speed - 8.0), 0.0, 1.0)
		pressure_beam_light.light_energy = 0.36 + chase_ratio * 0.52


func _pressure_progress_at_position(world_pos: Vector3) -> float:
	return pressure_axis_dir.dot(Vector3(world_pos.x, 0.0, world_pos.z) - pressure_axis_origin)


func _generate_procedural_level(jump_to_new_level: bool) -> void:
	var new_level: Dictionary = MIRA_PROCGEN_SCRIPT.build_level(procedural_seed)
	var generated_seed: int = procedural_seed
	procedural_seed += 1

	if procedural_level_index >= 0 and procedural_level_index < level_specs.size():
		level_specs[procedural_level_index] = new_level
	else:
		procedural_level_index = level_specs.size()
		level_specs.append(new_level)

	if jump_to_new_level:
		_load_level(procedural_level_index)
		prompt_label.text = "Procedural seed %d loaded. Press G for next." % generated_seed


func _start_metrics_attempt(level: Dictionary) -> void:
	if metrics == null:
		return
	var target_speed: float = float(level.get("pulse_speed", 10.8))
	var tuning_targets: Dictionary = {
		"target_speed": maxf(8.0, target_speed * 0.92),
		"flow_speed_threshold": maxf(7.5, target_speed * 0.72),
		"beam_risk_gap": 5.0,
		"beam_panic_gap": 2.4,
		"target_panic_ratio": 0.12
	}
	metrics.begin_attempt(str(level.get("title", "Unknown Level")), tuning_targets)


func _finalize_metrics_attempt(completed: bool, reason: String) -> void:
	if metrics == null:
		return
	if completed:
		metrics.end_attempt_with_complete()
	else:
		metrics.end_attempt_with_fail(reason)
	metrics.save_last_report()


func _reset_player_to_start() -> void:
	var level: Dictionary = level_specs[active_level_index]
	var spawn: Vector3 = level["spawn"] as Vector3
	player.reset_to(spawn, level_spawn_yaw, level_spawn_pitch)
	relay_checkpoint_position = spawn
	relay_checkpoint_active = true


func _set_relay_checkpoint(anchor: Vector3, forward: Vector3) -> void:
	var forward_flat: Vector3 = Vector3(forward.x, 0.0, forward.z).normalized()
	if forward_flat.length_squared() < 0.001:
		forward_flat = pressure_axis_dir
	var checkpoint: Vector3 = anchor + forward_flat * 1.9
	checkpoint.y = maxf(source_floor_center.y, 0.0)
	relay_checkpoint_position = checkpoint
	relay_checkpoint_active = true
	if metrics != null:
		metrics.mark_relay_checkpoint()


func _reset_player_to_relay_checkpoint() -> void:
	if not relay_checkpoint_active:
		_reset_player_to_start()
		return
	player.reset_to(relay_checkpoint_position, level_spawn_yaw, level_spawn_pitch)


func _check_player_out_of_bounds() -> bool:
	var pos: Vector3 = player.global_position
	var min_bounds: Vector3 = world_bounds.position
	var max_bounds: Vector3 = world_bounds.end
	var fell_below: bool = pos.y < (min_bounds.y - player_bounds_margin)
	var escaped_sides: bool = pos.x < (min_bounds.x - player_bounds_margin) or pos.x > (max_bounds.x + player_bounds_margin) or pos.z < (min_bounds.z - player_bounds_margin) or pos.z > (max_bounds.z + player_bounds_margin)
	if not fell_below and not escaped_sides:
		return false

	prompt_label.text = "Out of bounds. Resetting."
	if metrics != null:
		metrics.mark_reset()
	_finalize_metrics_attempt(false, "out_of_bounds")
	_deactivate_pulse()
	_reset_player_to_relay_checkpoint()
	_start_metrics_attempt(level_specs[active_level_index])
	return true


func _is_player_in_fire_zone() -> bool:
	var player_pos: Vector3 = player.global_position
	var dx: float = player_pos.x - source_floor_center.x
	var dz: float = player_pos.z - source_floor_center.z
	return absf(dx) <= fire_zone_size.x * 0.5 and absf(dz) <= fire_zone_size.y * 0.5


func _refresh_pulse_stability(amount: float) -> void:
	pulse_stability = minf(pulse_max_stability, maxf(pulse_stability, amount))


func _ramp_pulse_speed(factor: float) -> void:
	pulse_speed = minf(pulse_speed * factor, pulse_base_speed * max_pulse_speed_multiplier)


func _decay_pulse_speed(delta: float) -> void:
	if pulse_speed <= pulse_base_speed or pulse_speed_decay_rate <= 0.0:
		return
	var extra_speed: float = pulse_speed - pulse_base_speed
	var remaining: float = extra_speed * pow(1.0 - pulse_speed_decay_rate, delta)
	pulse_speed = pulse_base_speed + remaining


func _pulse_speed_ratio() -> float:
	var span: float = max_pulse_speed_multiplier - 1.0
	if span <= 0.0:
		return 0.0
	return clampf((pulse_speed / maxf(0.001, pulse_base_speed) - 1.0) / span, 0.0, 1.0)


func _pulse_color(speed_ratio: float) -> Color:
	if speed_ratio < 0.45:
		return Color(0.5608, 1.0, 0.8196, 1.0).lerp(Color(0.9373, 1.0, 0.9725, 1.0), speed_ratio / 0.45)
	if speed_ratio < 0.78:
		return Color(0.9373, 1.0, 0.9725, 1.0).lerp(Color(0.8392, 0.6431, 0.3529, 1.0), (speed_ratio - 0.45) / 0.33)
	return Color(0.8392, 0.6431, 0.3529, 1.0).lerp(Color(0.6078, 0.302, 0.3451, 1.0), (speed_ratio - 0.78) / 0.22)


func _update_pulse_audio() -> void:
	if not pulse_active:
		pulse_hum.stream_paused = true
		return
	var eye: Vector3 = player.get_eye_position()
	var distance: float = pulse_position.distance_to(eye)
	var proximity: float = clampf(1.0 - distance / 46.0, 0.0, 1.0)
	var speed_ratio: float = _pulse_speed_ratio()
	var stability_ratio: float = clampf(pulse_stability / maxf(0.001, pulse_max_stability), 0.0, 1.0)
	pulse_hum.global_position = pulse_position
	pulse_hum.pitch_scale = 0.82 + speed_ratio * 0.95
	pulse_hum.volume_db = linear_to_db(clampf(0.015 + proximity * 0.18 * stability_ratio, 0.001, 1.0))


func _update_ui() -> void:
	var level: Dictionary = level_specs[active_level_index]
	var speed_mult: float = pulse_speed / maxf(0.001, pulse_base_speed)
	var pulse_state_text: String = "LIVE" if pulse_active else "IDLE"
	var reflect_status: String = "READY" if pulse_active and player.is_pulse_in_reflect_radius(pulse_position, intercept_radius) else "MOVE"
	var pressure_gap: float = _pressure_progress_at_position(player.global_position) - pressure_progress
	hud_label.text = "%s  |  Pulse %s  |  Stability %.1f  |  Speed x%.2f  |  Reflect %s" % [
		level["title"],
		pulse_state_text,
		pulse_stability,
		speed_mult,
		reflect_status
	]
	if pressure_beam_enabled:
		hud_label.text += "  |  Beam %+0.1fm" % pressure_gap
	if not pulse_active:
		var idle_prompt: String = "LMB/X fire from source. LMB/X reflect in ring. R reset. N/P level. G new proc level."
		prompt_label.text = idle_prompt if _is_player_in_fire_zone() else "Return to source zone to fire."


func _capture_metrics_sample(delta: float) -> void:
	if metrics == null:
		return
	var player_events: Dictionary = player.drain_metrics_events()
	if int(player_events.get("dash", 0)) > 0:
		for dash_idx in range(int(player_events.get("dash", 0))):
			metrics.mark_dash()
	if int(player_events.get("jump", 0)) > 0:
		for jump_idx in range(int(player_events.get("jump", 0))):
			metrics.mark_jump()
	if int(player_events.get("wall_jump", 0)) > 0:
		for wall_jump_idx in range(int(player_events.get("wall_jump", 0))):
			metrics.mark_wall_jump()
	if int(player_events.get("slide_start", 0)) > 0:
		for slide_idx in range(int(player_events.get("slide_start", 0))):
			metrics.mark_slide_start()

	var planar_speed: float = Vector2(player.velocity.x, player.velocity.z).length()
	var beam_gap: float = _pressure_progress_at_position(player.global_position) - pressure_progress if pressure_beam_enabled else 999.0
	metrics.sample(
		delta,
		planar_speed,
		bool(player_events.get("grounded", false)),
		bool(player_events.get("sliding", false)),
		beam_gap,
		pressure_beam_enabled and pulse_active,
		bool(player_events.get("wall_touching", false))
	)


func _run_scene_parity_check() -> void:
	var level: Dictionary = _resolve_level_spec(level_specs[active_level_index])
	var override_scene_path: String = str(level.get("scene_override_path", ""))
	if override_scene_path.is_empty():
		prompt_label.text = "Parity check skipped: no scene_override_path on this level."
		return

	var expected_layout: Dictionary = _collect_scene_expected_layout(level)
	if expected_layout.is_empty():
		prompt_label.text = "Parity check failed: could not load expected scene layout."
		return

	var actual_layout: Dictionary = {
		"geometry": _collect_direct_child_names(geometry_root),
		"backdrop": _collect_direct_child_names(backdrop_root),
		"guide": _collect_direct_child_names(guide_root),
		"source": _collect_direct_child_names(source_group),
		"target": _collect_direct_child_names(target_group)
	}

	var roots: Array[String] = ["geometry", "backdrop", "guide", "source", "target"]
	var has_mismatch: bool = false
	for root_key in roots:
		var expected_names: Array[String] = expected_layout.get(root_key, []) as Array[String]
		var actual_names: Array[String] = actual_layout.get(root_key, []) as Array[String]
		var missing: Array[String] = _names_missing_from(expected_names, actual_names)
		var extra: Array[String] = _names_missing_from(actual_names, expected_names)
		if missing.is_empty() and extra.is_empty():
			continue
		has_mismatch = true
		print("[PARITY] %s mismatch:" % root_key)
		if not missing.is_empty():
			print("  missing: %s" % _format_name_list(missing, 12))
		if not extra.is_empty():
			print("  extra: %s" % _format_name_list(extra, 12))

	if has_mismatch:
		prompt_label.text = "Parity mismatch. Check Output for missing/extra nodes."
	else:
		prompt_label.text = "Parity OK: scene and runtime environment match."


func _collect_scene_expected_layout(level: Dictionary) -> Dictionary:
	var override_scene_path: String = str(level.get("scene_override_path", ""))
	if override_scene_path.is_empty():
		return {}
	var packed_scene: PackedScene = load(override_scene_path) as PackedScene
	if packed_scene == null:
		return {}
	var scene_instance: Node = packed_scene.instantiate()
	if scene_instance == null:
		return {}

	var expected: Dictionary = {
		"geometry": [],
		"backdrop": [],
		"guide": [],
		"source": [],
		"target": []
	}

	if bool(level.get("use_scene_platform_nodes", false)):
		var platforms_root_path: String = str(level.get("scene_platforms_root_path", "Platforms"))
		_append_child_names(scene_instance.get_node_or_null(NodePath(platforms_root_path)), expected["geometry"] as Array[String])
	if bool(level.get("use_scene_absorber_nodes", false)):
		var absorbers_root_path: String = str(level.get("scene_absorbers_root_path", "Absorbers"))
		_append_child_names(scene_instance.get_node_or_null(NodePath(absorbers_root_path)), expected["geometry"] as Array[String])
	if bool(level.get("include_scene_environment_shapes", false)):
		var env_root_path: String = str(level.get("scene_environment_root_path", "EnvironmentShapes"))
		var env_root: Node = scene_instance.get_node_or_null(NodePath(env_root_path))
		if env_root != null:
			_append_child_names(env_root.get_node_or_null("Geometry"), expected["geometry"] as Array[String])
			_append_child_names(env_root.get_node_or_null("Backdrop"), expected["backdrop"] as Array[String])
			_append_child_names(env_root.get_node_or_null("Guide"), expected["guide"] as Array[String])
			_append_child_names(env_root.get_node_or_null("SourceVisuals"), expected["source"] as Array[String])
			_append_child_names(env_root.get_node_or_null("TargetVisuals"), expected["target"] as Array[String])

	scene_instance.free()
	for key_variant in expected.keys():
		var key: String = str(key_variant)
		expected[key] = _sorted_unique_names(expected[key] as Array[String])
	return expected


func _append_child_names(root: Node, out_names: Array) -> void:
	if root == null:
		return
	for child in root.get_children():
		out_names.append(str(child.name))


func _collect_direct_child_names(root: Node) -> Array[String]:
	var names: Array[String] = []
	if root == null:
		return names
	for child in root.get_children():
		names.append(str(child.name))
	return _sorted_unique_names(names)


func _sorted_unique_names(input_names: Array) -> Array[String]:
	var seen: Dictionary = {}
	for entry_name in input_names:
		seen[str(entry_name)] = true
	var names: Array[String] = []
	for key_variant in seen.keys():
		names.append(str(key_variant))
	names.sort()
	return names


func _names_missing_from(expected_names: Array, actual_names: Array) -> Array[String]:
	var missing: Array[String] = []
	for entry_name in expected_names:
		var expected_name: String = str(entry_name)
		if not actual_names.has(expected_name):
			missing.append(expected_name)
	missing.sort()
	return missing


func _format_name_list(names: Array[String], max_items: int) -> String:
	if names.is_empty():
		return "[]"
	var items: Array[String] = []
	var count: int = min(names.size(), max_items)
	for index in range(count):
		items.append(names[index])
	if names.size() > max_items:
		items.append("... +%d" % (names.size() - max_items))
	return ", ".join(items)


func _add_channel_segment(from_point: Vector3, to_point: Vector3, optional: bool) -> void:
	var a: Vector3 = Vector3(from_point.x, 0.02, from_point.z)
	var b: Vector3 = Vector3(to_point.x, 0.02, to_point.z)
	var delta: Vector3 = b - a
	var length: float = delta.length()
	if length < 0.05:
		return
	var angle: float = atan2(delta.x, delta.z)
	var mid: Vector3 = a.lerp(b, 0.5)

	var trench: MeshInstance3D = MeshInstance3D.new()
	var trench_mesh: BoxMesh = BoxMesh.new()
	trench_mesh.size = Vector3(0.22 if not optional else 0.16, 0.018, length)
	trench.mesh = trench_mesh
	trench.position = mid
	trench.rotation.y = angle
	trench.material_override = _make_material(Color(0.1647, 0.1922, 0.2196, 0.42), Color(0.0, 0.0, 0.0, 1.0), 0.0)
	guide_root.add_child(trench)

	var glow: MeshInstance3D = MeshInstance3D.new()
	var glow_mesh: BoxMesh = BoxMesh.new()
	glow_mesh.size = Vector3(0.09 if not optional else 0.05, 0.025, length)
	glow.mesh = glow_mesh
	glow.position = mid + Vector3(0.0, 0.014, 0.0)
	glow.rotation.y = angle
	glow.material_override = _make_material(
		Color(0.5608, 1.0, 0.8196, 0.62) if not optional else Color(0.8392, 0.6431, 0.3529, 0.35),
		Color(0.9373, 1.0, 0.9725, 1.0) if not optional else Color(0.8392, 0.6431, 0.3529, 1.0),
		0.38 if not optional else 0.18
	)
	guide_root.add_child(glow)


func _make_material(albedo: Color, emission: Color, emission_energy: float, roughness: float = 0.3, metallic: float = 0.02) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = albedo
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = emission_energy
	material.roughness = roughness
	material.metallic = metallic
	if albedo.a < 0.99:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material


func _apply_level_environment(level: Dictionary) -> void:
	if world_environment == null:
		return
	var env_preset: String = str(level.get("env_preset", "default"))
	world_environment = graphics_kit.environment_from_key(env_preset)
	if world_environment_node != null:
		world_environment_node.environment = world_environment
	var fog_near: float = float(level.get("fog_near", 28.0))
	var fog_far: float = float(level.get("fog_far", maxf(fog_near + 40.0, world_bounds.size.z * 0.68)))
	fog_far = maxf(fog_near + 10.0, fog_far)
	world_environment.fog_sky_affect = 0.34
	world_environment.fog_aerial_perspective = 0.38
	world_environment.fog_density = clampf(1.0 / fog_far, 0.0045, 0.016)


func _create_milky_way_sky_material() -> ShaderMaterial:
	var shader: Shader = Shader.new()
	shader.code = """
shader_type sky;

uniform vec3 top_color : source_color = vec3(0.016, 0.018, 0.028);
uniform vec3 mid_color : source_color = vec3(0.07, 0.08, 0.11);
uniform vec3 horizon_color : source_color = vec3(0.1922, 0.1686, 0.2588);
uniform vec3 band_color : source_color = vec3(0.2902, 0.2627, 0.3765);
uniform float band_width : hint_range(0.05, 0.8) = 0.24;
uniform float band_strength : hint_range(0.0, 2.0) = 0.52;
uniform float star_density : hint_range(0.0, 0.2) = 0.00055;
uniform float star_scale : hint_range(50.0, 1200.0) = 760.0;
uniform float star_brightness : hint_range(0.0, 2.5) = 0.44;

float hash3(vec3 p) {
	return fract(sin(dot(p, vec3(127.1, 311.7, 74.7))) * 43758.5453123);
}

void sky() {
	vec3 dir = normalize(EYEDIR);
	float h = clamp(dir.y * 0.5 + 0.5, 0.0, 1.0);

	vec3 lower_grad = mix(horizon_color, mid_color, smoothstep(0.0, 0.58, h));
	vec3 upper_grad = mix(mid_color, top_color, smoothstep(0.34, 1.0, h));
	vec3 col = mix(lower_grad, upper_grad, smoothstep(0.2, 0.84, h));

	float horizon_glow = exp(-pow(abs(dir.y) / 0.22, 2.0));
	col += vec3(0.09, 0.07, 0.13) * horizon_glow * 0.26;

	float az = atan(dir.x, dir.z);
	float hue_wave = 0.5 + 0.5 * sin(az * 2.0 + dir.y * 3.6);
	col += mix(vec3(0.03, 0.03, 0.05), vec3(0.07, 0.05, 0.1), hue_wave) * 0.05 * (1.0 - h);

	vec3 band_normal = normalize(vec3(-0.28, 0.93, 0.21));
	float band = exp(-pow(abs(dot(dir, band_normal)) / band_width, 2.0));
	col += band_color * band * band_strength;

	vec3 cell = floor(dir * star_scale);
	float n = hash3(cell);
	float twinkle_seed = hash3(cell + vec3(19.1, 73.7, 41.3));
	float star = step(1.0 - star_density, n) * (0.65 + twinkle_seed * 0.35);
	col += vec3(star) * star_brightness;

	COLOR = col;
}
"""
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = shader
	return material


func _configure_input_map() -> void:
	_bind_key("move_left", KEY_A)
	_bind_key("move_left", KEY_LEFT)
	_bind_key("move_right", KEY_D)
	_bind_key("move_right", KEY_RIGHT)
	_bind_key("move_up", KEY_W)
	_bind_key("move_up", KEY_UP)
	_bind_key("move_down", KEY_S)
	_bind_key("move_down", KEY_DOWN)
	_bind_key("jump", KEY_SPACE)
	_bind_key("dash", KEY_SHIFT)
	_bind_key("sprint", KEY_CTRL)
	_bind_key("slide", KEY_C)
	_bind_key("slide", KEY_ALT)
	_bind_key("restart", KEY_R)
	_bind_key("next_level", KEY_N)
	_bind_key("prev_level", KEY_P)
	_bind_key("procedural_generate", KEY_G)
	_bind_key("metrics_report", KEY_F6)
	_bind_key("parity_check", KEY_F7)
	_bind_mouse("pulse_action", MOUSE_BUTTON_LEFT)
	_bind_joy_button("jump", JOY_BUTTON_A)
	_bind_joy_button("dash", JOY_BUTTON_RIGHT_SHOULDER)
	_bind_joy_button("sprint", JOY_BUTTON_LEFT_SHOULDER)
	_bind_joy_button("slide", JOY_BUTTON_B)
	_bind_joy_button("pulse_action", JOY_BUTTON_X)
	_bind_joy_button("restart", JOY_BUTTON_Y)
	_bind_joy_axis("look_left", JOY_AXIS_RIGHT_X, -1.0)
	_bind_joy_axis("look_right", JOY_AXIS_RIGHT_X, 1.0)
	_bind_joy_axis("look_up", JOY_AXIS_RIGHT_Y, -1.0)
	_bind_joy_axis("look_down", JOY_AXIS_RIGHT_Y, 1.0)


func _bind_key(action_name: String, keycode: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for event in InputMap.action_get_events(action_name):
		if event is InputEventKey and event.physical_keycode == keycode:
			return
	var input_event: InputEventKey = InputEventKey.new()
	input_event.physical_keycode = keycode
	InputMap.action_add_event(action_name, input_event)


func _bind_mouse(action_name: String, button: MouseButton) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for event in InputMap.action_get_events(action_name):
		if event is InputEventMouseButton and event.button_index == button:
			return
	var input_event: InputEventMouseButton = InputEventMouseButton.new()
	input_event.button_index = button
	InputMap.action_add_event(action_name, input_event)


func _bind_joy_button(action_name: String, button: JoyButton) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for event in InputMap.action_get_events(action_name):
		if event is InputEventJoypadButton and event.button_index == button:
			return
	var input_event: InputEventJoypadButton = InputEventJoypadButton.new()
	input_event.button_index = button
	InputMap.action_add_event(action_name, input_event)


func _bind_joy_axis(action_name: String, axis: JoyAxis, axis_value: float) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for event in InputMap.action_get_events(action_name):
		if event is InputEventJoypadMotion and event.axis == axis and is_equal_approx(event.axis_value, axis_value):
			return
	var input_event: InputEventJoypadMotion = InputEventJoypadMotion.new()
	input_event.axis = axis
	input_event.axis_value = axis_value
	InputMap.action_add_event(action_name, input_event)
