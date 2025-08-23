extends Node3D

@onready var pause_menu: Control = $Player2/Head/Camera3D/Pause_menu
@onready var shader_mat: ShaderMaterial = $Player/CanvasLayer2/ColorRect.material

enum DistortionState { NONE, LOW, MED, HIGH }
var paused = false
var distortion: float = 0.0
var state: DistortionState = DistortionState.NONE

@onready var lights: Node3D = $"Lighting stuff/torch1"

func set_flicker_enabled(enable: bool) -> void:
	for torch in lights.get_children():
		if torch.has_method("enable_flicker"):
			torch.enable_flicker(true)

func _process(delta):
	if Input.is_action_just_pressed("Pause"):
		pauseMenu()
		
func increase_distortion(value: float) -> void:
	distortion += value
	
	match state:
		DistortionState.NONE:
			if distortion > 30.0:
				print("distortion gone to 30")
				state = DistortionState.LOW
				set_flicker_enabled(true)
		DistortionState.LOW:
			if distortion > 50.0:
				print("distortion gone high")
				state = DistortionState.MED
				update_chroma(0.5)
				
		DistortionState.MED:
			if distortion > 70.0:
				print("distortion is high")
				state = DistortionState.HIGH
		
func update_chroma(value: float) -> void:
	shader_mat.set_shader_parameter("aberration_strength",value)
		
func pauseMenu():
	if paused:
		pause_menu.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().paused = false
		set_process_input(true)
		print("playing")
	else:
`		pause_menu.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		get_tree().paused = true
		set_process_input(false)
		print("paused")
		
	
	paused =!paused


func _on_black_cow_on_death() -> void:
	increase_distortion(2.5)
	pass # Replace with function body.


func _on_patched_cow_on_death() -> void:
	increase_distortion(2.5)
	pass # Replace with function body.


func _on_white_cow_on_death() -> void:
	increase_distortion(2.5)
	pass # Replace with function body.
