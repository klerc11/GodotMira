class_name LevelResetZone
extends Area3D

@export var box_size: Vector3 = Vector3(60.0, 8.0, 60.0)


func _ready() -> void:
	monitoring = true
	if get_child_count() == 0:
		var collision: CollisionShape3D = CollisionShape3D.new()
		var shape: BoxShape3D = BoxShape3D.new()
		shape.size = box_size
		collision.shape = shape
		add_child(collision)
