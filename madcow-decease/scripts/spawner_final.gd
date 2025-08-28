extends StaticBody3D

#@onready var collision_shape_3d_4: CollisionShape3D = 

func Hit(dmg: int) -> void:
	$Healthbar.take_damage(dmg)

func _on_healthbar_no_hp_left() -> void:
	$"../Fire/Flames".emitting = false
	$"../Fire/Smoke".emitting = false
	$"../Fire/ParticlesFloating".emitting = false
