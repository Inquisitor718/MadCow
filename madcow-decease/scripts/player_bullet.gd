extends RigidBody3D

var dmg = 0
func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Proj"):
		pass
	else:
		if body.is_in_group("Enemy") && body.has_method("Hit"):
			body.Hit(dmg,0,0)
			queue_free()
		else:
			queue_free()

func _on_timer_timeout() -> void:
	queue_free()
