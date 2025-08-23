extends Area3D

var spawned = false

@export var black_cow_scene = preload("res://Scenes/enemy scenes/black_cow.tscn")
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D


@onready var spawnpoint: Marker3D = $spawnpoint
@onready var spawnpoint_2: Marker3D = $spawnpoint2
@onready var spawnpoint_3: Marker3D = $spawnpoint3
@onready var spawnpoint_4: Marker3D = $spawnpoint4
@onready var spawnpoint_5: Marker3D = $spawnpoint5
@onready var spawnpoint_6: Marker3D = $spawnpoint6
@onready var spawnpoint_7: Marker3D = $spawnpoint7
@onready var spawnpoint_8: Marker3D = $spawnpoint8
@onready var spawnpoint_9: Marker3D = $spawnpoint9
@onready var spawnpoint_10: Marker3D = $spawnpoint10
@onready var spawnpoint_11: Marker3D = $spawnpoint11

func _on_body_entered(body: Node3D) -> void:
		var black_cow = black_cow_scene.instantiate()
		
		
		black_cow.global_transform = spawnpoint.global_transform
		get_parent().add_child(black_cow)
		
		
	
