extends Node3D

@export var exp_dmg: float
@export var exp_dur: float

func _ready() -> void:
	$AnimationPlayer.play("Explosion")

func _on_area_3d_body_entered(body: CharacterBody3D) -> void:
	if body.has_method("Hit"):
		body.Hit(exp_dmg)
		print("Boom damaged "+ str(exp_dmg))
		await get_tree().create_timer(exp_dur).timeout
		_on_animation_player_animation_finished("Explosion")


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()
