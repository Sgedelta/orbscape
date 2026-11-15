extends Control

@export var game_scene : PackedScene
@export var images : Array[Texture2D]
@export var seconds_per_image := 2.0
@export var fade_time := 0.3

@onready var picture : TextureRect = %Picture

var _done := false

func _ready() -> void:
	picture.modulate.a = 0.0
	for i in range(images.size()):
		if _done: return
		picture.texture = images[i]
		var t := create_tween()
		if i==0:
			t.tween_property(picture, "modulate:a", 1.0, fade_time)
		t.tween_interval(seconds_per_image)
		if i == images.size() - 1:
			t.tween_property(picture, "modulate:a", 0.0, fade_time)
		await t.finished
	_finish()

func _finish() -> void:
	if _done: return
	_done = true
	get_tree().change_scene_to_packed(game_scene)
