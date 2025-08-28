shader_type canvas_item;

uniform sampler2D viewport_tex: hint_screen_texture, filter_linear;
uniform sampler2D noise_tex1;
uniform sampler2D noise_tex2;

uniform vec2 scroll1 = vec2(0.05, 0.05);
uniform vec2 scroll2 = vec2(0.07, -0.03);

uniform float distortion_strength = 1.00;
uniform float transition_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 uv = SCREEN_UV;

	// Only distort if transition_amount > 0
	if (transition_amount > 0.001) {
		vec4 noise_col = texture(noise_tex1, UV + TIME * scroll1) *
						 texture(noise_tex2, UV + TIME * scroll2);
		uv += distortion_strength * transition_amount * (noise_col.rg - 0.5);
	}
	vec4 final_col = texture(viewport_tex, uv);

	// 🔥 Fade to black as transition_amount goes to 1
	final_col.rgb = mix(final_col.rgb, vec3(0.0), transition_amount);

	COLOR = final_col;

}


//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
