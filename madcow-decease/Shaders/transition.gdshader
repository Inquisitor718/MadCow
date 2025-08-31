shader_type canvas_item;

uniform sampler2D viewport_tex: hint_screen_texture, filter_linear;
uniform sampler2D noise_tex1;
uniform sampler2D noise_tex2;

uniform vec2 scroll1 = vec2(0.05, 0.05);
uniform vec2 scroll2 = vec2(0.07, -0.03);

uniform float distortion_strength = 0.05;
uniform float aberration_strength = 0.0;
uniform float transition_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 uv = SCREEN_UV;

    // Transition-controlled distortion
    if (transition_amount > 0.001) {
        vec4 noise_col = texture(noise_tex1, UV + TIME * scroll1) *
                         texture(noise_tex2, UV + TIME * scroll2);
        // distortion strength scaled by transition_amount
        uv += distortion_strength * (noise_col.rg - 0.5);
    }

    // Chromatic aberration sampling with distorted UV
    float offset = (aberration_strength / 100.0) * (1.0 + transition_amount);
    float r = texture(viewport_tex, uv + vec2(offset + ((offset/10.0) * sin(TIME)), 0.0)).r;
    float g = texture(viewport_tex, uv).g;
    float b = texture(viewport_tex, uv - vec2(offset + ((offset/10.0) * sin(TIME)), 0.0)).b;

    vec4 final_col = vec4(r, g, b, 1.0);

    // Optional: fade to black as transition_amount → 1
    //final_col.rgb = mix(final_col.rgb, vec3(0.0), transition_amount);

    COLOR = final_col;
}