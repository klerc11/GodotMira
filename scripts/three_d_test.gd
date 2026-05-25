extends Node3D

const ARENA_HALF_SIZE: float = 13.0
const ROUND_SECONDS: float = 75.0
const PICKUP_COUNT: int = 10
const HAZARD_COUNT: int = 6
const MAX_HEALTH: int = 4
const GRAVITY: float = 24.0
const MOVE_SPEED: float = 7.8
const SPRINT_SPEED: float = 11.6
const JUMP_SPEED: float = 8.6
const HIT_RECOVERY: float = 0.95

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var player_body: CharacterBody3D
var player_visual: Node3D
var player_meshes: Array[MeshInstance3D] = []
var camera: Camera3D
var score_label: Label
var status_label: Label
var health_label: Label
var help_label: Label

var pickups: Array[Node3D] = []
var pickup_phases: Array[float] = []
var hazards: Array[Node3D] = []
var hazard_angles: Array[float] = []
var hazard_radii: Array[float] = []
var hazard_speeds: Array[float] = []
var hazard_centers: Array[Vector3] = []

var score: int = 0
var health: int = MAX_HEALTH
var time_left: float = ROUND_SECONDS
var hit_recovery: float = 0.0
var game_over: bool = false
var status_timer: float = 0.0

var floor_material: StandardMaterial3D
var wall_material: StandardMaterial3D
var player_material: StandardMaterial3D
var player_hot_material: StandardMaterial3D
var pickup_material: StandardMaterial3D
var hazard_material: StandardMaterial3D
var obstacle_material: StandardMaterial3D


func _ready() -> void:
	rng.randomize()
	_configure_input()
	_build_materials()
	_build_environment()
	_build_arena()
	_build_player()
	_build_camera()
	_build_ui()
	reset_test()


func _physics_process(delta: float) -> void:
	if game_over:
		if Input.is_action_just_pressed("restart"):
			reset_test()
		_update_camera(delta)
		return

	if Input.is_action_just_pressed("restart"):
		reset_test()
		return

	_drive_player(delta)
	_update_pickups(delta)
	_update_hazards(delta)
	_check_pickups()
	_check_hazards()
	_check_bounds()
	_update_clock(delta)
	_update_camera(delta)
	_update_ui()


func reset_test() -> void:
	_clear_dynamic_nodes()

	score = 0
	health = MAX_HEALTH
	time_left = ROUND_SECONDS
	hit_recovery = 0.0
	game_over = false
	status_timer = 0.0

	player_body.global_position = Vector3(0.0, 1.25, 0.0)
	player_body.velocity = Vector3.ZERO
	player_visual.rotation = Vector3.ZERO
	_apply_player_material(player_material)

	for index in range(PICKUP_COUNT):
		_spawn_pickup()
	for index in range(HAZARD_COUNT):
		_spawn_hazard(index)

	_set_status("3D TEST RUNNING", 1.2)
	_update_camera(1.0)
	_update_ui()


func _clear_dynamic_nodes() -> void:
	for pickup in pickups:
		pickup.queue_free()
	for hazard in hazards:
		hazard.queue_free()

	pickups.clear()
	pickup_phases.clear()
	hazards.clear()
	hazard_angles.clear()
	hazard_radii.clear()
	hazard_speeds.clear()
	hazard_centers.clear()


func _build_materials() -> void:
	floor_material = _make_material(Color(0.07, 0.1, 0.105, 1.0), Color(0.0, 0.12, 0.15, 1.0), 0.18)
	wall_material = _make_material(Color(0.1, 0.18, 0.2, 1.0), Color(0.0, 0.3, 0.36, 1.0), 0.26)
	player_material = _make_material(Color(0.22, 0.75, 0.88, 1.0), Color(0.12, 0.65, 0.9, 1.0), 0.5)
	player_hot_material = _make_material(Color(1.0, 0.38, 0.25, 1.0), Color(1.0, 0.2, 0.08, 1.0), 0.9)
	pickup_material = _make_material(Color(1.0, 0.84, 0.2, 1.0), Color(1.0, 0.62, 0.12, 1.0), 1.2)
	hazard_material = _make_material(Color(0.9, 0.12, 0.18, 1.0), Color(1.0, 0.05, 0.08, 1.0), 1.35)
	obstacle_material = _make_material(Color(0.16, 0.19, 0.22, 1.0), Color(0.22, 0.28, 0.32, 1.0), 0.18)


