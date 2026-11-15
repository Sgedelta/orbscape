extends TextureRect

@export var cam_path : Path3D 
@export var next_scene : PackedScene
@export var fade_rect : ColorRect
@export var fade_time := 0.8

var _done := false

func _ready() -> void:
	fade_rect.color = Color(0, 0, 0, 0)
	cam_path.cinematic_done.connect(_finish)

func _finish() -> void:
	if _done: return
	_done = true
	var t := create_tween()
	t.tween_property(fade_rect, "color:a", 1.0, fade_time)
	await t.finished
	get_tree().change_scene_to_packed(next_scene)
