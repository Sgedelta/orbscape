extends SpotLight3D

@export var checkpoints: Array[Vector3]
@export var rotation_checkpoints: Array[Vector3]
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
	var rot_goal : Vector3 = rotation_checkpoints[_target]
	var rot_speed = rot_goal.distance_to(rotation_checkpoints[_target - 1]) / (max(goal.distance_to(checkpoints[_target-1]), .01) / speed)
	
	position = position.move_toward(goal, speed * delta)
	rotation = rotation.move_toward(rot_goal, rot_speed * delta)
	
	if position.distance_to(goal) < 0.05:
		_target = (_target + 1) % checkpoints.size()

func _is_player_lit() -> bool:
	var player_instance : Node3D = get_tree().get_first_node_in_group("player") as Node3D
	if(not is_instance_valid(player_instance)):
		return false
	var to_player := player_instance.global_position - global_position
	var depth := -to_player.y
	var light_radius := depth * tan(deg_to_rad(spot_angle))
	var flat_dist := Vector2(to_player.x, to_player.z).length()
	
	if flat_dist > light_radius * 0.9 + player_radius:
		return false

	# check if under something
	var space_state = get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(global_position, player_instance.global_position, 
		0xFFFFFFFF - 2)
	#query.exclude = [player.get_rid()]
	var hit := space_state.intersect_ray(query)
	return space_state.intersect_ray(query).is_empty()

func _on_caught() -> void:
	var player_instance : Node3D = get_tree().get_first_node_in_group("player") as Node3D
	_caught = true
	player_instance.freeze = true

	var flash := create_tween().set_loops(3)
	flash.tween_property(self, "light_color", Color.RED, 0.12)
	flash.tween_property(self, "light_color", Color.WHITE, 0.12)
	await flash.finished

	light_color = Color.RED
	
	player_instance.square_off()
	get_tree().reload_current_scene()
	
