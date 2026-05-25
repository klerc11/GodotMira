extends Node3D

const WORLD_STEPS: int = 264  # 3x linear → 9x area
const CELL_SIZE: float = 1.0
const WORLD_HALF: float = float(WORLD_STEPS) * CELL_SIZE * 0.5
const WATER_LEVEL: float = -1.0  # only the deepest carved valleys flood now
const TREE_COUNT: int = 1275  # redwood forest density (15% trim)
const ROCK_COUNT: int = 150
const BEACON_COUNT: int = 40
const RUIN_COUNT: int = 25
const GROUNDCOVER_COUNT: int = 3500  # grass tuft target (single MultiMesh batch)
const GRAVITY: float = 25.0
const WALK_SPEED: float = 8.0
const SPRINT_SPEED: float = 12.5
const JUMP_SPEED: float = 9.2
const MOUSE_SENSITIVITY: float = 0.0025
const MAX_PITCH: float = 1.4835  # ~85 degrees in radians
const EYE_HEIGHT: float = 0.7

var camera_pitch: float = 0.0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var terrain_noise: FastNoiseLite = FastNoiseLite.new()
var detail_noise: FastNoiseLite = FastNoiseLite.new()
var ridge_noise: FastNoiseLite = FastNoiseLite.new()

var terrain_root: Node3D
var props_root: Node3D
var beacons_root: Node3D
var player_body: CharacterBody3D
var player_visual: Node3D
var camera: Camera3D

var beacons: Array[Node3D] = []
var beacon_phases: Array[float] = []
var collected_count: int = 0
var world_seed: int = 0
var status_timer: float = 0.0

var score_label: Label
var seed_label: Label
var status_label: Label
var help_label: Label

var terrain_material: StandardMaterial3D
var water_material: StandardMaterial3D
var trunk_material: StandardMaterial3D
var leaf_material: StandardMaterial3D
var rock_material: StandardMaterial3D
var ruin_material: StandardMaterial3D
var player_material: StandardMaterial3D
var beacon_material: StandardMaterial3D
var leaf_variant_colors: Array[Color] = []
var trunk_variant_colors: Array[Color] = []
var trunk_base_mesh: CylinderMesh
var crown_base_mesh: SphereMesh
var grass_base_mesh: BoxMesh
var foliage_shader: Shader


func _ready() -> void:
	rng.randomize()
	_configure_input()
	_build_materials()
	_build_environment()
	_build_roots()
	_build_player()
	_build_camera()
	_build_ui()
	generate_world(rng.randi())
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		player_body.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera_pitch = clamp(camera_pitch - event.relative.y * MOUSE_SENSITIVITY, -MAX_PITCH, MAX_PITCH)
		camera.rotation.x = camera_pitch
	elif event is InputEventKey and event.pressed and event.physical_keycode == KEY_ESCAPE:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event is InputEventMouseButton and event.pressed and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("regenerate"):
		generate_world(rng.randi())
		return

	if Input.is_action_just_pressed("restart"):
		_place_player_at_spawn()

	_drive_player(delta)
	_update_beacons(delta)
	_check_beacons()
	_check_fall_reset()
	_update_camera(delta)
	_update_status(delta)
	_update_ui()


func generate_world(seed_value: int) -> void:
	world_seed = seed_value
	collected_count = 0
	status_timer = 0.0
	beacons.clear()
	beacon_phases.clear()

	_clear_children(terrain_root)
	_clear_children(props_root)
	_clear_children(beacons_root)

	_configure_noise(seed_value)
	_build_terrain()
	_build_water()
	_scatter_props()
	_scatter_beacons()
	_place_player_at_spawn()
	_set_status("WORLD GENERATED", 1.4)
	_update_camera(1.0)
	_update_ui()


func _clear_children(parent: Node) -> void:
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()


func _configure_noise(seed_value: int) -> void:
	terrain_noise.seed = seed_value
	terrain_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	terrain_noise.frequency = 0.038
	terrain_noise.fractal_octaves = 5
	terrain_noise.fractal_gain = 0.48

	detail_noise.seed = seed_value + 991
	detail_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	detail_noise.frequency = 0.05
	detail_noise.fractal_octaves = 3
	detail_noise.fractal_gain = 0.42

	ridge_noise.seed = seed_value + 4027
	ridge_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	ridge_noise.frequency = 0.072
	ridge_noise.fractal_octaves = 4
	ridge_noise.fractal_gain = 0.52


