class_name FieldHazardRing
extends Node2D

var base_radius: float = 42.0
var pulse: float = 0.0
var spin: float = 1.0


func setup(size: float, seed_phase: float, spin_speed: float) -> void:
	base_radius = size
	pulse = seed_phase
	spin = spin_speed


func active_radius() -> float:
	return base_radius + sin(pulse * 3.6) * 7.0


func _process(delta: float) -> void:
	pulse += delta
	rotation += spin * delta
	queue_redraw()


func _draw() -> void:
	var current_radius: float = active_radius()
	var hot: float = 0.55 + sin(pulse * 5.0) * 0.25

	draw_circle(Vector2.ZERO, current_radius, Color(0.94, 0.13, 0.13, 0.10 + hot * 0.05))
	draw_arc(Vector2.ZERO, current_radius, 0.0, TAU * 0.72, 80, Color(1.0, 0.21, 0.18, 0.75), 4.0, true)
	draw_arc(Vector2.ZERO, current_radius * 0.72, TAU * 0.08, TAU * 0.86, 70, Color(1.0, 0.46, 0.25, 0.34), 2.0, true)
	draw_circle(Vector2.ZERO, 4.0 + hot * 2.0, Color(1.0, 0.42, 0.25, 0.9))
