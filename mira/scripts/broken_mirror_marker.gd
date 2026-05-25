class_name BrokenMirrorMarker
extends "res://mira/scripts/mira_pulse_target.gd"

@export var reflect_radius: float = 2.1
@export var reflect_window: float = 0.9
@export var marker_color: Color = Color(1.0, 0.76, 0.22, 1.0)
@export var marker_radius: float = 0.84

var is_active: bool = false
var panel_material: StandardMaterial3D


func _ready() -> void:
	var floor_mesh: CylinderMesh = CylinderMesh.new()
	floor_mesh.top_radius = marker_radius
	floor_mesh.bottom_radius = marker_radius
	floor_mesh.height = 0.09
	floor_mesh.radial_segments = 20
	var floor_pad: MeshInstance3D = MeshInstance3D.new()
	floor_pad.mesh = floor_mesh
	floor_pad.material_override = _make_material(marker_color.darkened(0.28), 0.22)
	add_child(floor_pad)

	var ring_mesh: TorusMesh = TorusMesh.new()
	ring_mesh.inner_radius = marker_radius * 0.64
	ring_mesh.outer_radius = marker_radius * 0.96
	var ring: MeshInstance3D = MeshInstance3D.new()
	ring.mesh = ring_mesh
	ring.position = Vector3(0.0, 0.06, 0.0)
	ring.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	panel_material = _make_material(marker_color, 0.7)
	ring.material_override = panel_material
	add_child(ring)


func set_active(active: bool) -> void:
	is_active = active
	if panel_material != null:
		panel_material.emission_energy_multiplier = 1.22 if active else 0.7
	var scale_value: float = 1.08 if active else 1.0
	scale = Vector3.ONE * scale_value


func get_target_kind() -> String:
	return "broken"


func _make_material(color: Color, emission_energy: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = emission_energy
	return material
