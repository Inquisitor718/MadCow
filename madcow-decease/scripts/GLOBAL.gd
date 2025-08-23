extends Node

var mat: ShaderMaterial 
var kills = 0
var has_powerup = false
var distortion: float = 60.0

@onready var player_color_rect: ColorRect = null

func _ready() -> void:
	# Try to find Player's ColorRect on startup
	var player = get_tree().get_root().find_child("Player", true, false)
	if player:
		var viewport = player.get_node("CanvasLayer2")
		if viewport:
			player_color_rect = viewport.get_node("ColorRect")
			print("Colour rect detected")
			update_chroma(4.0)
	if player_color_rect == null:
		print("⚠️ Could not find Player/Viewport/ColorRect")

func update_chroma(strength: float) -> void:
	#if player_color_rect and player_color_rect.material is ShaderMaterial:
		#print("Shader detected")
		#player_color_rect.materialset_shader_parameter("aberration_strength", strength)
	pass

func _process(delta: float) -> void:
	if distortion>=30.0:
		enable_flicker()
	elif distortion>=50.0:
		b_hole()
		update_chroma(4.0)
	else:
		update_chroma(0.5)



func b_hole() -> void:
	pass

func enable_flicker()-> void:
	pass
