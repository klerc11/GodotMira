class_name SceneLevelSpec
extends Node3D

@export var spawn_point_path: NodePath = NodePath("SpawnPoint")
@export var source_point_path: NodePath = NodePath("SourcePoint")
@export var target_point_path: NodePath = NodePath("TargetPoint")
@export var bounds_min_path: NodePath = NodePath("WorldBounds/Min")
@export var bounds_max_path: NodePath = NodePath("WorldBounds/Max")
@export var platforms_root_path: NodePath = NodePath("Platforms")
@export var absorbers_root_path: NodePath = NodePath("Absorbers")
@export var use_scene_platform_nodes: bool = true
@export var scene_platforms_root_path: NodePath = NodePath("Platforms")
@export var use_scene_absorber_nodes: bool = true
@export var scene_absorbers_root_path: NodePath = NodePath("Absorbers")

@export var fire_zone_radius: float = 2.2
@export var fire_zone_size: Vector2 = Vector2(46.0, 6.2)
@export var platform_support_towers: bool = true
@export var platform_support_ground_y: float = -1.0
@export var env_preset: String = "clear"
@export var fog_near: float = 28.0
@export var fog_far: float = 96.0
@export var include_scene_environment_shapes: bool = true
@export var scene_environment_root_path: NodePath = NodePath("EnvironmentShapes")
@export var build_runtime_world_boundaries: bool = false
@export var build_runtime_backdrop: bool = false
@export var build_runtime_level_art: bool = false
@export var build_runtime_source_zone_visuals: bool = false
@export var build_runtime_target_zone_visuals: bool = false
@export var build_runtime_global_lighting: bool = false
@export var handoff_to_runtime_scene_on_play: bool = true
@export var runtime_scene_path: String = "res://mira/scenes/mira_game.tscn"


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if not handoff_to_runtime_scene_on_play:
		return
	if get_tree() == null:
		return
	# Only hand off when this level scene is launched directly.
	if get_tree().current_scene != self:
		return
	call_deferred("_handoff_to_runtime_scene")


func _handoff_to_runtime_scene() -> void:
	if runtime_scene_path.is_empty():
		return
	get_tree().change_scene_to_file(runtime_scene_path)


func build_level_spec() -> Dictionary:
	var spawn: Vector3 = _marker_position(spawn_point_path, Vector3(0.0, 0.35, 12.0))
	var source: Vector3 = _marker_position(source_point_path, Vector3(0.0, 1.58, 12.0))
	var target: Vector3 = _marker_position(target_point_path, Vector3(0.0, 1.58, -108.0))
	var bounds_min: Vector3 = _marker_position(bounds_min_path, Vector3(-24.0, -8.0, -132.0))
	var bounds_max: Vector3 = _marker_position(bounds_max_path, Vector3(24.0, 16.0, 24.0))

	var level_spec: Dictionary = {
		"spawn": spawn,
		"source": source,
		"target": target,
		"fire_zone_radius": fire_zone_radius,
		"fire_zone_size": fire_zone_size,
		"world_bounds_min": bounds_min,
		"world_bounds_max": bounds_max,
		"platform_support_towers": platform_support_towers,
		"platform_support_ground_y": platform_support_ground_y,
		"use_scene_platform_nodes": use_scene_platform_nodes,
		"scene_platforms_root_path": str(scene_platforms_root_path),
		"use_scene_absorber_nodes": use_scene_absorber_nodes,
		"scene_absorbers_root_path": str(scene_absorbers_root_path),
		"env_preset": env_preset,
		"fog_near": fog_near,
		"fog_far": fog_far,
		"include_scene_environment_shapes": include_scene_environment_shapes,
		"scene_environment_root_path": str(scene_environment_root_path),
		"build_runtime_world_boundaries": build_runtime_world_boundaries,
		"build_runtime_backdrop": build_runtime_backdrop,
		"build_runtime_level_art": build_runtime_level_art,
		"build_runtime_source_zone_visuals": build_runtime_source_zone_visuals,
		"build_runtime_target_zone_visuals": build_runtime_target_zone_visuals,
		"build_runtime_global_lighting": build_runtime_global_lighting,
		"platforms": _collect_boxes(platforms_root_path),
		"absorbers": _collect_boxes(absorbers_root_path)
	}
	return level_spec


func _marker_position(path: NodePath, fallback: Vector3) -> Vector3:
	var marker_node: Node3D = get_node_or_null(path) as Node3D
	if marker_node == null:
		return fallback
	return marker_node.position


func _collect_boxes(root_path: NodePath) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var root_node: Node = get_node_or_null(root_path)
	if root_node == null:
		return out

	for child_node in root_node.get_children():
		var node3d: Node3D = child_node as Node3D
		if node3d == null:
			continue

		var size: Vector3 = _extract_box_size(node3d)
		if size == Vector3.ZERO:
			continue

		out.append({
			"center": node3d.position,
			"size": size
		})

	return out


func _extract_box_size(node3d: Node3D) -> Vector3:
	if node3d is PlatformModule:
		return (node3d as PlatformModule).module_size

	var collider_size: Vector3 = _box_size_from_colliders(node3d)
	if collider_size != Vector3.ZERO:
		return collider_size

	return Vector3.ZERO


func _box_size_from_colliders(node3d: Node3D) -> Vector3:
	var colliders: Array[Node] = node3d.find_children("*", "CollisionShape3D", true, false)
	for collider_node in colliders:
		var collider: CollisionShape3D = collider_node as CollisionShape3D
		if collider == null:
			continue
		var box_shape: BoxShape3D = collider.shape as BoxShape3D
		if box_shape != null:
			return box_shape.size
	return Vector3.ZERO
