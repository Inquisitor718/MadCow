extends Area3D

@export var speed: float = 20.0
@export var lifetime: float = 5.0
@export var damage: int = 20
var direction: Vector3 = Vector3.ZERO
var has_collided := false


func _physics_process(delta):
	if has_collided:
		return

	# Validate direction
	if direction.length() < 0.1:
		queue_free()
		return

	# Move the fireball forward
	global_position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func _on_body_entered(body):
	if has_collided:
		return
	if body.is_in_group("Player") and body.has_method("dmg"):
		body.dmg(damage)
	has_collided = true
	queue_free()
