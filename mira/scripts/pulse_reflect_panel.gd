class_name PulseReflectPanel
extends StaticBody3D

@export var panel_size: Vector3 = Vector3(0.4, 3.0, 2.8)
@export var panel_color: Color = Color(0.15, 0.2, 0.24, 1.0)


func _ready() -> void:
	if get_child_count() == 0:
		var collision: CollisionShape3D = CollisionShape3D.new()
		var shape: BoxShape3D = BoxShape3D.new()
		shape.size = panel_size
		collision.shape = shape
		add_child(collision)

		var mesh: BoxMesh = BoxMesh.new()
		mesh.size = panel_size
		var instance: MeshInstance3D = MeshInstance3D.new()
		instance.mesh = mesh
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = panel_color
		material.roughness = 0.2
		instance.material_override = material
		add_child(instance)
