extends Node2D
@onready var music: AudioStreamPlayer2D = $Camera2D/AudioStreamPlayer2D


func _on_video_stream_player_finished() -> void:
	$Camera2D/ColorRect.show()
	fade_out_music(6.0)
	await get_tree().create_timer(6.0).timeout
	get_tree().change_scene_to_file("res://Basement.tscn")
	
func fade_out_music(duration: float):
	var tween := get_tree().create_tween()
	tween.tween_property(music, "volume_db", -20.0, duration)
	tween.tween_callback(Callable(music, "stop"))

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://Basement.tscn")
