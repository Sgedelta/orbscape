extends Path3D

@export var window: Node3D
@export var follower: PathFollow3D
@export var camera: Camera3D

@export var duration := 8.0

func _ready() -> void:
	var start := camera.global_position
	var top := Vector3(start.x, window.global_position.y, start.z)
	var push_dir := Vector3(window.global_position.x - start.x, 0.0, window.global_position.z - start.z).normalized()
	var inside := window.global_position + push_dir * 20

	var new_curve := Curve3D.new()
	new_curve.add_point(start)
	new_curve.add_point(Vector3(top.x, top.y, top.z - 10))
	new_curve.add_point(inside)
	curve = new_curve

	follower.rotation_mode = PathFollow3D.ROTATION_NONE
	follower.loop = false
	follower.progress_ratio = 0.0
	camera.position = Vector3.ZERO

	create_tween().tween_property(follower, "progress_ratio", 1.0, duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
