class_name FieldChaserDrone
extends Node2D

var radius: float = 15.0
var speed: float = 112.0
var turn_rate: float = 6.8
var velocity: Vector2 = Vector2.ZERO
var phase: float = 0.0
var stun_time: float = 0.0
var threat_scale: float = 1.0


func setup(seed_phase: float, speed_scale: float) -> void:
	phase = seed_phase
	threat_scale = speed_scale
	speed *= speed_scale


func update_ai(target_position: Vector2, delta: float, bounds: Rect2, heat: float, slow_factor: float) -> void:
	phase += delta
	stun_time = maxf(0.0, stun_time - delta)

	var offset: Vector2 = target_position - position
	var distance: float = maxf(offset.length(), 0.001)
	var direction: Vector2 = offset / distance
	var orbit: Vector2 = Vector2(-direction.y, direction.x) * sin(phase * 2.4) * 46.0
	var desired_velocity: Vector2 = direction * (speed + heat * 42.0) * slow_factor + orbit * slow_factor

	if stun_time > 0.0:
		desired_velocity *= -0.2

	var blend: float = 1.0 - exp(-turn_rate * delta)
	velocity = velocity.lerp(desired_velocity, blend)
	position += velocity * delta

	position.x = clampf(position.x, bounds.position.x + radius, bounds.end.x - radius)
	position.y = clampf(position.y, bounds.position.y + radius, bounds.end.y - radius)
	queue_redraw()


func knock_back(from_position: Vector2) -> void:
	var offset: Vector2 = position - from_position
	if offset.length_squared() < 0.001:
		offset = Vector2.RIGHT

	velocity = offset.normalized() * 230.0
	stun_time = 0.38
	queue_redraw()


func _draw() -> void:
	var hot: float = 0.5 + sin(phase * 5.0) * 0.25
	var body_color: Color = Color(0.72, 0.22, 0.78, 1.0)
	var glow_color: Color = Color(0.96, 0.24, 0.82, 0.14 + hot * 0.12)
	var eye_color: Color = Color(1.0, 0.88, 0.35, 1.0)

	draw_circle(Vector2.ZERO, radius + 9.0, glow_color)
	draw_circle(Vector2.ZERO, radius, Color(0.12, 0.06, 0.14, 1.0))

	var points: PackedVector2Array = PackedVector2Array([
		Vector2(0.0, -radius - 6.0),
		Vector2(radius + 6.0, 0.0),
		Vector2(0.0, radius + 6.0),
		Vector2(-radius - 6.0, 0.0),
	])
	draw_polygon(points, PackedColorArray([body_color, body_color, body_color, body_color]))
	draw_circle(Vector2.ZERO, radius * 0.42, eye_color)

	if stun_time > 0.0:
		draw_arc(Vector2.ZERO, radius + 13.0, 0.0, TAU, 40, Color(0.85, 0.95, 1.0, 0.75), 2.0, true)
