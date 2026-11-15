extends Control

@export var game_scene : PackedScene
@export var images : Array[Texture2D]
@export var seconds_per_image := 2.0
@export var fade_time := 0.3

@onready var picture : TextureRect = %Picture

var _done := false

func _ready() -> void:
	picture.modulate.a = 0.0
	for img in images:
		if _done: return
		picture.texture = img
		var t := create_tween()
		t.tween_property(picture, "modulate:a", 1.0, fade_time)
		t.tween_interval(seconds_per_image)
		t.tween_property(picture, "modulate:a", 0.0, fade_time)
		await t.finished
	_finish()

func _finish() -> void:
	if _done: return
	_done = true
	get_tree().change_scene_to_packed(game_scene)
