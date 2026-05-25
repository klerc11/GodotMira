class_name FieldPlayerShip
extends Node2D

var radius: float = 18.0
var speed: float = 245.0
var dash_speed: float = 760.0
var dash_duration: float = 0.15
var dash_cooldown_duration: float = 0.82
var velocity: Vector2 = Vector2.ZERO
var facing: Vector2 = Vector2.RIGHT

var _dash_time: float = 0.0
var _dash_cooldown: float = 0.0
var _trail: Array[Vector2] = []


func drive(input_vector: Vector2, delta: float, bounds: Rect2) -> void:
	if input_vector.length_squared() > 0.001:
		input_vector = input_vector.normalized()
		facing = input_vector

	_dash_time = maxf(0.0, _dash_time - delta)
	_dash_cooldown = maxf(0.0, _dash_cooldown - delta)

	var target_velocity: Vector2 = input_vector * speed
	if _dash_time > 0.0:
		target_velocity = facing * dash_speed

	var blend: float = 1.0 - exp(-14.0 * delta)
	velocity = velocity.lerp(target_velocity, blend)
	position += velocity * delta

	position.x = clampf(position.x, bounds.position.x + radius, bounds.end.x - radius)
	position.y = clampf(position.y, bounds.position.y + radius, bounds.end.y - radius)

	_trail.append(position)
	if _trail.size() > 11:
		_trail.pop_front()

	queue_redraw()


func start_dash() -> void:
	if not can_dash():
		return

	_dash_time = dash_duration
	_dash_cooldown = dash_cooldown_duration
	queue_redraw()


func can_dash() -> bool:
	return _dash_time <= 0.0 and _dash_cooldown <= 0.0


func dash_charge() -> float:
	if _dash_cooldown <= 0.0:
		return 1.0
	return 1.0 - clampf(_dash_cooldown / dash_cooldown_duration, 0.0, 1.0)


func clear_trail() -> void:
	_trail.clear()
	queue_redraw()


func _draw() -> void:
	for index in range(_trail.size()):
		var age: float = float(index + 1) / float(_trail.size())
		var trail_color: Color = Color(0.22, 0.72, 0.88, 0.04 + age * 0.17)
		draw_circle(_trail[index] - position, radius * (0.45 + age * 0.32), trail_color)

	var dash_glow: float = 0.22 if _dash_time <= 0.0 else 0.6
	draw_circle(Vector2.ZERO, radius + 8.0, Color(0.18, 0.66, 0.86, dash_glow))
	draw_circle(Vector2.ZERO, radius, Color(0.06, 0.1, 0.13, 1.0))
	draw_circle(Vector2.ZERO, radius - 5.0, Color(0.33, 0.86, 0.94, 1.0))

	var right: Vector2 = facing.normalized()
	if right.length_squared() < 0.001:
		right = Vector2.RIGHT
	var side: Vector2 = Vector2(-right.y, right.x)
	var nose: Vector2 = right * (radius + 9.0)
	var left_wing: Vector2 = -right * 9.0 + side * 11.0
	var right_wing: Vector2 = -right * 9.0 - side * 11.0
	draw_polygon(
		PackedVector2Array([nose, left_wing, right_wing]),
		PackedColorArray([Color(0.92, 0.98, 1.0), Color(0.22, 0.72, 0.88), Color(0.22, 0.72, 0.88)])
	)
