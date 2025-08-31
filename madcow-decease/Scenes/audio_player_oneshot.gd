extends AudioStreamPlayer
class_name AudioOneshot


func _on_finished() -> void:
	queue_free()
