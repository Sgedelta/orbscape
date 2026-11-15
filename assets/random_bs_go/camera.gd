extends Node3D

@export var target: Node3D
@export var mouse_sens := 0.003
@export var follow_speed := 8.0
@export var lower_limit = deg_to_rad(-60)
@export var upper_limit = deg_to_rad(30)


@onready var arm = $SpringArm

var vertical_rot = 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sens)
		
		vertical_rot -= event.relative.y * mouse_sens
		vertical_rot = clamp(vertical_rot, lower_limit, upper_limit)
		
		arm.rotation.x = vertical_rot
		
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	

func _process(delta: float) -> void:
	if target:
		global_position = global_position.lerp(target.global_position, 1.0 - exp(-follow_speed * delta))