func _make_material(albedo: Color, emission: Color, emission_energy: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = albedo
	material.roughness = 0.58
	material.metallic = 0.08
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = emission_energy
	return material


func _build_environment() -> void:
	var world_environment: WorldEnvironment = WorldEnvironment.new()
	var environment: Environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.025, 0.035, 0.045, 1.0)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.45, 0.58, 0.62, 1.0)
	environment.ambient_light_energy = 0.45
	world_environment.environment = environment
	add_child(world_environment)

	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.light_energy = 2.1
	sun.rotation_degrees = Vector3(-48.0, 38.0, 0.0)
	add_child(sun)

	var rim: OmniLight3D = OmniLight3D.new()
	rim.position = Vector3(-7.0, 6.5, 6.0)
	rim.light_color = Color(0.25, 0.75, 1.0, 1.0)
	rim.light_energy = 2.4
	rim.omni_range = 18.0
	add_child(rim)


func _build_arena() -> void:
	_add_static_box(Vector3(0.0, -0.25, 0.0), Vector3(28.0, 0.5, 28.0), floor_material, "Floor")

	var wall_height: float = 1.2
	_add_static_box(Vector3(0.0, wall_height * 0.5, -ARENA_HALF_SIZE - 0.35), Vector3(28.8, wall_height, 0.7), wall_material, "NorthWall")
	_add_static_box(Vector3(0.0, wall_height * 0.5, ARENA_HALF_SIZE + 0.35), Vector3(28.8, wall_height, 0.7), wall_material, "SouthWall")
	_add_static_box(Vector3(-ARENA_HALF_SIZE - 0.35, wall_height * 0.5, 0.0), Vector3(0.7, wall_height, 28.8), wall_material, "WestWall")
	_add_static_box(Vector3(ARENA_HALF_SIZE + 0.35, wall_height * 0.5, 0.0), Vector3(0.7, wall_height, 28.8), wall_material, "EastWall")

	_add_static_box(Vector3(-5.8, 0.6, -2.8), Vector3(2.2, 1.2, 5.0), obstacle_material, "ObstacleA")
	_add_static_box(Vector3(4.8, 0.55, 3.7), Vector3(5.2, 1.1, 1.7), obstacle_material, "ObstacleB")
	_add_static_box(Vector3(1.5, 0.8, -6.2), Vector3(1.8, 1.6, 2.0), obstacle_material, "ObstacleC")

	for x in range(-12, 13, 4):
		_add_marker(Vector3(float(x), 0.025, -ARENA_HALF_SIZE + 0.04), Vector3(0.08, 0.05, 0.8))
		_add_marker(Vector3(float(x), 0.025, ARENA_HALF_SIZE - 0.04), Vector3(0.08, 0.05, 0.8))
	for z in range(-12, 13, 4):
		_add_marker(Vector3(-ARENA_HALF_SIZE + 0.04, 0.025, float(z)), Vector3(0.8, 0.05, 0.08))
		_add_marker(Vector3(ARENA_HALF_SIZE - 0.04, 0.025, float(z)), Vector3(0.8, 0.05, 0.08))


func _add_static_box(pos: Vector3, box_size: Vector3, material: StandardMaterial3D, node_name: String) -> StaticBody3D:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = node_name
	body.position = pos

	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = box_size
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)

	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = box_size
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	body.add_child(instance)

	add_child(body)
	return body


func _add_marker(pos: Vector3, marker_size: Vector3) -> void:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = marker_size
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.position = pos
	instance.mesh = mesh
	instance.material_override = pickup_material
	add_child(instance)


func _build_player() -> void:
	player_body = CharacterBody3D.new()
	player_body.name = "PlayerBody"
	player_body.floor_snap_length = 0.2
	add_child(player_body)

	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = 0.42
	capsule.height = 1.6
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.shape = capsule
	player_body.add_child(collision)

	player_visual = Node3D.new()
	player_body.add_child(player_visual)
	player_meshes.clear()

	var body_mesh: CylinderMesh = CylinderMesh.new()
	body_mesh.top_radius = 0.32
	body_mesh.bottom_radius = 0.42
	body_mesh.height = 1.0
	var body_instance: MeshInstance3D = MeshInstance3D.new()
	body_instance.position = Vector3(0.0, -0.05, 0.0)
	body_instance.mesh = body_mesh
	body_instance.material_override = player_material
	player_visual.add_child(body_instance)
	player_meshes.append(body_instance)

	var head_mesh: SphereMesh = SphereMesh.new()
	head_mesh.radius = 0.34
	head_mesh.height = 0.68
	var head_instance: MeshInstance3D = MeshInstance3D.new()
	head_instance.position = Vector3(0.0, 0.6, 0.0)
	head_instance.mesh = head_mesh
	head_instance.material_override = player_material
	player_visual.add_child(head_instance)
	player_meshes.append(head_instance)

	var nose_mesh: BoxMesh = BoxMesh.new()
	nose_mesh.size = Vector3(0.18, 0.12, 0.58)
	var nose_instance: MeshInstance3D = MeshInstance3D.new()
	nose_instance.position = Vector3(0.0, 0.2, -0.46)
	nose_instance.mesh = nose_mesh
	nose_instance.material_override = pickup_material
	player_visual.add_child(nose_instance)


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.fov = 62.0
	camera.current = true
	add_child(camera)