func _build_materials() -> void:
	terrain_material = StandardMaterial3D.new()
	terrain_material.vertex_color_use_as_albedo = true
	terrain_material.roughness = 0.78

	# Glossy, slightly emissive water with rim highlight for a richer look.
	water_material = StandardMaterial3D.new()
	water_material.albedo_color = Color(0.10, 0.38, 0.52, 0.62)
	water_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	water_material.roughness = 0.08
	water_material.metallic_specular = 0.7
	water_material.emission_enabled = true
	water_material.emission = Color(0.05, 0.20, 0.32, 1.0)
	water_material.emission_energy_multiplier = 0.18
	water_material.rim_enabled = true
	water_material.rim = 0.55
	water_material.rim_tint = 0.6

	trunk_material = _make_material(Color(0.33, 0.2, 0.12, 1.0), Color.BLACK, 0.0)
	leaf_material = _make_material(Color(0.08, 0.42, 0.22, 1.0), Color(0.02, 0.15, 0.05, 1.0), 0.1)
	rock_material = _make_material(Color(0.32, 0.34, 0.36, 1.0), Color.BLACK, 0.0)
	ruin_material = _make_material(Color(0.36, 0.35, 0.32, 1.0), Color.BLACK, 0.0)
	player_material = _make_material(Color(0.22, 0.78, 0.92, 1.0), Color(0.08, 0.55, 0.78, 1.0), 0.55)
	beacon_material = _make_material(Color(1.0, 0.82, 0.22, 1.0), Color(1.0, 0.62, 0.12, 1.0), 1.45)

	# 12 leaf + 12 trunk color variants picked randomly per tree so the forest
	# reads as a real ecosystem instead of a clone army. (Colors only — actual
	# materials are MultiMesh per-instance, so we just need swatches.)
	for i in range(12):
		leaf_variant_colors.append(_make_leaf_color())
		trunk_variant_colors.append(_make_trunk_color())

	# Base meshes reused by every tree / grass-blade instance via MultiMesh.
	trunk_base_mesh = CylinderMesh.new()
	trunk_base_mesh.top_radius = 0.55
	trunk_base_mesh.bottom_radius = 1.35
	trunk_base_mesh.height = 38.0
	trunk_base_mesh.radial_segments = 10

	crown_base_mesh = SphereMesh.new()
	crown_base_mesh.radius = 5.5
	crown_base_mesh.height = 18.0
	crown_base_mesh.radial_segments = 12
	crown_base_mesh.rings = 8

	grass_base_mesh = BoxMesh.new()
	grass_base_mesh.size = Vector3(0.06, 0.55, 0.18)

	_build_foliage_shader()


func _make_leaf_color() -> Color:
	# Greens spanning fresh / deep / olive / blue-green.
	return Color.from_hsv(
		rng.randf_range(0.27, 0.40),
		rng.randf_range(0.45, 0.78),
		rng.randf_range(0.28, 0.55))


func _make_trunk_color() -> Color:
	# Reddish-brown bark band — redwood inspired.
	return Color.from_hsv(
		rng.randf_range(0.015, 0.075),
		rng.randf_range(0.38, 0.70),
		rng.randf_range(0.20, 0.42))


func _build_foliage_shader() -> void:
	# Single shader shared by crowns and grass. Per-material uniforms tune the
	# sway profile (height range, strength). Per-instance MultiMesh colors come
	# through as COLOR in the fragment stage.
	foliage_shader = Shader.new()
	foliage_shader.code = """
shader_type spatial;
render_mode cull_disabled, diffuse_burley;

uniform float wind_strength : hint_range(0.0, 2.0) = 0.7;
uniform float wind_speed : hint_range(0.0, 5.0) = 1.1;
uniform float sway_pivot = -3.0;
uniform float sway_range = 14.0;
uniform float roughness_value : hint_range(0.0, 1.0) = 0.7;
uniform float emission_amount : hint_range(0.0, 0.5) = 0.05;

void vertex() {
	vec3 world_origin = MODEL_MATRIX[3].xyz;
	float phase = world_origin.x * 0.07 + world_origin.z * 0.05 + TIME * wind_speed;
	float h = smoothstep(sway_pivot, sway_pivot + sway_range, VERTEX.y);
	VERTEX.x += sin(phase) * wind_strength * h;
	VERTEX.z += cos(phase * 0.83) * wind_strength * 0.6 * h;
}

void fragment() {
	ALBEDO = COLOR.rgb;
	ROUGHNESS = roughness_value;
	EMISSION = COLOR.rgb * emission_amount;
}
"""


