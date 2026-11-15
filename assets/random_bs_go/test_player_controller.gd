extends RigidBody3D

@export var subdivisions : int = 7;
@export var force_falloff : Curve;
@export var impulse_needed_to_deform = .5;
@export var impulse_to_deform_str : Curve;
@export var sensitivity = 1.0
@export var sphere_size = .33;
@export var dent_str_scalar = 1.0;

var max_impulse = .15;
var min_impulse = .01;

@onready var mesh_instance = $Mesh
@onready var mesh = mesh_instance.mesh
@onready var collider = $Collider
@onready var engine_mesh = $EngineMesh
var mdt = MeshDataTool.new()

var accumulated_force = 0.0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	engine_mesh.visible = false;
	square_off()
	#deform(Vector3(0, -.5, .5), Vector3(0, -1, 1))
	make_collision_shape()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	apply_torque( Vector3(-1, 0, 0) * accumulated_force)
	
	accumulated_force = 0

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var deform_count = 0;
	var deform_pos = Vector3();
	var deform_str = Vector3();
	
	for i in range(state.get_contact_count()):
		var pos = to_local(state.get_contact_local_position(i))
		var normal = state.get_contact_local_normal(i) * global_basis
		var hit_str = state.get_contact_impulse(i)
		if hit_str.length_squared() > (impulse_needed_to_deform * impulse_needed_to_deform) :
			#print("contact ", i, " ", pos, " str: ", normal*hit_str)
			deform_pos = pos;
			deform_str = normal * impulse_to_deform_str.sample(hit_str.length() - impulse_needed_to_deform)
			deform_count += 1
			deform(deform_pos, deform_str)
			
	
	if deform_count != 0:
		deform_pos /= deform_count;
		#deform(deform_pos, deform_str)
		make_collision_shape()
	pass

func _input(event: InputEvent) -> void:
	if event.is_action("forward"):
		accumulated_force += sensitivity;
	elif event.is_action("backward"):
		accumulated_force -= sensitivity;

func square_off():
	var box = BoxMesh.new()
	box.subdivide_depth = subdivisions
	box.subdivide_height = subdivisions
	box.subdivide_width = subdivisions
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, box.get_mesh_arrays())
	
	
	
	pass

func deform(localCoord : Vector3, deform_str : Vector3) :
	mdt.create_from_surface(mesh_instance.mesh, 0)
	
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
	
	
	mesh_instance.mesh.clear_surfaces()
	mdt.commit_to_surface(mesh_instance.mesh)
	pass


func make_collision_shape() :
	
	collider.shape = mesh.create_convex_shape(true, false)
