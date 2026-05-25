class_name PulseMirror
extends "res://mira/scripts/mira_pulse_target.gd"

@export var mirror_color: Color = Color(0.72, 0.9, 1.0, 1.0)
@export var panel_size: Vector2 = Vector2(1.95, 1.35)

var panel_material: StandardMaterial3D

func _ready() -> void:
	var back_frame_mesh: BoxMesh = BoxMesh.new()
	back_frame_mesh.size = Vector3(panel_size.x + 0.18, panel_size.y + 0.18, 0.12)
	var back_frame: MeshInstance3D = MeshInstance3D.new()
	back_frame.mesh = back_frame_mesh
	back_frame.position = Vector3(0.0, 0.88, 0.0)
	back_frame.material_override = _make_material(Color(0.16, 0.22, 0.28, 1.0), 0.0)
	add_child(back_frame)

	var panel_mesh: BoxMesh = BoxMesh.new()
	panel_mesh.size = Vector3(panel_size.x, panel_size.y, 0.035)
	var panel: MeshInstance3D = MeshInstance3D.new()
	panel.mesh = panel_mesh
	panel.position = Vector3(0.0, 0.88, 0.01)
	panel_material = _make_material(mirror_color, 0.88)
	panel.material_override = panel_material
	add_child(panel)

	var bounce_tick_mesh: BoxMesh = BoxMesh.new()
	bounce_tick_mesh.size = Vector3(0.18, panel_size.y * 0.76, 0.05)
	var bounce_tick: MeshInstance3D = MeshInstance3D.new()
	bounce_tick.mesh = bounce_tick_mesh
	bounce_tick.position = Vector3(0.0, 0.88, 0.04)
	bounce_tick.material_override = _make_material(Color(0.95, 0.99, 1.0, 1.0), 1.15)
	add_child(bounce_tick)

	_orient_from_route()


func get_target_kind() -> String:
	return "mirror"


func _make_material(color: Color, emission_energy: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.18
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = emission_energy
	return material


func _orient_from_route() -> void:
	var incoming_direction: Vector3 = _find_incoming_direction()
	var outgoing_direction: Vector3 = _find_outgoing_direction()
	if incoming_direction == Vector3.ZERO or outgoing_direction == Vector3.ZERO:
		return

	var mirror_normal: Vector3 = (incoming_direction - outgoing_direction).normalized()
	mirror_normal.y = 0.0
	if mirror_normal.length() <= 0.01:
		return
	look_at(global_position + mirror_normal.normalized(), Vector3.UP)


func _find_incoming_direction() -> Vector3:
	var parent_node: Node = get_parent()
	if parent_node == null:
		return Vector3.ZERO

	for child_node in parent_node.get_children():
		if not (child_node is PulseLane):
			continue
		var lane: PulseLane = child_node as PulseLane
		if lane.get_target() != self:
			continue
		var lane_points: Array[Vector3] = lane.get_route_points()
		if lane_points.size() < 2:
			continue
		var previous_point: Vector3 = lane_points[lane_points.size() - 2]
		var direction: Vector3 = (global_position - previous_point).normalized()
		direction.y = 0.0
		if direction.length() > 0.01:
			return direction.normalized()
	return Vector3.ZERO


func _find_outgoing_direction() -> Vector3:
	var next_lane: PulseLane = get_outgoing_lane() as PulseLane
	if next_lane == null:
		return Vector3.ZERO
	var lane_points: Array[Vector3] = next_lane.get_route_points()
	if lane_points.is_empty():
		return Vector3.ZERO
	var next_point: Vector3 = lane_points[0]
	var direction: Vector3 = (next_point - global_position).normalized()
	direction.y = 0.0
	return direction.normalized() if direction.length() > 0.01 else Vector3.ZERO
