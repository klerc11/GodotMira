class_name MiraPlayerController
extends CharacterBody3D

const MOUSE_SENSITIVITY: float = 0.0022
const MAX_PITCH: float = 1.46

@export var walk_speed: float = 7.6
@export var sprint_speed: float = 11.8
@export var jump_speed: float = 8.6
@export var gravity_force: float = 25.0
@export var dash_speed: float = 20.5
@export var dash_duration: float = 0.16
@export var dash_cooldown: float = 0.82
@export var slide_duration: float = 0.7
@export var slide_speed_boost: float = 3.0
@export var reflect_radius: float = 2.1

var camera_pitch: float = 0.0
var is_active: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var slide_timer: float = 0.0
var dash_direction: Vector3 = Vector3.ZERO
var active_camera: Camera3D
var audio_bus


func _ready() -> void:
	name = "MiraPlayer"
	floor_snap_length = 0.35

	var collision: CollisionShape3D = CollisionShape3D.new()
	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = 0.42
	capsule.height = 1.7
	collision.shape = capsule
	add_child(collision)

	active_camera = Camera3D.new()
	active_camera.position = Vector3(0.0, 0.7, 0.0)
	active_camera.fov = 74.0
	active_camera.current = true
	add_child(active_camera)


func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera_pitch = clampf(camera_pitch - event.relative.y * MOUSE_SENSITIVITY, -MAX_PITCH, MAX_PITCH)
		active_camera.rotation.x = camera_pitch


func physics_step(delta: float) -> void:
	dash_timer = maxf(0.0, dash_timer - delta)
	dash_cooldown_timer = maxf(0.0, dash_cooldown_timer - delta)
	slide_timer = maxf(0.0, slide_timer - delta)
	_apply_controller_look(delta)

	var basis: Basis = global_transform.basis
	var forward: Vector3 = -basis.z
	var right: Vector3 = basis.x
	forward.y = 0.0
	right.y = 0.0
	if forward.length_squared() > 0.0001:
		forward = forward.normalized()
	if right.length_squared() > 0.0001:
		right = right.normalized()

	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var move_direction: Vector3 = forward * -input_vector.y + right * input_vector.x
	if move_direction.length_squared() > 1.0:
		move_direction = move_direction.normalized()

	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0.0:
		var dash_basis: Vector3 = move_direction if move_direction.length_squared() > 0.001 else forward
		_start_dash(dash_basis)

	if Input.is_action_just_pressed("slide") and is_on_floor() and horizontal_speed() > 4.0 and slide_timer <= 0.0:
		_start_slide()

	var target_speed: float = sprint_speed if Input.is_action_pressed("sprint") else walk_speed
	var target_velocity: Vector3 = move_direction * target_speed
	var blend: float = 1.0 - exp(-11.0 * delta)

	if dash_timer > 0.0:
		target_velocity = dash_direction * dash_speed
	elif slide_timer > 0.0:
		var carry: Vector3 = horizontal_velocity()
		if carry.length_squared() > 0.001:
			target_velocity = carry.normalized() * (sprint_speed + slide_speed_boost)

	velocity.x = lerpf(velocity.x, target_velocity.x, blend)
	velocity.z = lerpf(velocity.z, target_velocity.z, blend)

	if is_on_floor():
		if velocity.y < 0.0:
			velocity.y = -0.18
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_speed
	else:
		velocity.y -= gravity_force * delta

	move_and_slide()
	_update_camera_height(delta)


func set_input_active(active: bool) -> void:
	is_active = active


func set_audio_bus(bus) -> void:
	audio_bus = bus


func reset_to_transform(target_transform: Transform3D) -> void:
	global_transform = target_transform
	velocity = Vector3.ZERO
	camera_pitch = 0.0
	active_camera.rotation = Vector3.ZERO
	dash_timer = 0.0
	dash_cooldown_timer = 0.0
	slide_timer = 0.0


func can_reflect_at(point: Vector3) -> bool:
	return global_position.distance_to(point) <= reflect_radius


func get_eye_position() -> Vector3:
	return active_camera.global_position


func horizontal_velocity() -> Vector3:
	return Vector3(velocity.x, 0.0, velocity.z)


func horizontal_speed() -> float:
	return horizontal_velocity().length()


func _start_dash(direction: Vector3) -> void:
	dash_direction = direction.normalized()
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	if audio_bus != null:
		audio_bus.play_dash()


func _start_slide() -> void:
	slide_timer = slide_duration
	if audio_bus != null:
		audio_bus.play_slide()


func _update_camera_height(delta: float) -> void:
	var target_height: float = 0.36 if slide_timer > 0.0 else 0.7
	active_camera.position.y = lerpf(active_camera.position.y, target_height, 1.0 - exp(-14.0 * delta))


func _apply_controller_look(delta: float) -> void:
	if not is_active:
		return

	var look_x: float = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	var look_y: float = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	if absf(look_x) < 0.02 and absf(look_y) < 0.02:
		return

	var sensitivity: float = 2.2 * delta
	rotate_y(-look_x * sensitivity)
	camera_pitch = clampf(camera_pitch - look_y * sensitivity, -MAX_PITCH, MAX_PITCH)
	active_camera.rotation.x = camera_pitch
