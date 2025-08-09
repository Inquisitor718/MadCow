extends Area3D

const  ROT_SPEED = 2
var vertical_velocity = 0.0

func _process(delta: float) -> void:
	vertical_velocity -= gravity * delta * 2
	global_position.y += vertical_velocity * delta
	if global_position.y <= 1:
		global_position.y = 1
		vertical_velocity = 0
	rotate_y(deg_to_rad(ROT_SPEED))


func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		set_collision_layer_value(3, false)
		set_collision_mask_value(1, false)
		$AnimationPlayer.play("bounce")


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()
