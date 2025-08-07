extends Node3D

@export var speed: float = 10.0

@export var lifetime: float = 3.0
@export var travelled_distance = 0

var target: CharacterBody3D = null
var direction: Vector3 = Vector3.ZERO

func _ready():
	print(direction)
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
	travelled_distance += speed * delta
	if travelled_distance > 10:
		queue_free()

func _on_area_3d_body_entered(body: CharacterBody3D) -> void:
	if body.is_in_group("Player") or body.is_in_group("player_S"):
		if body.has_method("dmg"):
			body.dmg(20)
		queue_free()

#extends Node3D
#
#@export var speed: float = 20.0
#@export var lifetime: float = 3.0
#@export var travelled_distance = 0
#
#var target: CharacterBody3D = null
#
#func _ready():
	#var players = get_tree().get_nodes_in_group("player_S")
	#target = players[0]
	#await get_tree().create_timer(lifetime).timeout
	#queue_free()
#
#func _physics_process(delta: float) -> void:
	#const range = 9000
	
#
	#travelled_distance += speed * delta
	#if travelled_distance > range:
		#queue_free()
	#
#func _on_area_3d_body_entered(body:CharacterBody3D) -> void:
	#if body.is_in_group("Player") or body.is_in_group("player_S"):
		#if body.has_method("dmg"):
			#body.dmg(20)
	#queue_free()
