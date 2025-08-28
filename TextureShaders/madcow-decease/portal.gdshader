shader_type spatial;

render_mode unshaded, blend_mix, depth_draw_never;

uniform sampler2D camo_tex : source_color; 
uniform vec3 color_a : source_color = vec3(0.0, 0.0, 0.0); // black or dark
uniform vec3 color_b : source_color = vec3(0.9, 0.3, 0.0); // orange or bright

uniform float glow = 1.0;

uniform vec3 glow_color : source_color = vec3(1.0, 0.5, 0.0);
uniform float glow_strength = 1.5;
uniform float glow_thinnes = 2.0;
uniform float glow_dispersion = 2.0;
uniform bool enable_fresnel = false;
uniform float major_radius = 1.0; // Torus big radius
uniform float minor_radius = 0.3; // Torus thickness

void fragment() {
    // --- Sample camo texture (mask only) ---
	vec2 animated_UV = UV * 4.0 + vec2(TIME * 0.2, TIME* 0.2);
    float mask = texture(camo_tex, animated_UV).r; // use red channel as mask
    vec3 base_color = mix(color_a, color_b, mask);
	vec3 final_color = base_color;
	if (enable_fresnel) {
	vec3 view_dir = normalize(-VERTEX);
	vec3 world_normal = normalize(NORMAL);
    vec3 world_view_dir = normalize(-VERTEX);
    float dot_nv = dot(world_normal, world_view_dir);
	float fresnel = pow(1.0 - dot_nv, glow_thinnes);
	ALBEDO = final_color + glow_color * fresnel * glow_dispersion;
	}
	else {
	ALBEDO = final_color;
	ALPHA = glow; 
	}
	
}