func _build_ui() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	add_child(layer)

	var root: Control = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)

	score_label = _make_label(Vector2(24.0, 18.0), Vector2(260.0, 34.0), 27, HORIZONTAL_ALIGNMENT_LEFT)
	root.add_child(score_label)

	health_label = _make_label(Vector2(708.0, 18.0), Vector2(228.0, 34.0), 24, HORIZONTAL_ALIGNMENT_RIGHT)
	root.add_child(health_label)

	status_label = _make_label(Vector2(260.0, 18.0), Vector2(440.0, 34.0), 22, HORIZONTAL_ALIGNMENT_CENTER)
	root.add_child(status_label)

	help_label = _make_label(Vector2(0.0, 492.0), Vector2(960.0, 30.0), 18, HORIZONTAL_ALIGNMENT_CENTER)
	help_label.text = "WASD MOVE   SHIFT SPRINT   SPACE JUMP   R RESET"
	root.add_child(help_label)


func _make_label(pos: Vector2, label_size: Vector2, font_size: int, alignment: HorizontalAlignment) -> Label:
	var label: Label = Label.new()
	label.position = pos
	label.size = label_size
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(0.9, 0.96, 1.0, 1.0))
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.75))
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
	hit_recovery = maxf(0.0, hit_recovery - delta)

	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var move_direction: Vector3 = Vector3(input_vector.x, 0.0, input_vector.y)
	if move_direction.length_squared() > 1.0:
		move_direction = move_direction.normalized()

	var target_speed: float = SPRINT_SPEED if Input.is_action_pressed("sprint") else MOVE_SPEED
	var target_velocity: Vector3 = move_direction * target_speed
	var velocity: Vector3 = player_body.velocity
	var blend: float = 1.0 - exp(-11.0 * delta)

	velocity.x = lerpf(velocity.x, target_velocity.x, blend)
	velocity.z = lerpf(velocity.z, target_velocity.z, blend)

	if player_body.is_on_floor():
		if velocity.y < 0.0:
			velocity.y = -0.15
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_SPEED
			_set_status("JUMP ARC", 0.6)
	else:
		velocity.y -= GRAVITY * delta

	player_body.velocity = velocity
	player_body.move_and_slide()

	if move_direction.length_squared() > 0.001:
		var target_rotation: float = atan2(move_direction.x, move_direction.z)
		player_visual.rotation.y = lerp_angle(player_visual.rotation.y, target_rotation, blend)

	_apply_player_material(_player_blink_material())


func _spawn_pickup() -> void:
	var pickup: Node3D = Node3D.new()
	pickup.position = _random_ground_point(1.0)

	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.32
	mesh.height = 0.64
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = pickup_material
	pickup.add_child(instance)

	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.72, 0.18, 1.0)
	light.light_energy = 0.95
	light.omni_range = 3.2
	pickup.add_child(light)

	add_child(pickup)
	pickups.append(pickup)
	pickup_phases.append(rng.randf_range(0.0, TAU))


func _spawn_hazard(index: int) -> void:
	var hazard: Node3D = Node3D.new()
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.46
	mesh.height = 0.92
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = hazard_material
	hazard.add_child(instance)

	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.12, 0.08, 1.0)
	light.light_energy = 1.4
	light.omni_range = 4.2
	hazard.add_child(light)

	add_child(hazard)
	hazards.append(hazard)
	hazard_angles.append(float(index) * TAU / float(HAZARD_COUNT))
	hazard_radii.append(rng.randf_range(3.4, 8.8))
	hazard_speeds.append(rng.randf_range(0.55, 0.95) * (1.0 if index % 2 == 0 else -1.0))
	hazard_centers.append(Vector3(rng.randf_range(-2.5, 2.5), 0.75, rng.randf_range(-2.5, 2.5)))


func _update_pickups(delta: float) -> void:
	for index in range(pickups.size()):
		var pickup: Node3D = pickups[index]
		var phase: float = pickup_phases[index] + delta * 2.4
		pickup_phases[index] = phase
		pickup.position.y = 0.82 + sin(phase) * 0.16
		pickup.rotation.y += delta * 1.8
		pickup.rotation.x = sin(phase * 0.7) * 0.24


