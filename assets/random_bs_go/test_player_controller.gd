class_name player
extends RigidBody3D

@export var camera_controller : Node3D;
@export var subdivisions : int = 7;
@export var force_falloff : Curve;
@export var impulse_needed_to_deform = .5;
@export var impulse_to_deform_str : Curve;
@export var sphere_size = .33;
@export var dent_str_scalar = 1.0;

@export var sensitivity = 1.0
@export var jump_str = 5.0
@export var jump_count = 1
@export var ball_texture : Texture2D
var used_jumps = 0;



var max_impulse = .15;
var min_impulse = .01;

@onready var mesh_instance = $Mesh
@onready var mesh = mesh_instance.mesh
@onready var collider = $Collider
@onready var engine_mesh = $EngineMesh
var mdt = MeshDataTool.new()

var accumulated_force = 0.0;
var GROUNDED_ANGLE = deg_to_rad(30)
var _on_ground_this_frame = false
var COYOTE_TIME = .1
var _time_since_ground = 10000
var JUMP_REFRESH_BUFFER = .1
var _time_since_jump = 0

var grounded: bool:
	get: return _time_since_ground <= COYOTE_TIME

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	engine_mesh.visible = false;
	square_off()
	#deform(Vector3(0, -.5, .5), Vector3(0, -1, 1))
	
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = ball_texture
	mesh_instance.material_override = mat
	
	make_collision_shape()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	var fwd := -camera_controller.global_basis.z
	var axis := Vector3.UP.cross(fwd)
	
	apply_torque( axis * accumulated_force)
	
	accumulated_force = 0
	
	if _on_ground_this_frame:
		_time_since_ground = 0.0
		if _time_since_jump >= JUMP_REFRESH_BUFFER:
			used_jumps = jump_count
	else:
		_time_since_ground += delta
	
	if _time_since_jump < JUMP_REFRESH_BUFFER:
		_time_since_jump += delta
	

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# calc deform
	var deform_count = 0;
	
	for i in range(state.get_contact_count()):
		var pos = to_local(state.get_contact_local_position(i))
		var normal = state.get_contact_local_normal(i) * global_basis
		var hit_str = state.get_contact_impulse(i)
		if hit_str.length_squared() > (impulse_needed_to_deform * impulse_needed_to_deform) :
			#print("contact ", i, " ", pos, " str: ", normal*hit_str)
			var deform_pos = pos;
			var deform_str = normal * impulse_to_deform_str.sample(hit_str.length() - impulse_needed_to_deform)
			deform_count += 1
			deform(deform_pos, deform_str)
			
	
	if deform_count != 0:
		make_collision_shape()
	
	# grounded checks
	_on_ground_this_frame = false
	for i in range(state.get_contact_count()):
		var normal = state.get_contact_local_normal(i)
		var angle = normal.angle_to(Vector3.UP)
		if angle < GROUNDED_ANGLE:
			_on_ground_this_frame = true;
	
	pass

func _input(event: InputEvent) -> void:
	if event.is_action("forward"):
		accumulated_force += sensitivity;
	elif event.is_action("backward"):
		accumulated_force -= sensitivity;
	elif event.is_action_pressed("jump") and used_jumps >= 1:
		apply_central_impulse(Vector3.UP * jump_str)
		used_jumps -= 1
		_time_since_jump = 0

func square_off():
	var box = BoxMesh.new()
	box.subdivide_depth = subdivisions
	box.subdivide_height = subdivisions
	box.subdivide_width = subdivisions
	
	mesh.clear_surfaces()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, box.get_mesh_arrays())
	
	mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	mdt.commit_to_surface(mesh)
	
	pass

func deform(localCoord : Vector3, deform_str : Vector3) :
	mdt.create_from_surface(mesh, 0)
	
	for i in range(mdt.get_vertex_count()):
		var vert = mdt.get_vertex(i)
		var original_vert = vert
		var impulse = deform_str * force_falloff.sample(vert.distance_to(localCoord))
		impulse = impulse.normalized() *  clampf(impulse.length(), 0, max_impulse)
		if(impulse.length_squared() < min_impulse * min_impulse):
			continue;
		vert += impulse * dent_str_scalar
		
		# force to be sphere, if we want to force to another shape we have to do math about it
		if(vert.length() < sphere_size):
			vert = original_vert.normalized() * sphere_size
		mdt.set_vertex(i, vert)
	
	# fix normals face by face
	for i in range(mdt.get_face_count()):
		# index in vert array
		var a = mdt.get_face_vertex(i, 0)
		var b = mdt.get_face_vertex(i, 1)
		var c = mdt.get_face_vertex(i, 2)
		# then the positions
		var a_pos = mdt.get_vertex(a)
		var b_pos = mdt.get_vertex(b)
		var c_pos = mdt.get_vertex(c)
		# calc normal (imperfect, but close enough!)
		var norm = (b_pos - c_pos).cross(a_pos - b_pos).normalized()
		
		mdt.set_vertex_normal(a, norm + mdt.get_vertex_normal(a))
		mdt.set_vertex_normal(b, norm + mdt.get_vertex_normal(b))
		mdt.set_vertex_normal(c, norm + mdt.get_vertex_normal(c))
	
	# renormalize normals
	for i  in range (mdt.get_vertex_count()):
		mdt.set_vertex_normal(i, mdt.get_vertex_normal(i).normalized())
	
	
	mesh.clear_surfaces()
	mdt.commit_to_surface(mesh)
	pass


func make_collision_shape() :
	
	collider.shape = mesh.create_convex_shape(true, false)
