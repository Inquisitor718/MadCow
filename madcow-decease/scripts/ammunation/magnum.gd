extends Node3D

@export var speed: float = 20.0

@export var lifetime: float = 3.0
@export var travelled_distance = 0

var direction: Vector3 = Vector3.ZERO

func _ready():
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
	travelled_distance += speed * delta
	if travelled_distance > 10:
		queue_free()

func _on_area_3d_body_entered(body: PhysicsBody3D) -> void:
	if body.is_in_group("player_S"):
		if body.has_method("dmg"):
			body.dmg(2)
		queue_free()
	if body.is_in_group("Enemy"):
		if body.has_method("Hit"):
			body.Hit(30)
