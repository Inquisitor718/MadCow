extends Area3D

const ROT_SPEED = 2
var vertical_velocity = 0.0


@export var weapon_name : String
@export var current_ammo: int
@export var reserve_ammo: int

func _process(_delta: float) -> void:
	rotate_y(deg_to_rad(ROT_SPEED))

func _on_body_entered(body: CharacterBody3D) -> void:
	if body.is_in_group("player_S") and body.is_in_group(weapon_name):
		$AnimationPlayer.play("bounce")
		print(weapon_name)
		set_collision_layer_value(5, false)
		set_collision_mask_value(1, false)
		

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()