func _make_material(albedo: Color, emission: Color, emission_energy: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = albedo
	material.roughness = 0.58
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = emission_energy
	return material


func _build_environment() -> void:
	var world_environment: WorldEnvironment = WorldEnvironment.new()
	var environment: Environment = Environment.new()

	# Bright daytime procedural sky with gradient + sun disc.
	var sky_material: ProceduralSkyMaterial = ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.32, 0.55, 0.92, 1.0)
	sky_material.sky_horizon_color = Color(0.78, 0.88, 0.98, 1.0)
	sky_material.sky_curve = 0.18
	sky_material.sky_energy_multiplier = 1.1
	sky_material.ground_bottom_color = Color(0.15, 0.18, 0.20, 1.0)
	sky_material.ground_horizon_color = Color(0.62, 0.64, 0.60, 1.0)
	sky_material.sun_angle_max = 28.0
	sky_material.sun_curve = 0.12

	var sky: Sky = Sky.new()
	sky.sky_material = sky_material

	environment.background_mode = Environment.BG_SKY
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_energy = 1.0

	# Atmospheric fog — softens the horizon and adds depth between distant trees.
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.76, 0.84, 0.92, 1.0)
	environment.fog_light_energy = 1.0
	environment.fog_density = 0.010
	environment.fog_sky_affect = 0.4
	environment.fog_height = 8.0
	environment.fog_height_density = 0.015

	# Volumetric fog — sun shafts through the canopy. Heavy on GPU; tune density
	# down or disable entirely if framerate suffers.
	environment.volumetric_fog_enabled = true
	environment.volumetric_fog_density = 0.012
	environment.volumetric_fog_albedo = Color(0.92, 0.95, 1.0, 1.0)
	environment.volumetric_fog_emission = Color(0.0, 0.0, 0.0, 1.0)
	environment.volumetric_fog_anisotropy = 0.5
	environment.volumetric_fog_length = 80.0
	environment.volumetric_fog_detail_spread = 2.0
	environment.volumetric_fog_ambient_inject = 0.4

	world_environment.environment = environment
	add_child(world_environment)

	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48.0, 34.0, 0.0)
	sun.light_energy = 1.4
	sun.light_color = Color(1.0, 0.97, 0.9, 1.0)
	sun.shadow_enabled = true
	add_child(sun)


func _build_roots() -> void:
	terrain_root = Node3D.new()
	terrain_root.name = "TerrainRoot"
	add_child(terrain_root)

	props_root = Node3D.new()
	props_root.name = "PropsRoot"
	add_child(props_root)

	beacons_root = Node3D.new()
	beacons_root.name = "BeaconsRoot"
	add_child(beacons_root)


func _build_terrain() -> void:
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)

	for z_index in range(WORLD_STEPS):
		for x_index in range(WORLD_STEPS):
			var x0: float = _index_to_world(x_index)
			var z0: float = _index_to_world(z_index)
			var x1: float = _index_to_world(x_index + 1)
			var z1: float = _index_to_world(z_index + 1)

			var a: Vector3 = Vector3(x0, _height_at(x0, z0), z0)
			var b: Vector3 = Vector3(x1, _height_at(x1, z0), z0)
			var c: Vector3 = Vector3(x1, _height_at(x1, z1), z1)
			var d: Vector3 = Vector3(x0, _height_at(x0, z1), z1)

			_add_terrain_vertex(surface, a)
			_add_terrain_vertex(surface, b)
			_add_terrain_vertex(surface, c)
			_add_terrain_vertex(surface, a)
			_add_terrain_vertex(surface, c)
			_add_terrain_vertex(surface, d)

	surface.generate_normals()
	var mesh: ArrayMesh = surface.commit()

	var terrain_body: StaticBody3D = StaticBody3D.new()
	terrain_body.name = "GeneratedTerrain"
	terrain_root.add_child(terrain_body)

	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.shape = mesh.create_trimesh_shape()
	terrain_body.add_child(collision)

	var terrain_instance: MeshInstance3D = MeshInstance3D.new()
	terrain_instance.mesh = mesh
	terrain_instance.material_override = terrain_material
	terrain_body.add_child(terrain_instance)


