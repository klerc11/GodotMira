@tool
class_name WallModule
extends Node3D

@export var module_size: Vector3 = Vector3(2.0, 4.0, 12.0)
@export var wall_material: Material
@export var rail_material: Material

@onready var body: StaticBody3D = $Body
@onready var collision_shape: CollisionShape3D = $Body/CollisionShape3D
@onready var wall_mesh: MeshInstance3D = $Body/WallMesh
@onready var rail_mesh: MeshInstance3D = $Body/RailMesh


func _ready() -> void:
	_apply()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_apply()


func configure(size_value: Vector3, wall_mat: Material, rail_mat: Material) -> void:
	module_size = size_value
	wall_material = wall_mat
	rail_material = rail_mat
	_apply()


func _apply() -> void:
	if collision_shape == null:
		return
	var shape: BoxShape3D = collision_shape.shape as BoxShape3D
	if shape != null:
		shape.size = module_size

	var wall_box: BoxMesh = wall_mesh.mesh as BoxMesh
	if wall_box != null:
		wall_box.size = module_size
	wall_mesh.material_override = wall_material

	var rail_box: BoxMesh = rail_mesh.mesh as BoxMesh
	if rail_box != null:
		rail_box.size = Vector3(module_size.x, maxf(0.16, module_size.y * 0.1), module_size.z)
	rail_mesh.position = Vector3(0.0, -module_size.y * 0.45, 0.0)
	rail_mesh.material_override = rail_material
