class_name FieldSpark
extends Node2D

var radius: float = 11.0
var value: int = 1
var phase: float = 0.0


func setup(seed_phase: float, spark_value: int) -> void:
	phase = seed_phase
	value = spark_value


func collection_radius() -> float:
	return radius + 8.0


func _process(delta: float) -> void:
	phase += delta
	rotation += delta * 0.75
	queue_redraw()


func _draw() -> void:
	var shimmer: float = 0.5 + sin(phase * 5.5) * 0.5
	var core_color: Color = Color(1.0, 0.88, 0.26, 1.0)
	var glow_color: Color = Color(1.0, 0.64, 0.12, 0.20 + shimmer * 0.14)

	draw_circle(Vector2.ZERO, radius + shimmer * 7.0, glow_color)
	draw_circle(Vector2.ZERO, radius, core_color)
	draw_circle(Vector2.ZERO, radius * 0.42, Color(1.0, 1.0, 0.78, 1.0))

	for index in range(4):
		var angle: float = float(index) * TAU * 0.25
		var inner: Vector2 = Vector2(cos(angle), sin(angle)) * (radius + 2.0)
		var outer: Vector2 = Vector2(cos(angle), sin(angle)) * (radius + 9.0 + shimmer * 4.0)
		draw_line(inner, outer, Color(1.0, 0.92, 0.48, 0.7), 2.0, true)
