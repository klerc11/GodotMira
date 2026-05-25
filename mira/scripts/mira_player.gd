class_name MiraPlayer
extends CharacterBody3D

@export var walk_speed: float = 8.3
@export var sprint_speed: float = 12.9
@export var acceleration_ground: float = 40.0
@export var acceleration_air: float = 14.0
@export var deceleration_ground: float = 28.0
@export var deceleration_air: float = 6.0
@export var jump_velocity: float = 6.48
@export var gravity_force: float = 21.0
@export var coyote_time: float = 0.14
@export var jump_buffer_time: float = 0.14
@export var landing_grace_time: float = 0.1
@export var wall_touch_grace_time: float = 0.18
@export var wall_touch_push: float = 6.4
@export var dash_speed: float = 22.0
@export var dash_decay: float = 7.2
@export var dash_cooldown_time: float = 0.6
@export var slide_kick_speed: float = 16.0
@export var slide_steer_speed: float = 7.2
@export var slide_decay_grounded: float = 3.6
@export var slide_decay_air: float = 9.5
@export var slide_dash_carry_ratio: float = 0.75
@export var slide_dash_carry_window: float = 0.24
@export var slide_max_boost_speed: float = 27.0
@export var slide_input_buffer_time: float = 0.16
@export var slide_drag_active: float = 0.62
@export var slide_drag_inactive: float = 0.055
@export var mouse_sensitivity_x: float = 0.0022
@export var mouse_sensitivity_y: float = 0.0019
@export var max_mouse_delta: float = 80.0
@export var max_mouse_turn_per_event: float = 0.14
@export var pitch_min: float = -0.55
@export var pitch_max: float = 0.72
@export var base_fov: float = 72.0
@export var max_fov: float = 86.0
@export var fov_response: float = 5.2
@export var slide_camera_drop: float = 0.18
@export var look_pad_sensitivity_x: float = 1.85
@export var look_pad_sensitivity_y: float = 1.45

var camera_yaw: float = PI
var camera_pitch: float = 0.08
var horizontal_velocity: Vector3 = Vector3.ZERO
var dash_velocity: Vector3 = Vector3.ZERO
var dash_carry_velocity: Vector3 = Vector3.ZERO
var dash_carry_timer: float = 0.0
var slide_velocity: Vector3 = Vector3.ZERO
var dash_cooldown: float = 0.0
var slide_visual: float = 0.0
var slide_input_buffer: float = 0.0
var sliding: bool = false
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var landing_grace_timer: float = 0.0
var wall_touch_timer: float = 0.0
var last_wall_normal: Vector3 = Vector3.ZERO
var input_enabled: bool = true
var mouse_ignore_events: int = 3
var metrics_dash_count: int = 0
var metrics_jump_count: int = 0
var metrics_wall_jump_count: int = 0
var metrics_slide_start_count: int = 0

var body_mesh: MeshInstance3D
var visor_mesh: MeshInstance3D
var camera_pivot: Node3D
var camera_arm: SpringArm3D
var camera_node: Camera3D


func _ready() -> void:
	_setup_collision()
	_setup_visuals()
	_setup_camera()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.physical_keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED
		mouse_ignore_events = 3
		return

	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseButton and event.pressed:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			mouse_ignore_events = 3
		return

	if not input_enabled:
		return

	if event is InputEventMouseMotion:
		if mouse_ignore_events > 0:
			mouse_ignore_events -= 1
			return
		var motion_x: float = clampf(event.relative.x, -max_mouse_delta, max_mouse_delta)
		var motion_y: float = clampf(event.relative.y, -max_mouse_delta, max_mouse_delta)
		camera_yaw -= clampf(motion_x * mouse_sensitivity_x, -max_mouse_turn_per_event, max_mouse_turn_per_event)
		camera_pitch -= clampf(motion_y * mouse_sensitivity_y, -max_mouse_turn_per_event, max_mouse_turn_per_event)
		camera_pitch = clampf(camera_pitch, pitch_min, pitch_max)