func _update_hazards(delta: float) -> void:
	for index in range(hazards.size()):
		hazard_angles[index] += hazard_speeds[index] * delta
		var angle: float = hazard_angles[index]
		var radius: float = hazard_radii[index]
		var center: Vector3 = hazard_centers[index]
		var offset: Vector3 = Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)
		var hazard: Node3D = hazards[index]
		hazard.position = center + offset
		hazard.position.y = 0.78 + sin(angle * 2.0) * 0.18
		hazard.rotation.y += delta * 2.6


func _check_pickups() -> void:
	var collected: Array[Node3D] = []
	for pickup in pickups:
		if player_body.global_position.distance_to(pickup.global_position) <= 1.05:
			collected.append(pickup)

	for pickup in collected:
		pickups.erase(pickup)
		pickup.queue_free()
		score += 1
		_set_status("CORE COLLECTED", 0.75)
		_spawn_pickup()


func _check_hazards() -> void:
	if hit_recovery > 0.0:
		return

	for hazard in hazards:
		if player_body.global_position.distance_to(hazard.global_position) <= 1.08:
			_take_hit(hazard.global_position)
			return


func _check_bounds() -> void:
	if player_body.global_position.y < -4.0:
		_take_hit(Vector3.ZERO)
		player_body.global_position = Vector3(0.0, 1.25, 0.0)
		player_body.velocity = Vector3.ZERO


func _take_hit(source_position: Vector3) -> void:
	health = maxi(0, health - 1)
	hit_recovery = HIT_RECOVERY
	_set_status("HIT: PHYSICS KNOCKBACK", 1.1)

	var knockback: Vector3 = player_body.global_position - source_position
	knockback.y = 0.0
	if knockback.length_squared() < 0.001:
		knockback = Vector3.FORWARD
	player_body.velocity += knockback.normalized() * 9.0 + Vector3.UP * 3.5

	if health <= 0:
		_end_test("3D TEST FAILED")


func _update_clock(delta: float) -> void:
	time_left = maxf(0.0, time_left - delta)
	status_timer = maxf(0.0, status_timer - delta)

	if status_timer <= 0.0 and not game_over:
		status_label.text = "3D TEST RUNNING"

	if time_left <= 0.0:
		_end_test("3D TEST COMPLETE")


func _end_test(message: String) -> void:
	game_over = true
	status_label.text = message
	help_label.text = "R RESET   2D TEST STILL EXISTS AT res://scenes/main.tscn"


func _set_status(message: String, duration: float) -> void:
	status_label.text = message
	status_timer = duration


func _update_camera(delta: float) -> void:
	var target: Vector3 = player_body.global_position + Vector3(0.0, 1.0, 0.0)
	var desired: Vector3 = player_body.global_position + Vector3(0.0, 8.2, 10.5)
	var blend: float = 1.0 - exp(-5.0 * delta)
	camera.global_position = camera.global_position.lerp(desired, blend)
	camera.look_at(target, Vector3.UP)


func _update_ui() -> void:
	score_label.text = "3D SCORE " + str(score).pad_zeros(3)
	health_label.text = "HULL " + str(health) + "/" + str(MAX_HEALTH) + "  " + _format_timer(time_left)


func _apply_player_material(material: StandardMaterial3D) -> void:
	for mesh_instance in player_meshes:
		mesh_instance.material_override = material


func _player_blink_material() -> StandardMaterial3D:
	if hit_recovery <= 0.0:
		return player_material

	if sin(hit_recovery * 32.0) > 0.0:
		return player_hot_material

	return player_material


func _random_ground_point(clearance: float) -> Vector3:
	for attempt in range(80):
		var point: Vector3 = Vector3(
			rng.randf_range(-ARENA_HALF_SIZE + 1.8, ARENA_HALF_SIZE - 1.8),
			0.82,
			rng.randf_range(-ARENA_HALF_SIZE + 1.8, ARENA_HALF_SIZE - 1.8)
		)
		if _is_point_clear(point, clearance):
			return point

	return Vector3(0.0, 0.82, 0.0)


func _is_point_clear(point: Vector3, clearance: float) -> bool:
	if player_body != null and player_body.global_position.distance_to(point) < clearance + 2.4:
		return false

	for pickup in pickups:
		if pickup.global_position.distance_to(point) < clearance + 1.5:
			return false

	for hazard in hazards:
		if hazard.global_position.distance_to(point) < clearance + 1.8:
			return false

	return true


func _format_timer(seconds: float) -> String:
	var whole: int = int(floor(seconds))
	var tenths: int = int(floor((seconds - whole) * 10.0))
	return "%02d.%01d" % [whole, tenths]
