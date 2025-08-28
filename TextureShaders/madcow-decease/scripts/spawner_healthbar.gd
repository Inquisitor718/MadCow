extends Sprite3D

signal no_hp_left

@export var max_hp : int = 1000

func _ready() -> void:
	$SubViewport/Panel/ProgressBar.max_value = max_hp
	$SubViewport/Panel/ProgressBar.value = max_hp
	
func take_damage(damage: float):
	$SubViewport/Panel/ProgressBar.value -= damage
	
	if $SubViewport/Panel/ProgressBar.value <= 0.01:
		no_hp_left.emit()
