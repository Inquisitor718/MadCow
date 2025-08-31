extends Area3D
signal dying

func _on_body_entered(body: Node3D) -> void:
	
	if not body.is_in_group("player_S"):
		body.queue_free()
	else:
		dying.emit()
		
