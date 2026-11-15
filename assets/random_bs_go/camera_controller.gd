extends Node3D

@export var sensitivity = .003;
@export var lower_limit = deg_to_rad(-30)
@export var upper_limit = deg_to_rad(30)

@onready var arm = $SpringArm

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var rot_y = event.relative.y
		var rot_x = event.relative.x
		
		
	
	pass
