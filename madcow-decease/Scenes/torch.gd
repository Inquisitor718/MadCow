extends Area3D

@onready var light: OmniLight3D = $OmniLight3D
var flicker_enabled: bool = false
var noise := FastNoiseLite.new()
var time := 0.0

# Base fire color (orange-ish)
var base_color: Color = Color(1.0, 0.6, 0.2)


func _process(delta: float) -> void:
	if !flicker_enabled:
		return
	
	time += delta * 5.0
	var flicker = noise.get_noise_1d(time)  # -1.0 to 1.0
	
	# Slightly vary the red & green channels, blue stays low
	var r = clamp(base_color.r + flicker * 0.1, 0.8, 1.0)
	var g = clamp(base_color.g + flicker * 0.1, 0.4, 0.8)
	var b = clamp(base_color.b + flicker * 0.05, 0.0, 0.3)
	
	light.light_color = Color(r, g, b)

func enable_flicker(enable: bool) -> void:
	flicker_enabled = enable
