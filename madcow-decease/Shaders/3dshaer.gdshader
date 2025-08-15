shader_type spatial;

uniform vec3 color_start : source_color = vec3(1.0, 0.0, 0.0); 
uniform vec3 color_end : source_color = vec3(0.0, 0.0, 1.0);   
uniform float time_period = 0.2;

void fragment() {
    float t = clamp(UV.x, 0.0, 1.0); 
    if (sin((TIME)/time_period)>0.0) {
		ALBEDO = color_start;
	} else {
		ALBEDO = color_end;
	}
}