func _add_terrain_vertex(surface: SurfaceTool, point: Vector3) -> void:
	surface.set_color(_terrain_color(point))
	surface.set_uv(Vector2((point.x + WORLD_HALF) / (WORLD_HALF * 2.0), (point.z + WORLD_HALF) / (WORLD_HALF * 2.0)))
	surface.add_vertex(point)


func _terrain_color(point: Vector3) -> Color:
	# Smooth blends between sand → grass → moss → rock, with per-vertex
	# noise variation so the surface doesn't look like flat banded paint.
	var sand: Color = Color(0.58, 0.51, 0.32, 1.0)
	var grass: Color = Color(0.22, 0.48, 0.24, 1.0)
	var moss: Color = Color(0.17, 0.37, 0.20, 1.0)
	var rock: Color = Color(0.55, 0.55, 0.52, 1.0)
	var wet_underbrush: Color = Color(0.13, 0.42, 0.20, 1.0)  # saturated, damp

	var color: Color = sand.lerp(grass, smoothstep(WATER_LEVEL - 0.2, WATER_LEVEL + 0.7, point.y))
	color = color.lerp(moss, smoothstep(2.4, 4.2, point.y))
	color = color.lerp(rock, smoothstep(4.6, 6.2, point.y))

	# Damp, saturated greens within ~1.8m of the waterline — reads as lush
	# riparian growth, peaks just above the shore and fades out as we climb.
	var wet_band: float = smoothstep(WATER_LEVEL + 0.1, WATER_LEVEL + 0.8, point.y) \
		* (1.0 - smoothstep(WATER_LEVEL + 0.9, WATER_LEVEL + 2.4, point.y))
	color = color.lerp(wet_underbrush, wet_band * 0.65)

	# Subtle noise mottle so adjacent vertices don't share identical tone.
	var variation: float = detail_noise.get_noise_2d(point.x * 1.8, point.z * 1.8) * 0.07
	color.r = clamp(color.r + variation, 0.0, 1.0)
	color.g = clamp(color.g + variation * 0.7, 0.0, 1.0)
	color.b = clamp(color.b + variation * 0.4, 0.0, 1.0)
	return color


func _build_water() -> void:
	var mesh: PlaneMesh = PlaneMesh.new()
	mesh.size = Vector2(WORLD_HALF * 2.15, WORLD_HALF * 2.15)

	var water: MeshInstance3D = MeshInstance3D.new()
	water.name = "Water"
	water.mesh = mesh
	water.position = Vector3(0.0, WATER_LEVEL, 0.0)
	water.material_override = water_material
	terrain_root.add_child(water)


func _build_player() -> void:
	player_body = CharacterBody3D.new()
	player_body.name = "Explorer"
	player_body.floor_snap_length = 0.6
	add_child(player_body)

	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = 0.42
	capsule.height = 1.65
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.shape = capsule
	player_body.add_child(collision)

	player_visual = Node3D.new()
	player_body.add_child(player_visual)
	# Player body mesh intentionally omitted — first-person camera doesn't render self.


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.fov = 75.0
	camera.current = true
	camera.position = Vector3(0.0, EYE_HEIGHT, 0.0)
	player_body.add_child(camera)


