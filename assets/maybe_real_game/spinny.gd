extends StaticBody3D

@export_range(-180, 180, 0.1, "radians_as_degrees") var speed;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation.y += speed * delta
	pass
