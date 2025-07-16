extends CharacterBody3D

# Enemy properties
@export var speed = 3.0
@export var detection_range = 15.0
@export var shoot_range = 12.0
@export var bullet_speed = 20.0
@export var health = 100
@export var damage = 25

# Node references
@onready var player_detection_ray = $PlayerDetectionRay
@onready var bullet_spawn = $BulletSpawn  
@onready var shoot_timer = $ShootTimer
@onready var nav_agent = $NavigationAgent3D

# Bullet scene
var bullet_scene = preload("res://EnemyBullet.tscn")

# State variables
var player = null
var player_detected = false
var last_known_player_position = Vector3.ZERO
var is_shooting = false

# AI States
enum State {
	 IDLE,
	 PATROLLING, 
	 CHASING,
	 ATTACKING
}

var current_state = State.IDLE

func _ready():
	 # Connect timer signal
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	 
	 # Find player in scene
	player = get_tree().get_first_node_in_group("player")
	 
	 # Set up navigation agent
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 0.5
	 
	 # Add to enemy group
	add_to_group("enemies")

func _physics_process(delta):
	 # Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	 
	 # Update AI state machine
	update_ai_state()
	 
	
	match current_state:
		State.IDLE:
			handle_idle_state()
		State.CHASING:
			handle_chase_state()
		State.ATTACKING:
			handle_attack_state()
	move_and_slide()


func update_ai_state():
	if not player:
		return
	
	player_detected= detect_player_with_raycast()
	
	var distance_to_player = global_position.distacne_to(player.global_position)
	
	if player_detected and distance_to_player <= shoot_range:
		current_state = State.ATTACKING
	elif player_detected and distance_to_player <= detection_range:
		current_state = State.CHASING
		last_known_player_position = player.global_position
	elif distance_to_player > detection_range*1.5:
		current_state = State.IDLE

func detect_player_with_raycast() -> bool:
	 if not player:
		  return false
		  
	 # Calculate direction to player
	 var direction_to_player = (player.global_position - global_position).normalized()
	 
	 # Set raycast target position
	 player_detection_ray.target_position = direction_to_player * detection_range
	 
	 # Force raycast update
	 player_detection_ray.force_raycast_update()
	 
	 # Check if raycast hit something
	 if player_detection_ray.is_colliding():
		  var collider = player_detection_ray.get_collider()
		  
		  # Check if the collider is the player
		  if collider and collider.is_in_group("player"):
				return true
	 
	 return false

func handle_idle_state():
	 # Stop movement
	 velocity.x = 0
	 velocity.z = 0

func handle_chase_state():
	 if not player:
		  return
		  
	 # Set navigation target to player position
	 nav_agent.target_position = player.global_position
	 
	 # Get next path position
	 var next_path_position = nav_agent.get_next_path_position()
	 
	 # Calculate movement direction
	 var direction = (next_path_position - global_position).normalized()
	 
	 # Apply movement
	 velocity.x = direction.x * speed
	 velocity.z = direction.z * speed
	 
	 # Look at player
	 look_at_target(player.global_position)

func handle_attack_state():
	 if not player:
		  return
		  
	 # Stop movement while attacking
	 velocity.x = 0
	 velocity.z = 0
	 
	 # Look at player
	 look_at_target(player.global_position)
	 
	 # Start shooting if not already shooting
	 if not is_shooting:
		  start_shooting()

func look_at_target(target_position: Vector3):
	 # Calculate direction to target (only horizontal)
	 var direction = Vector3(
		  target_position.x - global_position.x,
		  0,
		  target_position.z - global_position.z
	 ).normalized()
	 
	 # Rotate to face target
	 if direction.length() > 0.1:
		  look_at(global_position + direction, Vector3.UP)

func start_shooting():
	 is_shooting = true
	 shoot_timer.start()

func stop_shooting():
	 is_shooting = false
	 shoot_timer.stop()

func _on_shoot_timer_timeout():
	 if current_state == State.ATTACKING and player_detected:
		  shoot_at_player()

func shoot_at_player():
	 if not player or not bullet_scene:
		  return
		  
	 # Create bullet instance
	 var bullet = bullet_scene.instantiate()
	 
	 # Add bullet to scene tree
	 get_tree().root.add_child(bullet)
	 
	 # Set bullet position
	 bullet.global_position = bullet_spawn.global_position
	 
	 # Calculate direction to player
	 var direction = (player.global_position - bullet_spawn.global_position).normalized()
	 
	 # Initialize bullet
	 bullet.initialize(direction, bullet_speed, damage)

func take_damage(amount: int):
	 health -= amount
	 
	 if health <= 0:
		  die()

func die():
	 # Remove from scene
	 queue_free()

func _on_area_3d_body_entered(body):
	 # Handle collision with player or other objects
	 if body.is_in_group("player"):
		  body.take_damage(damage)
