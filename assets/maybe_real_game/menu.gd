extends Control

@export var game_scene : PackedScene;
@export_range(-180.0, 180.0, 0.1, "radians_as_degrees") var title_rotate_speed = deg_to_rad(33)

@onready var title_rect : TextureRect = %TitleDisp

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	title_rect.rotation += title_rotate_speed * delta;
	
	pass


func on_play():
	get_tree().change_scene_to_packed(game_scene)
