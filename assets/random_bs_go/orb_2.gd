extends RigidBody3D

@export var camera: Node3D
@export var cube_size := 1.0
@export var sphere_radius := 0.5
@export var roll_per_scroll := 0.3
@export var morph_per_radian := 0.01
@export_range(0.0, 1.0) var swap_threshold := 0.5

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collider: CollisionShape3D = $CollisionShape3D

var scroll := 0.0
var morph_progress := 0.0
var mat: ShaderMaterial
var is_sphere := false

func _ready() -> void:
	mat = mesh_instance.material_override as ShaderMaterial

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			scroll += 1.0
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scroll -= 1.0

func _physics_process(delta: float) -> void:
	if scroll != 0.0:
		var fwd := -camera.global_basis.z
		var axis := Vector3.UP.cross(fwd)
		apply_torque_impulse(axis * scroll * roll_per_scroll)
		scroll = 0.0

	morph_progress = clampf(morph_progress + angular_velocity.length() * delta * morph_per_radian, 0.0, 1.0)
	mat.set_shader_parameter("morph", morph_progress)

	if not is_sphere and morph_progress >= swap_threshold:
		var s := SphereShape3D.new()
		s.radius = sphere_radius
		collider.shape = s
		is_sphere = true
