extends Control

@onready var level = $"../../../../"


func _on_resume_pressed() -> void:
	level.pauseMenu()


func _on_quit_pressed() -> void:
	get_tree().quit()
