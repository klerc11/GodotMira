class_name FieldFloatingText
extends Label

var velocity: Vector2 = Vector2(0.0, -58.0)
var life: float = 0.82
var max_life: float = 0.82


func setup(message: String, start_position: Vector2, tint: Color) -> void:
	text = message
	position = start_position
	modulate = tint
	z_index = 50
	add_theme_font_size_override("font_size", 20)
	add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.75))
	add_theme_constant_override("shadow_offset_x", 2)
	add_theme_constant_override("shadow_offset_y", 2)


func _process(delta: float) -> void:
	position += velocity * delta
	life -= delta
	modulate.a = clampf(life / max_life, 0.0, 1.0)
	if life <= 0.0:
		queue_free()
