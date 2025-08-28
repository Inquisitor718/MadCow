shader_type spatial;
render_mode unshaded;

uniform vec3 color_start : source_color = vec3(1.0, 0.0, 0.0); 
uniform vec3 color_end : source_color = vec3(0.0, 0.0, 1.0);   
uniform float time_period = 0.2;

void fragment() {
    float t = clamp(abs(sin(TIME/time_period)), 0.0, 1.0); 
  	ALBEDO = mix(color_start,color_end,t);
}
