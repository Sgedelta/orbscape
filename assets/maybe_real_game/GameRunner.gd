extends Node3D

var ended = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_ending_area_body_exited(body: Node3D) -> void:
	if not body.is_in_group("player") or ended:
		print("NOT ENDING")
		return
	print("ENDING")
	ended = true
	var endTween = create_tween()
	endTween.tween_interval(3)
	endTween.tween_callback(Callable(%EndSong, "play"))
	endTween.tween_property(%EndSong, "volume_db", 0.0, 25).from(-40)
	endTween.parallel().tween_callback(Callable(self, "_set_ending_orbs_visible")).set_delay(10)
	endTween.tween_property(%Blackout, "modulate", Color.WHITE, 20).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	endTween.tween_callback(Callable(self, "_end_game"))
	endTween.tween_property(%Blackout, "modulate", Color(1,1,1,0), 3)

func _set_ending_orbs_visible() :
	for orb in get_tree().get_nodes_in_group("end_orbs"):
		orb.freeze = false
		orb.visible = true

func _end_game() :
	get_tree().call_group("player", "reset_self_for_endgame")
