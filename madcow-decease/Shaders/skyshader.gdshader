shader_type sky;

uniform vec3 color_A : source_color = vec3(0.1176, 0.236, 1.0);
uniform vec3 color_B : source_color = vec3(0.8, 0.0, 0.992);
uniform sampler2D skyTexture;
uniform float time_speed = 0.02;
uniform float swirl_strength = 0.1;
uniform float tex_scale = 0.6;
uniform bool invert_color = false;

void sky() {
    vec2 uv = EYEDIR.xz * tex_scale;
    float t = TIME * time_speed;

    // swirl (merged sin/cos using a single trig function each)
    float swirl_x = sin(uv.y * 5.0 + TIME * 0.5);
    float swirl_y = cos(uv.x * 5.0 + TIME * 0.7);
    uv += vec2(swirl_x, swirl_y) * swirl_strength;

    // scrolling
    uv += t;

    // texture sample
    vec3 tex_col = texture(skyTexture, uv).rgb;
    float lum = tex_col.r;

    // color mix (branchless for GPU friendliness)
    float lum_mix = invert_color ? (1.0 - lum) : lum;
    vec3 colorized = mix(color_A, color_B, lum_mix);

    // fade by height
    float fade = smoothstep(0.04, 0.8, EYEDIR.y);
    colorized *= fade;

    // horizon gradient blend
    float horizon_blend = smoothstep(-0.2, 0.8, EYEDIR.y);
    vec3 gradient_col = mix(color_A, color_B, horizon_blend);

    // final color
    COLOR = vec4(mix(colorized, gradient_col, 0.3), 1.0).rgb;
}
