class_name GoldenRouteLevel
extends Node3D

@export var start_zone_path: NodePath
@export var source_path: NodePath
@export var reset_zone_path: NodePath
@export var spawn_point_path: NodePath


func get_start_zone():
	return get_node_or_null(start_zone_path)


func get_source():
	return get_node_or_null(source_path)


func get_reset_zone():
	return get_node_or_null(reset_zone_path)


func get_spawn_transform() -> Transform3D:
	var spawn_point = get_node_or_null(spawn_point_path)
	if spawn_point is Marker3D:
		return (spawn_point as Marker3D).global_transform
	return global_transform
