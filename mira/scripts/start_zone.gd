class_name StartZone
extends Area3D

@export var zone_radius: float = 2.7


func _ready() -> void:
	monitoring = true

	if get_child_count() == 0:
		var collision: CollisionShape3D = CollisionShape3D.new()
		var shape: CylinderShape3D = CylinderShape3D.new()
		shape.radius = zone_radius
		shape.height = 2.2
		collision.shape = shape
		add_child(collision)

	var ring_mesh: CylinderMesh = CylinderMesh.new()
	ring_mesh.top_radius = zone_radius
	ring_mesh.bottom_radius = zone_radius
	ring_mesh.height = 0.08
	ring_mesh.radial_segments = 28
	var ring: MeshInstance3D = MeshInstance3D.new()
	ring.mesh = ring_mesh
	ring.material_override = _make_material(Color(0.18, 0.72, 0.95, 1.0))
	add_child(ring)


func contains_point(point: Vector3) -> bool:
	return global_position.distance_to(point) <= zone_radius


func _make_material(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 0.38
	return material
