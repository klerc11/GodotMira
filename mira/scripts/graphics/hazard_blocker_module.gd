@tool
class_name HazardBlockerModule
extends Node3D

@export var module_size: Vector3 = Vector3(2.0, 2.0, 2.0)
@export var blocker_material: Material

@onready var body: StaticBody3D = $Body
@onready var collision_shape: CollisionShape3D = $Body/CollisionShape3D
@onready var blocker_mesh: MeshInstance3D = $Body/BlockerMesh


func _ready() -> void:
	_apply()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_apply()


func configure(size_value: Vector3, blocker_mat: Material) -> void:
	module_size = size_value
	blocker_material = blocker_mat
	_apply()


func _apply() -> void:
	if collision_shape == null:
		return
	var shape: BoxShape3D = collision_shape.shape as BoxShape3D
	if shape != null:
		shape.size = module_size
	var box_mesh: BoxMesh = blocker_mesh.mesh as BoxMesh
	if box_mesh != null:
		box_mesh.size = module_size
	blocker_mesh.material_override = blocker_material