func physics_step(delta: float) -> void:
	_update_rotation()
	_update_look_from_controller(delta)

	var move_input: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down") if input_enabled else Vector2.ZERO
	var move_direction: Vector3 = _camera_relative_move(move_input)
	var grounded_before_move: bool = is_on_floor()
	var horizontal_speed: float = Vector2(horizontal_velocity.x, horizontal_velocity.z).length()

	if dash_cooldown > 0.0:
		dash_cooldown = maxf(0.0, dash_cooldown - delta)
	if dash_carry_timer > 0.0:
		dash_carry_timer = maxf(0.0, dash_carry_timer - delta)
	slide_input_buffer = maxf(0.0, slide_input_buffer - delta)
	coyote_timer = coyote_time if grounded_before_move else maxf(0.0, coyote_timer - delta)
	jump_buffer_timer = maxf(0.0, jump_buffer_timer - delta)
	landing_grace_timer = maxf(0.0, landing_grace_timer - delta)
	wall_touch_timer = maxf(0.0, wall_touch_timer - delta)
	if is_on_wall_only():
		wall_touch_timer = wall_touch_grace_time
		last_wall_normal = get_wall_normal()
	if grounded_before_move:
		landing_grace_timer = landing_grace_time

	if input_enabled and Input.is_action_just_pressed("dash"):
		_try_dash(move_direction)
	if input_enabled and Input.is_action_just_pressed("slide"):
		slide_input_buffer = slide_input_buffer_time
	if input_enabled and Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time

	var has_slide_intent: bool = _wants_slide() or slide_input_buffer > 0.0
	var has_momentum_for_slide: bool = move_direction.length_squared() > 0.0 or horizontal_speed > 2.2 or dash_carry_timer > 0.0 or dash_velocity.length() > 0.5
	var slide_intent: bool = input_enabled and has_slide_intent and grounded_before_move and has_momentum_for_slide
	if slide_intent and not sliding:
		_start_slide(move_direction)
		metrics_slide_start_count += 1
		slide_input_buffer = 0.0
	sliding = slide_intent

	var slide_target: float = 1.0 if sliding else 0.0
	slide_visual = lerpf(slide_visual, slide_target, 1.0 - pow(0.0008, delta))

	var dash_damp: float = exp(-dash_decay * delta)
	dash_velocity *= dash_damp
	if dash_velocity.length() < 0.05:
		dash_velocity = Vector3.ZERO

	slide_velocity *= pow(slide_drag_active if sliding else slide_drag_inactive, delta)
	if slide_velocity.length() < 0.05:
		slide_velocity = Vector3.ZERO

	var wants_sprint: bool = input_enabled and Input.is_action_pressed("sprint") and not sliding
	var target_speed: float = sprint_speed if wants_sprint else walk_speed
	var steer_speed: float = slide_steer_speed if sliding else target_speed
	var desired_horizontal: Vector3 = move_direction * steer_speed
	var accel_rate: float = acceleration_ground if grounded_before_move else acceleration_air
	var decel_rate: float = deceleration_ground if grounded_before_move else deceleration_air
	var blend: float = 1.0 - exp(-((accel_rate if desired_horizontal.length_squared() > 0.0 else decel_rate) * delta))
	horizontal_velocity = horizontal_velocity.lerp(desired_horizontal, blend)

	velocity.x = horizontal_velocity.x + dash_velocity.x + slide_velocity.x
	velocity.z = horizontal_velocity.z + dash_velocity.z + slide_velocity.z

	if _consume_jump_request() and not sliding:
		if grounded_before_move or coyote_timer > 0.0 or landing_grace_timer > 0.0:
			velocity.y = jump_velocity
			metrics_jump_count += 1
			coyote_timer = 0.0
			landing_grace_timer = 0.0
		elif wall_touch_timer > 0.0 and last_wall_normal.length_squared() > 0.001:
			var wall_push: Vector3 = Vector3(last_wall_normal.x, 0.0, last_wall_normal.z).normalized() * wall_touch_push
			velocity.x += wall_push.x
			velocity.z += wall_push.z
			velocity.y = jump_velocity * 0.92
			metrics_jump_count += 1
			metrics_wall_jump_count += 1
			wall_touch_timer = 0.0
	else:
		velocity.y -= gravity_force * delta

	var was_grounded: bool = grounded_before_move
	move_and_slide()
	if not was_grounded and is_on_floor():
		landing_grace_timer = landing_grace_time
	_update_visual_state()
	_update_camera_motion(delta)


