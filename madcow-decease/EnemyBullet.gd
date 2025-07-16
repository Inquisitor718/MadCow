extends RigidBody3D

# Bullet properties
var speed = 20.0
var damage = 25
var direction = Vector3.ZERO

# Node references
@onready var life_timer = $LifeTimer

func _ready():
	 # Connect signals
	life_timer.timeout.connect(_on_life_timer_timeout)
	body_entered.connect(_on_body_entered)
	 
	 # Add to bullet group
	add_to_group("enemy_bullets")

func initialize(bullet_direction: Vector3, bullet_speed: float, bullet_damage: int):
	direction = bullet_direction
	speed = bullet_speed
	damage = bullet_damage
	 
	 # Set initial velocity
	linear_velocity = direction * speed

func _on_life_timer_timeout():
	queue_free()


func _on_body_entered(body):
	
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
			queue_free()
	
	elif not body.is_in_group("enemies") and not body.is_in_group("enemy_bullets"):
		queue_free()