func _build_ui() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	add_child(layer)

	var root: Control = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)

	score_label = _make_label(Vector2(24.0, 18.0), Vector2(240.0, 32.0), 25, HORIZONTAL_ALIGNMENT_LEFT)
	root.add_child(score_label)

	seed_label = _make_label(Vector2(630.0, 18.0), Vector2(306.0, 32.0), 19, HORIZONTAL_ALIGNMENT_RIGHT)
	root.add_child(seed_label)

	status_label = _make_label(Vector2(250.0, 18.0), Vector2(460.0, 32.0), 22, HORIZONTAL_ALIGNMENT_CENTER)
	root.add_child(status_label)

	help_label = _make_label(Vector2(0.0, 492.0), Vector2(960.0, 30.0), 18, HORIZONTAL_ALIGNMENT_CENTER)
	help_label.text = "MOUSE LOOK   WASD MOVE   SHIFT SPRINT   SPACE JUMP   R RESPAWN   ENTER NEW WORLD   ESC FREE CURSOR"
	root.add_child(help_label)


func _make_label(pos: Vector2, label_size: Vector2, font_size: int, alignment: HorizontalAlignment) -> Label:
	var label: Label = Label.new()
	label.position = pos
	label.size = label_size
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(0.92, 0.98, 1.0, 1.0))
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.8))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	return label


func _configure_input() -> void:
	_bind_key("move_left", KEY_A)
	_bind_key("move_left", KEY_LEFT)
	_bind_key("move_right", KEY_D)
	_bind_key("move_right", KEY_RIGHT)
	_bind_key("move_up", KEY_W)
	_bind_key("move_up", KEY_UP)
	_bind_key("move_down", KEY_S)
	_bind_key("move_down", KEY_DOWN)
	_bind_key("jump", KEY_SPACE)
	_bind_key("sprint", KEY_SHIFT)
	_bind_key("restart", KEY_R)
	_bind_key("regenerate", KEY_ENTER)
	_bind_key("regenerate", KEY_KP_ENTER)


