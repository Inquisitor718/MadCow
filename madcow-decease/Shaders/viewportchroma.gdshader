shader_type canvas_item;

uniform sampler2D viewport_tex: hint_screen_texture,filter_linear;
uniform float aberration_strength = 4.0;

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = UV;
	float offset = aberration_strength/100.0;
	float r = texture(viewport_tex,uv+vec2(offset+ ((offset/10.0)*sin(TIME)),0.0)).r;
	float g = texture(viewport_tex,uv).g;
	float b = texture(viewport_tex,uv-vec2(offset + ((offset/10.0)*sin(TIME)),0.0)).b;
	COLOR = vec4(r,g,b,1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
