shader_type canvas_item;

uniform sampler2D viewport_tex: hint_screen_texture, filter_linear;

uniform float aberration_strength = 4.0;

void fragment() {
	vec2 uv = SCREEN_UV;

	// Chromatic aberration effect
	float offset = aberration_strength / 100.0;
	float r = texture(viewport_tex, uv + vec2(offset + ((offset/10.0) * sin(TIME)), 0.0)).r;
	float g = texture(viewport_tex, uv).g;
	float b = texture(viewport_tex, uv - vec2(offset + ((offset/10.0) * sin(TIME)), 0.0)).b;

	COLOR = vec4(r, g, b, 1.0);
}
