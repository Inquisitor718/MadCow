extends Node3D


@onready var shader_mat: ShaderMaterial = $CanvasLayer/ColorRect.material

enum DistortionState { NONE, LOW, MED, HIGH }
var paused = false
var state: DistortionState = DistortionState.NONE
@export var rate: float = 60.0:
	set(value):
		value = clamp(value, 0, 5.0)
		rate = value

@onready var player: CharacterBody3D = $Player

func _ready() -> void:
	Global.distortion = 0.0
	shader_mat.set_shader_parameter("aberration_strength",0.0)



func _process(delta):
	#if Input.is_action_just_pressed("Pause"):
		#pauseMenu()
		Global.distortion -= delta*rate
		rate+=delta
		player._dist_display(Global.distortion)
		if Global.distortion < 50.0:
				update_chroma(0.0,2.0)
		elif Global.distortion >= 50.0:
				update_chroma(0.5,2.0)
		elif Global.distortion >= 70.0:
				update_chroma(1.0,2.0)
		pass
		
func increase_distortion(value: float) -> void:
	Global.distortion += value
	rate=0
	
		
func update_chroma(strength: float,frequency: float) -> void:
	shader_mat.set_shader_parameter("aberration_strength",strength)
	shader_mat.set_shader_parameter("frequency",frequency)
#func pauseMenu():
	#if paused:
		#pause_menu.hide()
		#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		#get_tree().paused = false
		#set_process_input(true)
		#print("playing")
	#else:
		#pause_menu.show()
		#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		#get_tree().paused = true
		#set_process_input(false)
		#print("paused")
		#
	#
	#paused =!paused
func _on_death() -> void:
	increase_distortion(7.5)
	pass
