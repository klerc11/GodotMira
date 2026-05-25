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
var slide_particle_timer: float = 0.0
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var landing_grace_timer: float = 0.0
var wall_touch_timer: float = 0.0
var last_wall_normal: Vector3 = Vector3.ZERO
var mouse_ignore_events: int = 3
var spawn_position: Vector3 = Vector3.ZERO

var jump_down_prev: bool = false
var dash_down_prev: bool = false
var slide_down_prev: bool = false
var initial_camera_fov: float = 72.0
var initial_camera_pivot_y: float = 1.42

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_node: Camera3D = $CameraPivot/Camera3D
@onready var body_mesh: MeshInstance3D = $BodyMesh
@onready var slide_particles: GPUParticles3D = $SlideParticles


func _ready() -> void:
	spawn_position = global_position
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if camera_node != null:
		initial_camera_fov = camera_node.fov
	if camera_pivot != null:
		initial_camera_pivot_y = camera_pivot.position.y
	if camera_pivot != null:
		camera_pivot.rotation.x = camera_pitch
	_configure_slide_particles()
	_update_rotation()


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

	if event is InputEventMouseMotion:
		if mouse_ignore_events > 0:
			mouse_ignore_events -= 1
			return
		var motion_x: float = clampf(event.relative.x, -max_mouse_delta, max_mouse_delta)
		var motion_y: float = clampf(event.relative.y, -max_mouse_delta, max_mouse_delta)
		camera_yaw -= clampf(motion_x * mouse_sensitivity_x, -max_mouse_turn_per_event, max_mouse_turn_per_event)
		camera_pitch -= clampf(motion_y * mouse_sensitivity_y, -max_mouse_turn_per_event, max_mouse_turn_per_event)
		camera_pitch = clampf(camera_pitch, pitch_min, pitch_max)


func _physics_process(delta: float) -> void:
	_update_rotation()

	var move_input: Vector2 = _read_move_input()
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

	var jump_down: bool = Input.is_key_pressed(KEY_SPACE)
	var dash_down: bool = Input.is_key_pressed(KEY_SHIFT)
	var slide_down: bool = Input.is_key_pressed(KEY_C) or Input.is_key_pressed(KEY_ALT)
	var dash_pressed: bool = dash_down and not dash_down_prev
	var slide_pressed: bool = slide_down and not slide_down_prev
	var jump_pressed: bool = jump_down and not jump_down_prev
	dash_down_prev = dash_down
	slide_down_prev = slide_down
	jump_down_prev = jump_down

	if dash_pressed:
		_try_dash(move_direction)
	if slide_pressed:
		slide_input_buffer = slide_input_buffer_time
	if jump_pressed:
		jump_buffer_timer = jump_buffer_time

	var has_slide_intent: bool = slide_down or slide_input_buffer > 0.0
	var has_momentum_for_slide: bool = move_direction.length_squared() > 0.0 or horizontal_speed > 2.2 or dash_carry_timer > 0.0 or dash_velocity.length() > 0.5
	var slide_intent: bool = has_slide_intent and grounded_before_move and has_momentum_for_slide
	if slide_intent and not sliding:
		_start_slide(move_direction)
		slide_input_buffer = 0.0
		slide_particle_timer = 0.24
	sliding = slide_intent

	var slide_target: float = 1.0 if sliding else 0.0
	slide_visual = lerpf(slide_visual, slide_target, 1.0 - pow(0.0008, delta))
	slide_particle_timer = maxf(0.0, slide_particle_timer - delta)
	if slide_particles != null:
		var sprint_particles: bool = Input.is_key_pressed(KEY_CTRL) and grounded_before_move and horizontal_speed > 2.0
		slide_particles.global_position = global_position + Vector3(0.0, 0.1, 0.0)
		slide_particles.emitting = (sliding and grounded_before_move) or slide_particle_timer > 0.0 or sprint_particles

	var dash_damp: float = exp(-dash_decay * delta)
	dash_velocity *= dash_damp
	if dash_velocity.length() < 0.05:
		dash_velocity = Vector3.ZERO

	slide_velocity *= pow(slide_drag_active if sliding else slide_drag_inactive, delta)
	if slide_velocity.length() < 0.05:
		slide_velocity = Vector3.ZERO

	var wants_sprint: bool = Input.is_key_pressed(KEY_CTRL) and not sliding
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
			coyote_timer = 0.0
			landing_grace_timer = 0.0
		elif wall_touch_timer > 0.0 and last_wall_normal.length_squared() > 0.001:
			var wall_push: Vector3 = Vector3(last_wall_normal.x, 0.0, last_wall_normal.z).normalized() * wall_touch_push
			velocity.x += wall_push.x
			velocity.z += wall_push.z
			velocity.y = jump_velocity * 0.92
			wall_touch_timer = 0.0
	else:
		velocity.y -= gravity_force * delta

	var was_grounded: bool = grounded_before_move
	move_and_slide()
	if not was_grounded and is_on_floor():
		landing_grace_timer = landing_grace_time
	_update_camera_motion(delta)

	if Input.is_key_pressed(KEY_R):
		global_position = spawn_position
		velocity = Vector3.ZERO
		horizontal_velocity = Vector3.ZERO
		dash_velocity = Vector3.ZERO
		slide_velocity = Vector3.ZERO
	if global_position.y < -30.0:
		global_position = spawn_position
		velocity = Vector3.ZERO
		horizontal_velocity = Vector3.ZERO
		dash_velocity = Vector3.ZERO
		slide_velocity = Vector3.ZERO


