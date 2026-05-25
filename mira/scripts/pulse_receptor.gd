class_name PulseReceptor
extends "res://mira/scripts/mira_pulse_target.gd"

@export var receptor_color: Color = Color(1.0, 0.58, 0.28, 1.0)


func _ready() -> void:
	var base_mesh: CylinderMesh = CylinderMesh.new()
	base_mesh.top_radius = 0.78
	base_mesh.bottom_radius = 0.94
	base_mesh.height = 0.46
	var base: MeshInstance3D = MeshInstance3D.new()
	base.position = Vector3(0.0, 0.23, 0.0)
	base.mesh = base_mesh
	base.material_override = _make_material(Color(0.2, 0.2, 0.2, 1.0), 0.0)
	add_child(base)

	var receptor_mesh: TorusMesh = TorusMesh.new()
	receptor_mesh.inner_radius = 0.28
	receptor_mesh.outer_radius = 0.58
	var receptor: MeshInstance3D = MeshInstance3D.new()
	receptor.position = Vector3(0.0, 0.82, 0.0)
	receptor.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	receptor.mesh = receptor_mesh
	receptor.material_override = _make_material(receptor_color, 0.95)
	add_child(receptor)


func get_target_kind() -> String:
	return "receptor"


func _make_material(color: Color, emission_energy: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = emission_energy
	return material
