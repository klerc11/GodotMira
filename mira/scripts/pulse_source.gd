class_name PulseSource
extends "res://mira/scripts/mira_pulse_target.gd"

@export var launch_color: Color = Color(0.18, 0.88, 1.0, 1.0)


func _ready() -> void:
	var ring_mesh: CylinderMesh = CylinderMesh.new()
	ring_mesh.top_radius = 0.82
	ring_mesh.bottom_radius = 0.82
	ring_mesh.height = 0.1
	ring_mesh.radial_segments = 20

	var ring: MeshInstance3D = MeshInstance3D.new()
	ring.mesh = ring_mesh
	ring.material_override = _make_material(launch_color, 0.9)
	add_child(ring)

	var core_mesh: SphereMesh = SphereMesh.new()
	core_mesh.radius = 0.22
	core_mesh.height = 0.44
	var core: MeshInstance3D = MeshInstance3D.new()
	core.position = Vector3(0.0, 0.32, 0.0)
	core.mesh = core_mesh
	core.material_override = _make_material(Color(0.9, 0.98, 1.0, 1.0), 0.3)
	add_child(core)


func _make_material(color: Color, emission_energy: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = emission_energy
	return material