func set_input_enabled(enabled: bool) -> void:
	input_enabled = enabled
	if not enabled:
		horizontal_velocity = Vector3.ZERO
		dash_velocity = Vector3.ZERO
		dash_carry_velocity = Vector3.ZERO
		dash_carry_timer = 0.0
		slide_velocity = Vector3.ZERO
		slide_input_buffer = 0.0
		sliding = false


func reset_to(spawn_position: Vector3, start_yaw: float, start_pitch: float) -> void:
	global_position = spawn_position
	velocity = Vector3.ZERO
	horizontal_velocity = Vector3.ZERO
	dash_velocity = Vector3.ZERO
	dash_carry_velocity = Vector3.ZERO
	dash_carry_timer = 0.0
	slide_velocity = Vector3.ZERO
	slide_input_buffer = 0.0
	jump_buffer_timer = 0.0
	coyote_timer = 0.0
	wall_touch_timer = 0.0
	landing_grace_timer = 0.0
	sliding = false
	camera_yaw = start_yaw
	camera_pitch = start_pitch
	slide_visual = 0.0
	mouse_ignore_events = 3
	_update_rotation()


func get_eye_position() -> Vector3:
	return camera_pivot.global_position


func get_horizontal_aim_direction() -> Vector3:
	var forward: Vector3 = -camera_node.global_transform.basis.z
	forward.y = 0.0
	return forward.normalized() if forward.length() > 0.001 else Vector3.FORWARD


func is_pulse_in_reflect_radius(pulse_position: Vector3, reflect_radius: float) -> bool:
	return get_eye_position().distance_to(pulse_position) <= reflect_radius


func _wants_slide() -> bool:
	return Input.is_action_pressed("slide")


func _try_dash(move_direction: Vector3) -> void:
	if dash_cooldown > 0.0:
		return
	var dash_direction: Vector3 = move_direction if move_direction.length() > 0.01 else get_horizontal_aim_direction()
	dash_velocity = dash_direction.normalized() * dash_speed
	dash_carry_velocity = dash_velocity
	dash_carry_timer = slide_dash_carry_window
	dash_cooldown = dash_cooldown_time
	metrics_dash_count += 1


func _start_slide(move_direction: Vector3) -> void:
	var slide_direction: Vector3 = move_direction if move_direction.length() > 0.01 else get_horizontal_aim_direction()
	slide_velocity += slide_direction.normalized() * slide_kick_speed
	var carry_velocity: Vector3 = dash_velocity
	if dash_carry_timer > 0.0 and dash_carry_velocity.length_squared() > carry_velocity.length_squared():
		carry_velocity = dash_carry_velocity
	slide_velocity += carry_velocity * slide_dash_carry_ratio
	dash_carry_timer = 0.0
	if slide_velocity.length() > slide_max_boost_speed:
		slide_velocity = slide_velocity.normalized() * slide_max_boost_speed


func _camera_relative_move(input_value: Vector2) -> Vector3:
	var forward: Vector3 = -camera_node.global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var right: Vector3 = camera_node.global_transform.basis.x
	right.y = 0.0
	right = right.normalized()
	# Input.get_vector returns -1 for the "up/forward" action, so invert Y for world-forward movement.
	var move: Vector3 = right * input_value.x - forward * input_value.y
	return move.normalized() if move.length() > 0.001 else Vector3.ZERO


func _consume_jump_request() -> bool:
	if jump_buffer_timer <= 0.0:
		return false
	jump_buffer_timer = 0.0
	return true


func _update_look_from_controller(delta: float) -> void:
	if not input_enabled:
		return
	var look_x: float = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	var look_y: float = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	if absf(look_x) < 0.02 and absf(look_y) < 0.02:
		return
	camera_yaw -= look_x * look_pad_sensitivity_x * delta
	camera_pitch -= look_y * look_pad_sensitivity_y * delta
	camera_pitch = clampf(camera_pitch, pitch_min, pitch_max)


func _update_rotation() -> void:
	rotation.y = camera_yaw
	camera_pivot.rotation.x = camera_pitch


func _setup_collision() -> void:
	var shape: CapsuleShape3D = CapsuleShape3D.new()
	shape.radius = 0.34
	shape.height = 1.05
	var collider: CollisionShape3D = CollisionShape3D.new()
	collider.shape = shape
	collider.position = Vector3(0.0, 0.86, 0.0)
	add_child(collider)


