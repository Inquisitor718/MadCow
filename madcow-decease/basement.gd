extends Node3D

@onready var pause_menu: Control = $Player2/Head/Camera3D/Pause_menu



var paused= false

func _process(delta):
	if Input.is_action_just_pressed("Pause"):
		pauseMenu()
		
func pauseMenu():
	if paused:
		pause_menu.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().paused = false
		set_process_input(true)
		print("playing")
	else:
		pause_menu.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		get_tree().paused = true
		set_process_input(false)
		print("paused")
		
	
	paused =!paused