func _bind_key(action_name: String, keycode: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

	for event in InputMap.action_get_events(action_name):
		if event is InputEventKey and event.physical_keycode == keycode:
			return

	var key_event: InputEventKey = InputEventKey.new()
	key_event.physical_keycode = keycode
	InputMap.action_add_event(action_name, key_event)


func _drive_player(delta: float) -> void:
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var basis: Basis = player_body.global_transform.basis
	var forward: Vector3 = -basis.z
	var right: Vector3 = basis.x
	forward.y = 0.0
	right.y = 0.0
	if forward.length_squared() > 0.0001:
		forward = forward.normalized()
	if right.length_squared() > 0.0001:
		right = right.normalized()
	# input_vector.y = down - up, so W (up) gives -1 → use -input_vector.y for forward amount
	var move_direction: Vector3 = forward * -input_vector.y + right * input_vector.x
	if move_direction.length_squared() > 1.0:
		move_direction = move_direction.normalized()

	var target_speed: float = SPRINT_SPEED if Input.is_action_pressed("sprint") else WALK_SPEED
	var target_velocity: Vector3 = move_direction * target_speed
	var velocity: Vector3 = player_body.velocity
	var blend: float = 1.0 - exp(-10.5 * delta)

	velocity.x = lerpf(velocity.x, target_velocity.x, blend)
	velocity.z = lerpf(velocity.z, target_velocity.z, blend)

	if player_body.is_on_floor():
		if velocity.y < 0.0:
			velocity.y = -0.2
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_SPEED
			_set_status("JUMPING", 0.55)
	else:
		velocity.y -= GRAVITY * delta

	player_body.velocity = velocity
	player_body.move_and_slide()


func _scatter_props() -> void:
	_scatter_trees()

	for index in range(ROCK_COUNT):
		var point: Vector3 = _find_ground_point(WATER_LEVEL - 0.1, 6.0)
		if point != Vector3.INF:
			_spawn_rock(point, rng.randf_range(0.55, 1.55))

	for index in range(RUIN_COUNT):
		var point: Vector3 = _find_ground_point(WATER_LEVEL + 0.35, 2.6)
		if point != Vector3.INF:
			_spawn_ruin_block(point, rng.randf_range(0.9, 1.8))

	_scatter_groundcover()


func _scatter_beacons() -> void:
	for index in range(BEACON_COUNT):
		var point: Vector3 = _find_ground_point(WATER_LEVEL + 0.12, 5.2)
		if point != Vector3.INF:
			_spawn_beacon(point)


func _scatter_trees() -> void:
	# Two MultiMeshInstance3D batches (trunk + crown) for ALL trees. Drops
	# rendering from ~2550 draw calls to 2. Per-instance MultiMesh colors
	# preserve the 12-variant trunk/leaf variation; the crown shader adds
	# wind sway driven by per-tree world position.
	var placements: Array = []
	for index in range(TREE_COUNT):
		var point: Vector3 = _find_ground_point(WATER_LEVEL + 0.22, 3.8)
		if point == Vector3.INF:
			continue
		var tree_scale: float = rng.randf_range(0.8, 1.45)
		var trunk_color: Color = trunk_variant_colors[rng.randi() % trunk_variant_colors.size()]
		var leaf_color: Color = leaf_variant_colors[rng.randi() % leaf_variant_colors.size()]
		placements.append([point, tree_scale, trunk_color, leaf_color])
		_spawn_tree_collision(point, tree_scale)

	var count: int = placements.size()
	if count == 0:
		return

	# Trunk batch (no wind — rigid wood).
	var trunk_mm_resource: MultiMesh = MultiMesh.new()
	trunk_mm_resource.transform_format = MultiMesh.TRANSFORM_3D
	trunk_mm_resource.use_colors = true
	trunk_mm_resource.mesh = trunk_base_mesh
	trunk_mm_resource.instance_count = count

	var trunk_material_inst: StandardMaterial3D = StandardMaterial3D.new()
	trunk_material_inst.vertex_color_use_as_albedo = true
	trunk_material_inst.roughness = 0.88

	var trunk_mm_node: MultiMeshInstance3D = MultiMeshInstance3D.new()
	trunk_mm_node.multimesh = trunk_mm_resource
	trunk_mm_node.material_override = trunk_material_inst
	props_root.add_child(trunk_mm_node)

	# Crown batch (wind sway via foliage_shader).
	var crown_mm_resource: MultiMesh = MultiMesh.new()
	crown_mm_resource.transform_format = MultiMesh.TRANSFORM_3D
	crown_mm_resource.use_colors = true
	crown_mm_resource.mesh = crown_base_mesh
	crown_mm_resource.instance_count = count

	var crown_material_inst: ShaderMaterial = ShaderMaterial.new()
	crown_material_inst.shader = foliage_shader
	crown_material_inst.set_shader_parameter("wind_strength", 0.55)
	crown_material_inst.set_shader_parameter("wind_speed", 1.1)
	crown_material_inst.set_shader_parameter("sway_pivot", -4.0)
	crown_material_inst.set_shader_parameter("sway_range", 14.0)
	crown_material_inst.set_shader_parameter("roughness_value", 0.7)
	crown_material_inst.set_shader_parameter("emission_amount", 0.05)

	var crown_mm_node: MultiMeshInstance3D = MultiMeshInstance3D.new()
	crown_mm_node.multimesh = crown_mm_resource
	crown_mm_node.material_override = crown_material_inst
	props_root.add_child(crown_mm_node)

	for i in range(count):
		var point: Vector3 = placements[i][0]
		var tree_scale: float = placements[i][1]
		var trunk_color: Color = placements[i][2]
		var leaf_color: Color = placements[i][3]
		var basis: Basis = Basis.from_scale(Vector3.ONE * tree_scale)

		var trunk_xform: Transform3D = Transform3D(basis, point + Vector3(0.0, 38.0 * tree_scale * 0.5, 0.0))
		trunk_mm_resource.set_instance_transform(i, trunk_xform)
		trunk_mm_resource.set_instance_color(i, trunk_color)

		var crown_xform: Transform3D = Transform3D(basis, point + Vector3(0.0, 38.0 * tree_scale * 0.78, 0.0))
		crown_mm_resource.set_instance_transform(i, crown_xform)
		crown_mm_resource.set_instance_color(i, leaf_color)


func _spawn_tree_collision(point: Vector3, tree_scale: float) -> void:
	# Collision-only body so the player can't walk through trunks; visuals
	# are handled by the MultiMesh batches built in _scatter_trees.
	var trunk_height: float = 38.0 * tree_scale
	var body: StaticBody3D = StaticBody3D.new()
	body.position = point
	props_root.add_child(body)

	var trunk_shape: CylinderShape3D = CylinderShape3D.new()
	trunk_shape.radius = 1.1 * tree_scale
	trunk_shape.height = trunk_height
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.position = Vector3(0.0, trunk_height * 0.5, 0.0)
	collision.shape = trunk_shape
	body.add_child(collision)


func _scatter_groundcover() -> void:
	# Thousands of grass blades as a single MultiMesh batch with shader wind.
	# No collision — purely decorative.
	var placements: Array = []
	for index in range(GROUNDCOVER_COUNT):
		var point: Vector3 = _find_ground_point(WATER_LEVEL + 0.18, 4.0)
		if point == Vector3.INF:
			continue
		placements.append(point)

	var count: int = placements.size()
	if count == 0:
		return

	var grass_mm_resource: MultiMesh = MultiMesh.new()
	grass_mm_resource.transform_format = MultiMesh.TRANSFORM_3D
	grass_mm_resource.use_colors = true
	grass_mm_resource.mesh = grass_base_mesh
	grass_mm_resource.instance_count = count

	var grass_material_inst: ShaderMaterial = ShaderMaterial.new()
	grass_material_inst.shader = foliage_shader
	# Short blades — small sway envelope tuned to the 0.55m tall base mesh.
	grass_material_inst.set_shader_parameter("wind_strength", 0.08)
	grass_material_inst.set_shader_parameter("wind_speed", 1.8)
	grass_material_inst.set_shader_parameter("sway_pivot", -0.3)
	grass_material_inst.set_shader_parameter("sway_range", 0.7)
	grass_material_inst.set_shader_parameter("roughness_value", 0.82)
	grass_material_inst.set_shader_parameter("emission_amount", 0.02)

	var grass_mm_node: MultiMeshInstance3D = MultiMeshInstance3D.new()
	grass_mm_node.multimesh = grass_mm_resource
	grass_mm_node.material_override = grass_material_inst
	props_root.add_child(grass_mm_node)

	for i in range(count):
		var point: Vector3 = placements[i]
		var blade_scale: float = rng.randf_range(0.6, 1.4)
		var rot_y: float = rng.randf_range(0.0, TAU)
		# Slight non-uniform scaling for shape variety, rotated around Y for variety.
		var basis: Basis = Basis(Vector3.UP, rot_y).scaled(
			Vector3(blade_scale * rng.randf_range(0.8, 1.4), blade_scale, blade_scale * rng.randf_range(0.8, 1.4)))
		var xform: Transform3D = Transform3D(basis, point + Vector3(0.0, 0.275 * blade_scale, 0.0))
		grass_mm_resource.set_instance_transform(i, xform)
		# Yellow-green to deep-green range for grass.
		grass_mm_resource.set_instance_color(i, Color.from_hsv(
			rng.randf_range(0.22, 0.36),
			rng.randf_range(0.50, 0.80),
			rng.randf_range(0.30, 0.55)))


func _spawn_rock(point: Vector3, rock_scale: float) -> void:
	var rock: StaticBody3D = StaticBody3D.new()
	rock.position = point + Vector3(0.0, 0.18 * rock_scale, 0.0)
	props_root.add_child(rock)

	var shape: SphereShape3D = SphereShape3D.new()
	shape.radius = 0.42 * rock_scale
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.shape = shape
	rock.add_child(collision)

	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.42 * rock_scale
	mesh.height = 0.62 * rock_scale
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.scale = Vector3(1.25, 0.72, 0.92)
	instance.mesh = mesh
	instance.material_override = rock_material
	rock.add_child(instance)


func _spawn_ruin_block(point: Vector3, block_scale: float) -> void:
	var size: Vector3 = Vector3(rng.randf_range(0.8, 1.8), rng.randf_range(0.6, 1.8), rng.randf_range(0.8, 1.8)) * block_scale
	var body: StaticBody3D = StaticBody3D.new()
	body.position = point + Vector3(0.0, size.y * 0.5, 0.0)
	body.rotation_degrees.y = rng.randf_range(0.0, 360.0)
	props_root.add_child(body)

	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = size
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)

	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = ruin_material
	body.add_child(instance)


