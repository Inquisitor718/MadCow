extends Node3D


@onready var shader_mat: ShaderMaterial = $Player/CanvasLayer2/ColorRect.material

enum DistortionState { NONE, LOW, MED, HIGH }
var paused = false
var state: DistortionState = DistortionState.NONE
@export var rate: float = 60.0:
	set(value):
		value = clamp(value, 0, 5.0)
		rate = value

@onready var lights: Node3D = $"Lighting stuff/torch1"
@onready var player: CharacterBody3D = $Player

func _ready() -> void:
	Global.distortion = 0.0

func set_flicker_enabled(enable: bool) -> void:
	for torch in lights.get_children():
		if torch.has_method("enable_flicker"):
			torch.enable_flicker(true)


func _process(delta):
	#if Input.is_action_just_pressed("Pause"):
		#pauseMenu()
		Global.distortion -= delta*rate
		rate+=delta
		player._dist_display(Global.distortion)
		pass
		
func increase_distortion(value: float) -> void:
	Global.distortion += value
	rate=0
	match state:
		DistortionState.NONE:
			if Global.distortion > 30.0:
				print("Global.distortion gone to 30")
				state = DistortionState.LOW
				set_flicker_enabled(true)
		DistortionState.LOW:
			if Global.distortion > 50.0:
				print("Global.distortion gone high")
				state = DistortionState.MED
				update_chroma(0.5,2.0)
				
		DistortionState.MED:
			if Global.distortion > 70.0:
				print("distortion is high")
				state = DistortionState.HIGH
		
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
	increase_distortion(10.0)
	pass

func _on_black_cow_on_death() -> void:
	increase_distortion(10.0)
	pass # Replace with function body.


func _on_patched_cow_on_death() -> void:
	increase_distortion(10.0)
	pass # Replace with function body.


func _on_white_cow_on_death() -> void:
	increase_distortion(10.0)
	pass # Replace with function body.
