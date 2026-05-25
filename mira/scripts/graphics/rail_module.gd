@tool
class_name RailModule
extends Node3D

@export var module_size: Vector3 = Vector3(0.08, 0.08, 4.0)
@export var rail_material: Material

@onready var rail_mesh: MeshInstance3D = $RailMesh


func _ready() -> void:
	_apply()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_apply()


func configure(size_value: Vector3, rail_mat: Material) -> void:
	module_size = size_value
	rail_material = rail_mat
	_apply()


func _apply() -> void:
	if rail_mesh == null:
		return
	var box_mesh: BoxMesh = rail_mesh.mesh as BoxMesh
	if box_mesh != null:
		box_mesh.size = module_size
	rail_mesh.material_override = rail_material
