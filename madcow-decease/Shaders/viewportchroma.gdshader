shader_type canvas_item;

uniform sampler2D viewport_tex: hint_screen_texture, filter_linear;
uniform sampler2D noise_tex1;
uniform sampler2D noise_tex2;

uniform vec2 scroll1 = vec2(0.05, 0.05);
uniform vec2 scroll2 = vec2(0.07, -0.03);

uniform float distortion_strength = 0.05;
uniform float aberration_strength = 4.0;
uniform bool transition = false;

void fragment() {
    // base screen UV
    vec2 uv = SCREEN_UV;

    // distortion effect if transition is enabled
    if (transition) {
        vec4 noise_col = texture(noise_tex1, UV + TIME * scroll1) *
                         texture(noise_tex2, UV + TIME * scroll2);
        uv += distortion_strength * (noise_col.rg - 0.5); 
    }

    // chromatic aberration sampling with the (possibly distorted) UV
    float offset = aberration_strength / 100.0;
    float r = texture(viewport_tex, uv + vec2(offset + ((offset/10.0)*sin(TIME)), 0.0)).r;
    float g = texture(viewport_tex, uv).g;
    float b = texture(viewport_tex, uv - vec2(offset + ((offset/10.0)*sin(TIME)), 0.0)).b;

    COLOR = vec4(r, g, b, 1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
