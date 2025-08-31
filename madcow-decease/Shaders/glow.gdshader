shader_type spatial;

render_mode unshaded, cull_disabled, depth_draw_never,blend_add;

uniform vec3 glow_color : source_color = vec3(1.0, 0.5, 0.0);
uniform float glow_strength = 1.5;
uniform float glow_thinnes = 2.0;
uniform float glow_dispersion = 2.0;

void fragment() {
	vec3 view_dir = normalize(-VERTEX);
	vec3 world_normal = normalize(NORMAL);
    vec3 world_view_dir = normalize(-VERTEX);
    float dot_nv = dot(world_normal, world_view_dir);
	float fresnel = pow(1.0 - dot_nv, glow_thinnes);
	ALBEDO = glow_color * fresnel * glow_dispersion;
}