func _spawn_beacon(point: Vector3) -> void:
	var beacon: Node3D = Node3D.new()
	beacon.position = point + Vector3(0.0, 0.85, 0.0)
	beacons_root.add_child(beacon)

	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.32
	mesh.height = 0.64
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = beacon_material
	beacon.add_child(instance)

	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.68, 0.18, 1.0)
	light.light_energy = 1.5
	light.omni_range = 5.0
	beacon.add_child(light)

	beacons.append(beacon)
	beacon_phases.append(rng.randf_range(0.0, TAU))


func _update_beacons(delta: float) -> void:
	for index in range(beacons.size()):
		var beacon: Node3D = beacons[index]
		var phase: float = beacon_phases[index] + delta * 2.6
		beacon_phases[index] = phase
		beacon.position.y = _height_at(beacon.position.x, beacon.position.z) + 0.88 + sin(phase) * 0.2
		beacon.rotation.y += delta * 1.7


func _check_beacons() -> void:
	var collected: Array[Node3D] = []
	for beacon in beacons:
		if player_body.global_position.distance_to(beacon.global_position) <= 1.2:
			collected.append(beacon)

	for beacon in collected:
		var index: int = beacons.find(beacon)
		if index >= 0:
			beacons.remove_at(index)
			beacon_phases.remove_at(index)
		beacon.queue_free()
		collected_count += 1
		_set_status("BEACON FOUND", 0.9)

	if collected_count >= BEACON_COUNT:
		_set_status("WORLD ROUTE COMPLETE", 3.0)


