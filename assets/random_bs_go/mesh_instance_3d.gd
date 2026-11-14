@tool
extends MeshInstance3D

@export_range(0.0, 1.0, 0.001) var morph: float = 0.0:
	set(value):
		morph = value
		do_morph()

func _ready() -> void:
	do_morph()

func do_morph() -> void:
	var mat := material_override as ShaderMaterial
	mat.set_shader_parameter("morph", morph)
	mat.set_shader_parameter("half_size", mesh.size.x * 0.5)
