@tool
extends Node3D

@export_range(0.0, 1.0, 0.001) var morph: float = 0.0:
	set(value):
		morph = value
		_apply_morph()

@export var mesh_instance: MeshInstance3D

func _ready() -> void:
	_apply_morph()

func _apply_morph() -> void:
	mesh_instance.set_blend_shape_value(0, morph)
