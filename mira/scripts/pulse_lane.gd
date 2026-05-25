class_name PulseLane
extends Node3D

@export var target_path: NodePath
@export var lane_color: Color = Color(0.26, 0.84, 1.0, 1.0)
@export var lane_radius: float = 0.14
@export var channel_width: float = 0.48
@export var channel_height: float = 0.045
@export var channel_y: float = 0.02


func _ready() -> void:
	_build_visuals()


func get_target():
	return get_node_or_null(target_path)


func get_route_points() -> Array[Vector3]:
	var points: Array[Vector3] = []
	var markers: Array[Node] = get_children()
	markers.sort_custom(func(a: Node, b: Node) -> bool: return a.name.naturalnocasecmp_to(b.name) < 0)
	for marker in markers:
		if marker is Marker3D:
			points.append((marker as Marker3D).global_position)
	var target = get_target()
	if target != null and target.has_method("get_anchor_position"):
		points.append(target.get_anchor_position())
	return points


func _build_visuals() -> void:
	var markers: Array[Node] = get_children()
	markers.sort_custom(func(a: Node, b: Node) -> bool: return a.name.naturalnocasecmp_to(b.name) < 0)
	if markers.size() < 2:
		return

	var channel_material: StandardMaterial3D = _make_material(lane_color, 0.55)
	var marker_material: StandardMaterial3D = _make_material(lane_color.lightened(0.16), 0.95)

	for marker_node in markers:
		if not (marker_node is Marker3D):
			continue
		var marker: Marker3D = marker_node as Marker3D
		var marker_mesh: CylinderMesh = CylinderMesh.new()
		marker_mesh.top_radius = channel_width * 0.42
		marker_mesh.bottom_radius = channel_width * 0.42
		marker_mesh.height = channel_height
		marker_mesh.radial_segments = 18

		var marker_instance: MeshInstance3D = MeshInstance3D.new()
		marker_instance.mesh = marker_mesh
		marker_instance.material_override = marker_material
		marker_instance.position = Vector3(marker.position.x, channel_y, marker.position.z)
		add_child(marker_instance)

	for index in range(markers.size() - 1):
		if not (markers[index] is Marker3D and markers[index + 1] is Marker3D):
			continue

		var from_point: Vector3 = (markers[index] as Marker3D).position
		var to_point: Vector3 = (markers[index + 1] as Marker3D).position
		from_point.y = channel_y
		to_point.y = channel_y
		var segment: Vector3 = to_point - from_point
		var length: float = segment.length()
		if length <= 0.001:
			continue

		var mesh: BoxMesh = BoxMesh.new()
		mesh.size = Vector3(channel_width, channel_height, length)

		var instance: MeshInstance3D = MeshInstance3D.new()
		instance.mesh = mesh
		instance.material_override = channel_material
		instance.position = from_point + segment * 0.5
		instance.transform.basis = Basis.looking_at(segment.normalized(), Vector3.UP)
		add_child(instance)


func _make_material(color: Color, emission_energy: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = emission_energy
	material.roughness = 0.26
	return material
