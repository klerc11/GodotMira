@tool
class_name TrimModule
extends Node3D

@export var module_size: Vector3 = Vector3(4.0, 0.06, 0.12)
@export var trim_material: Material

@onready var trim_mesh: MeshInstance3D = $TrimMesh


func _ready() -> void:
	_apply()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_apply()


func configure(size_value: Vector3, trim_mat: Material) -> void:
	module_size = size_value
	trim_material = trim_mat
	_apply()


func _apply() -> void:
	if trim_mesh == null:
		return
	var box_mesh: BoxMesh = trim_mesh.mesh as BoxMesh
	if box_mesh != null:
		box_mesh.size = module_size
	trim_mesh.material_override = trim_material
