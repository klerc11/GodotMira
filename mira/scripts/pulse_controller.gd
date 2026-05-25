class_name PulseController
extends Node3D

signal pulse_failed
signal pulse_completed
signal prompt_changed(prompt_text)

enum PulseState { IDLE, TRAVELING, TRAVELING_FREE, FAILED, COMPLETED }

@export var base_speed: float = 10.0
@export var max_speed: float = 21.0
@export var speed_decay: float = 2.0
@export var max_stability: float = 7.0
@export var stability_drain_per_second: float = 1.05
@export var player_reflect_refresh: float = 3.1
@export var reflect_input_buffer: float = 0.2
@export var late_reflect_extra_time: float = 0.8
@export var late_reflect_max_distance: float = 9.5

var level
var player
var audio_bus
var source
var pulse_state: PulseState = PulseState.IDLE
var active_lane
var active_target
var route_points: Array[Vector3] = []
var route_index: int = 0
var pulse_speed: float = 0.0
var stability: float = 0.0
var reflect_marker
var reflect_buffer: float = 0.0
var free_travel_direction: Vector3 = Vector3.ZERO
var late_reflect_timer: float = 0.0
var _last_prompt: String = ""
var pulse_light: OmniLight3D
var pulse_mesh: MeshInstance3D
var pulse_hum: AudioStreamPlayer3D
var trail_meshes: Array[MeshInstance3D] = []
var trail_history: Array[Vector3] = []


func _ready() -> void:
	pulse_mesh = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.2
	sphere.height = 0.4
	pulse_mesh.mesh = sphere
	add_child(pulse_mesh)

	pulse_light = OmniLight3D.new()
	pulse_light.light_energy = 2.0
	pulse_light.omni_range = 7.0
	add_child(pulse_light)

	for index in range(10):
		var trail: MeshInstance3D = MeshInstance3D.new()
		var mesh: SphereMesh = SphereMesh.new()
		mesh.radius = 0.12
		mesh.height = 0.24
		trail.mesh = mesh
		trail.visible = false
		add_child(trail)
		trail_meshes.append(trail)

	hide_pulse()


func _exit_tree() -> void:
	if pulse_hum != null:
		pulse_hum.stop()
		pulse_hum.stream = null
		pulse_hum.queue_free()
		pulse_hum = null


func configure(level_node, player_node, audio_node) -> void:
	level = level_node
	player = player_node
	audio_bus = audio_node
	source = level.get_source()

	if pulse_hum != null:
		pulse_hum.queue_free()
	pulse_hum = audio_bus.create_pulse_hum_player()
	add_child(pulse_hum)
	pulse_hum.play()
	pulse_hum.stream_paused = true

	reset_to_idle()


func tick(delta: float, start_zone_active: bool) -> void:
	if pulse_state == PulseState.IDLE:
		_update_prompt(start_zone_active)
		return

	reflect_buffer = maxf(0.0, reflect_buffer - delta)
	pulse_speed = maxf(base_speed, pulse_speed - speed_decay * delta)
	stability = maxf(0.0, stability - stability_drain_per_second * delta)
	if stability <= 0.0 and pulse_state != PulseState.COMPLETED:
		fail_pulse()
		return

	if pulse_state == PulseState.TRAVELING:
		_travel_along_route(delta)
	elif pulse_state == PulseState.TRAVELING_FREE:
		_travel_free(delta)

	_update_visuals(delta)
	_update_prompt(start_zone_active)


func request_action(start_zone_active: bool) -> void:
	buffer_reflect_input()
	if pulse_state == PulseState.IDLE:
		if not start_zone_active or source == null:
			return
		launch()


func buffer_reflect_input() -> void:
	reflect_buffer = reflect_input_buffer


func launch() -> void:
	pulse_state = PulseState.TRAVELING
	pulse_speed = base_speed
	stability = max_stability
	global_position = source.get_anchor_position() + Vector3(0.0, 0.42, 0.0)
	_begin_lane(source.get_outgoing_lane())
	if audio_bus != null:
		audio_bus.play_launch()


