@tool
class_name MirrorFrameModule
extends Node3D

@export var width: float = 3.4
@export var height: float = 2.0
@export var frame_thickness: float = 0.2
@export var plate_material: Material
@export var frame_material: Material
@export var accent_material: Material

@onready var plate: MeshInstance3D = $Plate
@onready var frame_top: MeshInstance3D = $FrameTop
@onready var frame_bottom: MeshInstance3D = $FrameBottom
@onready var frame_left: MeshInstance3D = $FrameLeft
@onready var frame_right: MeshInstance3D = $FrameRight
@onready var accent: MeshInstance3D = $Accent


func _ready() -> void:
	_apply()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_apply()


func configure(width_value: float, height_value: float, plate_mat: Material, frame_mat: Material, accent_mat: Material) -> void:
	width = width_value
	height = height_value
	plate_material = plate_mat
	frame_material = frame_mat
	accent_material = accent_mat
	_apply()


func _apply() -> void:
	if plate == null:
		return
	_set_box_size(plate, Vector3(width, height, 0.06))
	plate.material_override = plate_material

	_set_box_size(frame_top, Vector3(width + frame_thickness * 2.0, frame_thickness, 0.14))
	_set_box_size(frame_bottom, Vector3(width + frame_thickness * 2.0, frame_thickness, 0.14))
	_set_box_size(frame_left, Vector3(frame_thickness, height, 0.14))
	_set_box_size(frame_right, Vector3(frame_thickness, height, 0.14))
	frame_top.position = Vector3(0.0, height * 0.5 + frame_thickness * 0.5, 0.0)
	frame_bottom.position = Vector3(0.0, -height * 0.5 - frame_thickness * 0.5, 0.0)
	frame_left.position = Vector3(-width * 0.5 - frame_thickness * 0.5, 0.0, 0.0)
	frame_right.position = Vector3(width * 0.5 + frame_thickness * 0.5, 0.0, 0.0)
	frame_top.material_override = frame_material
	frame_bottom.material_override = frame_material
	frame_left.material_override = frame_material
	frame_right.material_override = frame_material

	_set_box_size(accent, Vector3(width * 0.7, 0.08, 0.12))
	accent.position = Vector3(0.0, 0.0, 0.02)
	accent.material_override = accent_material


func _set_box_size(mesh_instance: MeshInstance3D, size_value: Vector3) -> void:
	var box_mesh: BoxMesh = mesh_instance.mesh as BoxMesh
	if box_mesh != null:
		box_mesh.size = size_value
