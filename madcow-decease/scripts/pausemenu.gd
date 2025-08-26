extends Control

func _ready() -> void:
	$AnimationPlayer.play("RESET")

func resume():
	print(">> RESUME CALLED")
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	set_process_input(true)
func pause():
	print(">> PAUSE CALLED")
	get_tree().paused = true
	$AnimationPlayer.play("blur")
	set_process_input(false)

func testEsc():
	if Input.is_action_just_pressed("pause") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("pause") and get_tree().paused:
		resume()


func _on_resume_pressed():
	resume()

func _on_quit_pressed():
	get_tree().quit()
	 
func _process(delta: float) -> void:
	testEsc()
 
# Pause and Resume have strange bs going on , used focus -> None on the button resume to fix the triggering of resume() everytime I release spacebar(only happens if the escape key has been pressed atleast once after the scene has been loaded)
