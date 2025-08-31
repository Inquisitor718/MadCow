extends Node

var mat: ShaderMaterial 
var kills = 0
var has_powerup = false
var distortion: float = 0.0:
	set(value):
		value = clamp(value, 0, 100)
		distortion = value

@onready var player_color_rect: ColorRect = null

func _ready() -> void:
	# Try to find Player's ColorRect on startup
	pass

	

func _process(_delta: float) -> void:
	if distortion>=30.0:
		enable_flicker()
	elif distortion>=50.0:
		b_hole()



func b_hole() -> void:
	pass

func enable_flicker()-> void:
	pass
	
var spawner_enemies_1 : bool = false
var spawner_enemies_2 : bool = false
