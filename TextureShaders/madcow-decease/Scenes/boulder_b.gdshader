shader_type spatial;
uniform sampler2D my_texture;

void vertex() {
	NORMAL = - NORMAL;
}

void fragment() {
	vec4 tex_color = texture(my_texture, UV);
	ALBEDO = tex_color.rgb;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