func reset_to_idle() -> void:
	pulse_state = PulseState.IDLE
	active_lane = null
	active_target = null
	route_points.clear()
	route_index = 0
	pulse_speed = 0.0
	stability = 0.0
	reflect_marker = null
	reflect_buffer = 0.0
	free_travel_direction = Vector3.ZERO
	late_reflect_timer = 0.0
	trail_history.clear()
	if pulse_hum != null:
		pulse_hum.stream_paused = true
	hide_pulse()
	_update_prompt(true)


func fail_pulse() -> void:
	pulse_state = PulseState.FAILED
	if reflect_marker != null and reflect_marker.has_method("set_active"):
		reflect_marker.set_active(false)
	reflect_marker = null
	if audio_bus != null:
		audio_bus.play_fail()
	reset_to_idle()
	pulse_failed.emit()


func perform_player_reflect() -> void:
	if reflect_marker == null:
		return

	reflect_marker.set_active(false)
	stability = minf(max_stability, stability + player_reflect_refresh)
	pulse_speed = minf(max_speed, pulse_speed * 1.18)
	reflect_buffer = 0.0
	late_reflect_timer = 0.0
	free_travel_direction = Vector3.ZERO
	if audio_bus != null:
		audio_bus.play_reflect()

	var next_lane = reflect_marker.get_outgoing_lane()
	reflect_marker = null
	pulse_state = PulseState.TRAVELING
	_begin_lane(next_lane)


func _begin_lane(lane) -> void:
	active_lane = lane
	if active_lane == null:
		fail_pulse()
		return

	active_target = active_lane.get_target()
	route_points = active_lane.get_route_points()
	route_index = 0
	if route_points.is_empty():
		fail_pulse()
		return

	show_pulse()


func _travel_along_route(delta: float) -> void:
	var remaining: float = pulse_speed * delta
	while remaining > 0.0 and route_index < route_points.size():
		var target_point: Vector3 = route_points[route_index]
		var offset: Vector3 = target_point - global_position
		var distance: float = offset.length()

		if distance <= remaining:
			global_position = target_point
			remaining -= distance
			route_index += 1
			if route_index >= route_points.size():
				_resolve_target()
				return
		else:
			global_position += offset.normalized() * remaining
			remaining = 0.0


func _resolve_target() -> void:
	if active_target == null:
		fail_pulse()
		return

	var target_kind: String = active_target.get_target_kind() if active_target != null and active_target.has_method("get_target_kind") else ""

	if target_kind == "mirror":
		stability = max_stability
		pulse_speed = minf(max_speed, pulse_speed * 1.1)
		if audio_bus != null:
			audio_bus.play_bounce()
		_begin_lane(active_target.get_outgoing_lane())
		return

	if target_kind == "broken":
		reflect_marker = active_target
		reflect_marker.set_active(true)
		var player_in_range: bool = player != null and player.can_reflect_at(global_position)
		var reflect_pressed: bool = _has_reflect_intent()
		if player_in_range and reflect_pressed:
			perform_player_reflect()
			return
		_begin_late_reflect_travel()
		return

	if target_kind == "receptor":
		pulse_state = PulseState.COMPLETED
		if audio_bus != null:
			audio_bus.play_complete()
		pulse_completed.emit()
		return

	fail_pulse()


