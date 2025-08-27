extends Area3D

@onready var light: OmniLight3D = $OmniLight3D
var flicker_enabled: bool = false
var time := 0.0

# Two target colors for flicker
@export var color_a: Color = Color(1.0, 0.6, 0.2) # orange fire
@export var color_b: Color = Color(1.0, 0.2, 0.05) # deeper red fire

# Speed of flicker
var flicker_speed: float = 5.0

func _process(delta: float) -> void:
	if !flicker_enabled:
		return
	
	time += delta * flicker_speed
	
	var t = (sin(time) * 0.5) + 0.5  
	
	# Interpolate between two colors
	var flicker_color = color_a.lerp(color_b, t)
	
	light.light_color = flicker_color

func enable_flicker(enable: bool) -> void:
	flicker_enabled = enable
