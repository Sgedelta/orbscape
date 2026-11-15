extends SpotLight3D

@export var player: RigidBody3D
@export var checkpoints: Array[Vector3]
@export var speed := 3.0

var player_radius := 0.5
var _target := 0
var _caught := false

func _physics_process(delta: float) -> void:
	if _caught:
		return

	_patrol(delta)

	if _is_player_lit():
		_on_caught()

func _patrol(delta: float) -> void:
	var goal : Vector3 = checkpoints[_target]
	global_position = global_position.move_toward(goal, speed * delta)
	if global_position.distance_to(goal) < 0.05:
		_target = (_target + 1) % checkpoints.size()

func _is_player_lit() -> bool:
	var to_player := player.global_position - global_position
	var depth := -to_player.y
	var light_radius := depth * tan(deg_to_rad(spot_angle))
	var flat_dist := Vector2(to_player.x, to_player.z).length()
	
	if flat_dist > light_radius * 0.9 + player_radius:
		return false

	# check if under something
	var space_state = get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(global_position, player.global_position)
	query.exclude = [player.get_rid()]
	var hit := space_state.intersect_ray(query)
	print(hit)
	return space_state.intersect_ray(query).is_empty()

func _on_caught() -> void:
	_caught = true
	player.freeze = true

	var flash := create_tween().set_loops(3)
	flash.tween_property(self, "light_color", Color.RED, 0.12)
	flash.tween_property(self, "light_color", Color.WHITE, 0.12)
	await flash.finished

	light_color = Color.RED
	
	get_tree().reload_current_scene()