func _update_visuals(delta: float) -> void:
	trail_history.push_front(global_position)
	if trail_history.size() > trail_meshes.size():
		trail_history.resize(trail_meshes.size())

	var speed_t: float = inverse_lerp(base_speed, max_speed, pulse_speed)
	var stable_t: float = clampf(stability / max_stability, 0.0, 1.0)
	var pulse_color: Color = Color(0.18, 0.86, 1.0, 1.0).lerp(Color(1.0, 0.48, 0.58, 1.0), speed_t)
	pulse_color = pulse_color.lerp(Color(1.0, 0.78, 0.18, 1.0), 1.0 - stable_t)
	var pulse_scale: float = 0.85 + speed_t * 0.35 + sin(Time.get_ticks_msec() * 0.012) * 0.04
	scale = Vector3.ONE * pulse_scale

	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = pulse_color
	material.emission_enabled = true
	material.emission = pulse_color
	material.emission_energy_multiplier = 1.35
	pulse_mesh.material_override = material
	pulse_light.light_color = pulse_color
	pulse_light.light_energy = 1.8 + speed_t * 1.3

	for index in range(trail_meshes.size()):
		var trail: MeshInstance3D = trail_meshes[index]
		if index >= trail_history.size():
			trail.visible = false
			continue
		trail.visible = true
		trail.position = to_local(trail_history[index])
		var trail_material: StandardMaterial3D = StandardMaterial3D.new()
		trail_material.albedo_color = pulse_color
		trail_material.emission_enabled = true
		trail_material.emission = pulse_color
		trail_material.emission_energy_multiplier = 0.5
		trail.material_override = trail_material
		var fade: float = 1.0 - float(index + 1) / float(trail_meshes.size() + 1)
		trail.scale = Vector3.ONE * (0.2 + fade * 0.35)

	if pulse_hum != null:
		pulse_hum.stream_paused = false
		pulse_hum.global_position = global_position
		pulse_hum.pitch_scale = 0.9 + speed_t * 0.85
		pulse_hum.volume_db = linear_to_db(0.07 + stable_t * 0.08)


func _update_prompt(start_zone_active: bool) -> void:
	var prompt: String = ""
	if pulse_state == PulseState.IDLE:
		prompt = "LMB / X TO LAUNCH" if start_zone_active else "RETURN TO START ZONE"
	elif pulse_state == PulseState.TRAVELING and active_target != null and active_target.has_method("get_target_kind") and active_target.get_target_kind() == "broken":
		prompt = "INTERCEPT + CLICK / HOLD REFLECT"
	elif pulse_state == PulseState.TRAVELING_FREE:
		prompt = "INTERCEPT + CLICK / HOLD REFLECT"

	if prompt != _last_prompt:
		_last_prompt = prompt
		prompt_changed.emit(prompt)


func show_pulse() -> void:
	visible = true
	if pulse_hum != null:
		pulse_hum.stream_paused = false


func hide_pulse() -> void:
	visible = false
	for trail in trail_meshes:
		trail.visible = false


func _begin_late_reflect_travel() -> void:
	pulse_state = PulseState.TRAVELING_FREE
	free_travel_direction = _get_arrival_direction()
	if free_travel_direction.is_zero_approx():
		free_travel_direction = Vector3.FORWARD
	late_reflect_timer = reflect_marker.reflect_window + late_reflect_extra_time if reflect_marker != null else 0.0


func _travel_free(delta: float) -> void:
	if reflect_marker == null:
		fail_pulse()
		return

	late_reflect_timer -= delta
	if late_reflect_timer <= 0.0:
		fail_pulse()
		return

	if global_position.distance_to(reflect_marker.get_anchor_position()) > late_reflect_max_distance:
		fail_pulse()
		return

	if _player_can_reflect_current_pulse() and _has_reflect_intent():
		perform_player_reflect()
		return

	global_position += free_travel_direction * pulse_speed * delta

	if _player_can_reflect_current_pulse() and _has_reflect_intent():
		perform_player_reflect()


func _player_can_reflect_current_pulse() -> bool:
	return player != null and player.can_reflect_at(global_position)


func _has_reflect_intent() -> bool:
	return reflect_buffer > 0.0 or Input.is_action_pressed("launch_reflect")


func _get_arrival_direction() -> Vector3:
	if route_points.size() >= 2:
		var last_point: Vector3 = route_points[route_points.size() - 1]
		var previous_point: Vector3 = route_points[route_points.size() - 2]
		var direction: Vector3 = (last_point - previous_point).normalized()
		if not direction.is_zero_approx():
			return direction

	if route_index > 0 and route_index < route_points.size():
		var from_point: Vector3 = route_points[route_index - 1]
		var to_point: Vector3 = route_points[route_index]
		var direction_mid: Vector3 = (to_point - from_point).normalized()
		if not direction_mid.is_zero_approx():
			return direction_mid

	return Vector3.ZERO
