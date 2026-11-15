shader_type spatial;

uniform float morph : hint_range(0.0, 1.0) = 0.0;
uniform float half_size = 0.5;

//https://mathproofs.blogspot.com/2005/07/mapping-cube-to-sphere.html?lr=1

vec3 cube_to_sphere(vec3 p) {
	vec3 p2 = p * p;
	return vec3(
		p.x * sqrt(1.0 - p2.y * 0.5 - p2.z * 0.5 + p2.y * p2.z / 3.0),
		p.y * sqrt(1.0 - p2.z * 0.5 - p2.x * 0.5 + p2.z * p2.x / 3.0),
		p.z * sqrt(1.0 - p2.x * 0.5 - p2.y * 0.5 + p2.x * p2.y / 3.0)
	);
}

void vertex() {
	// -1,1 normalize, find xyz to lerp
	vec3 sphere_pos = cube_to_sphere(VERTEX / half_size) * half_size;
	//lerp
	VERTEX = mix(VERTEX, sphere_pos, morph);
	NORMAL = normalize(mix(NORMAL, normalize(sphere_pos), morph));
}