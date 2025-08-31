extends Sprite3D

signal no_hp_left

@export var max_hp : float = 1000.0

func _ready() -> void:
	$SubViewport/Panel/ProgressBar.max_value = max_hp
	$SubViewport/Panel/ProgressBar.value = max_hp
	
func take_damage(damage: float):
	$SubViewport/Panel/ProgressBar.value -= damage
	
	if $SubViewport/Panel/ProgressBar.value <= 0.01:
		no_hp_left.emit()
		await get_tree().create_timer(3.0).timeout
		Global.spawner_enemies_1 = false
		
		for i in range(max_hp):
			if $SubViewport/Panel/ProgressBar.value < max_hp:
				await get_tree().create_timer(0.15).timeout
				$SubViewport/Panel/ProgressBar.value += 2
			else:
				Global.spawner_enemies_1 = true
				$"../../Fire/Flames".emitting = true
				$"../../Fire/Smoke".emitting = true
				$"../../Fire/ParticlesFloating".emitting = true
				break