func _setup_visuals() -> void:
	body_mesh = MeshInstance3D.new()
	var capsule_mesh: CapsuleMesh = CapsuleMesh.new()
	capsule_mesh.radius = 0.34
	capsule_mesh.height = 1.05
	body_mesh.mesh = capsule_mesh
	body_mesh.position = Vector3(0.0, 0.86, 0.0)
	body_mesh.material_override = _make_material(Color(0.1647, 0.1922, 0.2196, 1.0), Color(0.2902, 0.2627, 0.3765, 1.0), 0.08)
	add_child(body_mesh)

	visor_mesh = MeshInstance3D.new()
	var sphere_mesh: SphereMesh = SphereMesh.new()
	sphere_mesh.radius = 0.22
	sphere_mesh.height = 0.44
	visor_mesh.mesh = sphere_mesh
	visor_mesh.position = Vector3(0.0, 1.28, -0.26)
	visor_mesh.material_override = _make_material(Color(0.5608, 1.0, 0.8196, 1.0), Color(0.9373, 1.0, 0.9725, 1.0), 0.28)
	add_child(visor_mesh)

	var shoulder_left: MeshInstance3D = MeshInstance3D.new()
	var shoulder_right: MeshInstance3D = MeshInstance3D.new()
	var shoulder_mesh: SphereMesh = SphereMesh.new()
	shoulder_mesh.radius = 0.08
	shoulder_mesh.height = 0.16
	shoulder_left.mesh = shoulder_mesh
	shoulder_right.mesh = shoulder_mesh
	shoulder_left.position = Vector3(-0.22, 1.18, -0.06)
	shoulder_right.position = Vector3(0.22, 1.18, -0.06)
	shoulder_left.material_override = _make_material(Color(0.2941, 0.3294, 0.3647, 1.0), Color(0.2902, 0.2627, 0.3765, 1.0), 0.08)
	shoulder_right.material_override = _make_material(Color(0.2941, 0.3294, 0.3647, 1.0), Color(0.2902, 0.2627, 0.3765, 1.0), 0.08)
	add_child(shoulder_left)
	add_child(shoulder_right)


func _setup_camera() -> void:
	camera_pivot = Node3D.new()
	camera_pivot.position = Vector3(0.0, 1.42, 0.0)
	add_child(camera_pivot)

	camera_arm = SpringArm3D.new()
	camera_arm.spring_length = 4.6
	camera_arm.margin = 0.24
	camera_pivot.add_child(camera_arm)

	camera_node = Camera3D.new()
	camera_node.position = Vector3(0.0, 0.18, 0.0)
	camera_node.current = true
	camera_arm.add_child(camera_node)


func _update_visual_state() -> void:
	if body_mesh == null:
		return
	var crouch_scale: float = 0.72 + (1.0 - slide_visual) * 0.28
	body_mesh.scale.y = crouch_scale


func _update_camera_motion(delta: float) -> void:
	if camera_node == null or camera_pivot == null:
		return
	var planar_speed: float = Vector2(velocity.x, velocity.z).length()
	var speed_ratio: float = clampf(planar_speed / maxf(0.001, sprint_speed + dash_speed * 0.45), 0.0, 1.0)
	var target_fov: float = lerpf(base_fov, max_fov, speed_ratio)
	camera_node.fov = lerpf(camera_node.fov, target_fov, 1.0 - exp(-fov_response * delta))
	camera_pivot.position.y = lerpf(camera_pivot.position.y, 1.42 - slide_visual * slide_camera_drop, 1.0 - exp(-11.0 * delta))


func drain_metrics_events() -> Dictionary:
	var events: Dictionary = {
		"dash": metrics_dash_count,
		"jump": metrics_jump_count,
		"wall_jump": metrics_wall_jump_count,
		"slide_start": metrics_slide_start_count,
		"sliding": sliding,
		"grounded": is_on_floor(),
		"wall_touching": is_on_wall_only()
	}
	metrics_dash_count = 0
	metrics_jump_count = 0
	metrics_wall_jump_count = 0
	metrics_slide_start_count = 0
	return events


func _make_material(albedo: Color, emission: Color, emission_energy: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = albedo
	material.emission_enabled = true
	material.emission = emission
	material.emission_energy_multiplier = emission_energy
	material.roughness = 0.25
	return material