func _read_move_input() -> Vector2:
	var move_x: float = 0.0
	move_x += 1.0 if Input.is_key_pressed(KEY_D) else 0.0
	move_x -= 1.0 if Input.is_key_pressed(KEY_A) else 0.0
	move_x += 1.0 if Input.is_key_pressed(KEY_RIGHT) else 0.0
	move_x -= 1.0 if Input.is_key_pressed(KEY_LEFT) else 0.0
	var move_y: float = 0.0
	move_y += 1.0 if Input.is_key_pressed(KEY_W) else 0.0
	move_y -= 1.0 if Input.is_key_pressed(KEY_S) else 0.0
	move_y += 1.0 if Input.is_key_pressed(KEY_UP) else 0.0
	move_y -= 1.0 if Input.is_key_pressed(KEY_DOWN) else 0.0
	var out_vec: Vector2 = Vector2(move_x, move_y)
	return out_vec.normalized() if out_vec.length_squared() > 1.0 else out_vec


func _try_dash(move_direction: Vector3) -> void:
	if dash_cooldown > 0.0:
		return
	var dash_direction: Vector3 = move_direction if move_direction.length() > 0.01 else get_horizontal_aim_direction()
	dash_velocity = dash_direction.normalized() * dash_speed
	dash_carry_velocity = dash_velocity
	dash_carry_timer = slide_dash_carry_window
	dash_cooldown = dash_cooldown_time


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
	var move: Vector3 = right * input_value.x + forward * input_value.y
	return move.normalized() if move.length() > 0.001 else Vector3.ZERO


func _consume_jump_request() -> bool:
	if jump_buffer_timer <= 0.0:
		return false
	jump_buffer_timer = 0.0
	return true


func _update_rotation() -> void:
	rotation.y = camera_yaw
	if camera_pivot != null:
		camera_pivot.rotation.x = camera_pitch


func get_horizontal_aim_direction() -> Vector3:
	var forward: Vector3 = -camera_node.global_transform.basis.z
	forward.y = 0.0
	return forward.normalized() if forward.length() > 0.001 else Vector3.FORWARD


func _update_camera_motion(delta: float) -> void:
	if camera_node == null or camera_pivot == null:
		return
	camera_node.fov = initial_camera_fov
	camera_pivot.position.y = initial_camera_pivot_y
	if body_mesh != null:
		body_mesh.scale.y = lerpf(body_mesh.scale.y, 0.72 + (1.0 - slide_visual) * 0.28, 1.0 - exp(-10.0 * delta))


func _configure_slide_particles() -> void:
	if slide_particles == null:
		return
	slide_particles.amount = 200
	slide_particles.lifetime = 0.58
	slide_particles.explosiveness = 0.0
	slide_particles.randomness = 0.85
	slide_particles.speed_scale = 1.0
	slide_particles.visibility_aabb = AABB(Vector3(-8.0, -2.0, -8.0), Vector3(16.0, 8.0, 16.0))
