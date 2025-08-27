extends StaticBody3D

@onready var collision_shape_3d_4: CollisionShape3D = $CollisionShape3D4

func Hit(dmg: int) -> void:
		%Healthbar.take_damage(dmg)

	#$Fire/Flames.amount_ratio_ratio = lerp($Fire/Flames.amount_ratio_ratio, 0, 0.1)
	#$Fire/Smoke.amount_ratio_ratio = lerp($Fire/Smoke.amount_ratio_ratio, 0, 0.1)
	#$Fire/StaticFlame.amount_ratio_ratio = lerp($Fire/StaticFlame.amount_ratio_ratio, 0, 0.1)
	#$Fire/ParticlesFloating.amount_ratio_ratio = lerp($Fire/ParticlesFloating.amount_ratio_ratio, 0, 0.1)


func _on_healthbar_no_hp_left() -> void:
	$Fire/Flames.emitting = false
	$Fire/Smoke.emitting = false
	$Fire/StaticFlame.emitting = false
	$Fire/ParticlesFloating.emitting = false
