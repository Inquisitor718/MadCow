extends Area3D

var spawned = false

@export var black_cow_scene = preload("res://Scenes/enemy scenes/black_cow.tscn")
@export var white_cow_scene = preload("res://Scenes/enemy scenes/white_cow.tscn")
@export var patched_cow_scene = preload("res://Scenes/enemy scenes/patched_cow.tscn")
@export var baby_cow_scene = preload("res://Scenes/enemy scenes/baby_cow.tscn")
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D


@onready var spawnpoint: Marker3D = $spawnpoint
@onready var spawnpoint_2: Marker3D = $spawnpoint2
@onready var spawnpoint_3: Marker3D = $spawnpoint3
@onready var spawnpoint_4: Marker3D = $spawnpoint4
@onready var spawnpoint_5: Marker3D = $spawnpoint5


@onready var spawnpoints: Array[Marker3D] = [
	spawnpoint, spawnpoint_2, spawnpoint_3, spawnpoint_4, spawnpoint_5
]

var cow_scenes = [black_cow_scene, white_cow_scene, patched_cow_scene, baby_cow_scene]

func _on_body_entered(body: Node3D) -> void:
	if spawned:
		return 
	spawned=true
	collision_shape_3d.disabled = true
	for sp in spawnpoints:
		var scene = cow_scenes.pick_random()
		var cow = scene.instantiate()
		get_parent().add_child(cow)
		cow.global_transform = sp.global_transform
		await get_tree().create_timer(1.0).timeout
