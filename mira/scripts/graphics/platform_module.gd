@tool
class_name PlatformModule
extends Node3D

@export var module_size: Vector3 = Vector3(4.0, 0.6, 4.0)
@export var base_material: Material
@export var trim_material: Material

@onready var body: StaticBody3D = $Body
@onready var collision_shape: CollisionShape3D = $Body/CollisionShape3D
@onready var base_mesh: MeshInstance3D = $Body/BaseMesh
@onready var trim_mesh: MeshInstance3D = $Body/TrimMesh


func _ready() -> void:
	_apply()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_apply()


func configure(size_value: Vector3, base_mat: Material, trim_mat: Material) -> void:
	module_size = size_value
	base_material = base_mat
	trim_material = trim_mat
	_apply()


func _apply() -> void:
	if collision_shape == null:
		return
	var shape: BoxShape3D = collision_shape.shape as BoxShape3D
	if shape != null:
		shape.size = module_size
	var box_mesh: BoxMesh = base_mesh.mesh as BoxMesh
	if box_mesh != null:
		box_mesh.size = module_size
	base_mesh.material_override = base_material

	var trim_box: BoxMesh = trim_mesh.mesh as BoxMesh
	if trim_box != null:
		trim_box.size = Vector3(module_size.x * 0.94, maxf(0.03, module_size.y * 0.18), module_size.z * 0.94)
	trim_mesh.position = Vector3(0.0, module_size.y * 0.42, 0.0)
	trim_mesh.material_override = trim_material
