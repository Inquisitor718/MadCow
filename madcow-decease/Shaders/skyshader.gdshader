shader_type sky;

uniform vec3 color_A : source_color = vec3(0.1176, 0.236 , 1.0);
uniform vec3 color_B : source_color  = vec3(0.8, 0.0, 0.992);
uniform sampler2D skyTexture;
uniform float time_speed = 0.02;
uniform float swirl_strength = 0.1;
uniform float tex_scale =  0.6;
uniform bool invert_color = false;

void sky() {
	//Mapping for godot sky textures
    vec2 uv = EYEDIR.xz * tex_scale;

	float fade = smoothstep(0.04, 0.8, EYEDIR.y);

	//this gives a swirl to the X & Z coords
    uv.x += sin(uv.y * 5.0 + TIME * 0.5) * swirl_strength;
    uv.y += cos(uv.x * 5.0 + TIME * 0.7) * swirl_strength;

	//scrolling gives a moving feel
    uv += TIME * time_speed;

	//gives rgb representation of texture
    vec3 tex_col = texture(skyTexture, uv).rgb;

	//takes dot product of texture rgb with a vector
	float lum = tex_col.r;

	//mixing the colorA & color_B white and black
	vec3 colorized;
	if (invert_color) {
		colorized = mix(color_A, color_B, 1.0-lum);
		}
    else {
		colorized = mix(color_A, color_B, lum);
	}
	//gives a fade depending on location, remove for 360 effect
	colorized *= fade;

	//gives a horizon blend to make the texture about the horizon
    float horizon_blend = smoothstep(-0.2, 0.8, EYEDIR.y);


    vec3 gradient_col = mix(color_A, color_B, horizon_blend);

    COLOR = vec4(mix(colorized, gradient_col, 0.3), 1.0).rgb;
}