func _check_fall_reset() -> void:
	if player_body.global_position.y < -8.0:
		_place_player_at_spawn()
		_set_status("RESPAWNED", 0.8)


func _place_player_at_spawn() -> void:
	var spawn: Vector3 = _find_ground_point(WATER_LEVEL + 0.25, 2.0)
	if spawn == Vector3.INF:
		spawn = Vector3(0.0, _height_at(0.0, 0.0), 0.0)

	player_body.global_position = spawn + Vector3(0.0, 1.6, 0.0)
	player_body.velocity = Vector3.ZERO


func _find_ground_point(min_height: float, max_abs_height: float) -> Vector3:
	for attempt in range(200):
		var x: float = rng.randf_range(-WORLD_HALF + 4.0, WORLD_HALF - 4.0)
		var z: float = rng.randf_range(-WORLD_HALF + 4.0, WORLD_HALF - 4.0)
		var height: float = _height_at(x, z)
		if height < min_height or absf(height) > max_abs_height:
			continue

		var slope: float = _slope_at(x, z)
		if slope > 1.25:
			continue

		return Vector3(x, height, z)

	return Vector3.INF


func _height_at(x: float, z: float) -> float:
	var continent: float = terrain_noise.get_noise_2d(x, z)
	var detail: float = detail_noise.get_noise_2d(x, z)
	var ridge: float = absf(ridge_noise.get_noise_2d(x, z))
	var bowl: float = Vector2(x, z).length() / WORLD_HALF
	var edge_falloff: float = maxf(0.0, bowl - 0.72) * 2.1
	# +1.2 bias raises the average ground above the water plane so only deep
	# valleys form lakes; gentler coefficients across the board for walkability.
	return continent * 3.5 + detail * 0.08 + (1.0 - ridge) * 0.2 - edge_falloff + 1.2


func _slope_at(x: float, z: float) -> float:
	var sample_distance: float = 0.8
	var height_x: float = _height_at(x + sample_distance, z) - _height_at(x - sample_distance, z)
	var height_z: float = _height_at(x, z + sample_distance) - _height_at(x, z - sample_distance)
	return maxf(absf(height_x), absf(height_z))


func _index_to_world(index: int) -> float:
	return float(index) * CELL_SIZE - WORLD_HALF


func _update_camera(_delta: float) -> void:
	# First-person: camera is parented to player_body at EYE_HEIGHT.
	# Yaw is applied to the body in _unhandled_input, pitch to the camera.
	pass


func _update_status(delta: float) -> void:
	status_timer = maxf(0.0, status_timer - delta)
	if status_timer <= 0.0:
		status_label.text = "PROCEDURAL WORLD"


func _set_status(message: String, duration: float) -> void:
	status_label.text = message
	status_timer = duration


func _update_ui() -> void:
	score_label.text = "BEACONS " + str(collected_count) + "/" + str(BEACON_COUNT)
	seed_label.text = "SEED " + str(world_seed)
