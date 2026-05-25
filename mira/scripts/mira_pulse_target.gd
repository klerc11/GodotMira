class_name MiraPulseTarget
extends Node3D

@export var outgoing_lane_path: NodePath


func get_outgoing_lane():
	if outgoing_lane_path == NodePath():
		return null
	return get_node_or_null(outgoing_lane_path)


func get_anchor_position() -> Vector3:
	return global_position


func get_target_kind() -> String:
	return "target"
