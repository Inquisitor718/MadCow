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
			return center + Vector3(rand_x, 0, rand_z)

func _on_timer_timeout() -> void:
	if Global.spawner_enemies_1:
		var scenes = [Baby_Cow, Black_Cow, Patched_Cow, White_Cow]
		var chosen_scene = scenes[randi() % scenes.size()]
		print(randi() % scenes.size())
		
		var enemy_instance = chosen_scene.instantiate()
		add_child(enemy_instance)
		enemy_instance.global_transform.origin = get_random_spawn_position()


func _on_area_3d_body_entered(body) -> void:
	if body.is_in_group("player_S"):
		Global.spawner_enemies_1 = true


func _on_area_3d_body_exited(body) -> void:
	if body.is_in_group("player_S"):
		Global.spawner_enemies_1 = false
