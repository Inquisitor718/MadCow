extends StaticBody3D

@export var x: float 
@export var z: float
@export var r: float

@export var Baby_Cow: PackedScene
@export var Black_Cow: PackedScene
@export var Patched_Cow: PackedScene
@export var White_Cow: PackedScene

@onready var spwan_timer = $Timer

func _ready():
	randomize()

func get_random_spawn_position():
	var center = global_transform.origin
	while true:
		var rand_x = randf_range(-x, x)
		var rand_z = randf_range(-z, z)
		var dist = sqrt(rand_x * rand_x + rand_z * rand_z)
		if dist > r:
			Global.spawner_enemies = true
			return center + Vector3(rand_x, 0, rand_z)

func _on_timer_timeout() -> void:
	if Global.spawner_enemies:
		var scenes = [Baby_Cow, Black_Cow, Patched_Cow, White_Cow]
		var spawn_pos = get_random_spawn_position()
		spawn_pos.y = -4
		var chosen_scene = scenes[randi() % scenes.size()]
		var enemy_instance = chosen_scene.instantiate()
		enemy_instance.global_transform.origin = spawn_pos
		add_child(enemy_instance)
	#get_tree().current_scene.add_child(enemy_instance)
