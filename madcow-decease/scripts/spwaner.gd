extends Node3D

@onready var spwan_timer = $Timer

func _on_timer_timeout() -> void:
	const PATCHED_COW = preload("res://scenes/patched_cow.tscn")
	var new_enemy = PATCHED_COW.instantiate()
	get_parent().add_child(new_enemy)
	new_enemy.global_position = global_position
