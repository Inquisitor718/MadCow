extends CharacterBody3D

enum {
	IDLE,
	TRACKING,
	SHOOTING
}

var state = IDLE
var target

@export var TURN_SPEED = 3
@export var enemy_health = 500

@onready var eyes: Node3D = $Eyes
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@export var navigation_region: NavigationRegion3D
@onready var shoot_timer: Timer = $ShootTimer

func _on_sight_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") || body.is_in_group("player_S"):
		state = TRACKING
		target = body
		shoot_timer.start()


func _on_sight_range_body_exited(body: Node3D) -> void:
	state = IDLE
	shoot_timer.stop()

func _on_shoot_timer_timeout() -> void:
	if ray_cast_3d.is_colliding():
		var hit = ray_cast_3d.get_collider()
		if hit == target:
			hit.dmg(20)
			print("Hit!")
			
		
		
func set_movement_target(target: Vector3):
	navigation_agent_3d.set_target_position(target)
	
func patroll():
	var vertices = navigation_region.navigation_mesh.get_vertices()
	if vertices.size() > 0:
		set_movement_target(vertices[randi_range(0, vertices.size() - 1)])

func Hit(dmg):
	enemy_health -= dmg
	print("Enemy Health:", enemy_health)
	if enemy_health <= 0:
		queue_free()

func _physics_process(delta: float) -> void:
	match state:
		IDLE:
			patroll()
		TRACKING:
			eyes.look_at(target.global_transform.origin, Vector3.UP)
			rotate_y(deg_to_rad(eyes.rotation.y * TURN_SPEED))
			




#extends CharacterBody3D
#
#@export var movement_speed: float = 3.0
#@export var navigation_region: NavigationRegion3D
#@export var attack_cooldown: float = 1.5
#@export var fireball_scene: PackedScene
#@export var attack_damage: int = 20
#
#@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
#@onready var fire_point: Marker3D = $FirePoint
#
#
#
#const ATTACK_RANGE = 2.0
#var player = null
#var attack_timer := 0.0
#
#func _ready():
	#navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	#patroll()
#
#func _physics_process(delta):
	#attack_timer -= delta
	#outter_cast.force_update_transform()
	#inner_cast.force_update_transform()
#
	## Detect player from outer cast
	#if player == null and outter_cast.is_colliding():
		#for i in range(outter_cast.get_collision_count()):
			#var body = outter_cast.get_collider(i)
			#if body.is_in_group("Player"):
				#player = body
				#break
	#
	#if player:
		#var _distance = global_position.distance_to(player.global_position)
		#var direction_to_player = (player.global_position - global_position).normalized()
		#var look_target = global_position + Vector3(direction_to_player.x, 0, direction_to_player.z)
		#look_at(look_target, Vector3.UP)
		## Check inner cast to stop and attack
		#if inner_cast.is_colliding():
			#for i in range(inner_cast.get_collision_count()):
				#if inner_cast.get_collider(i) == player:
					#stop_and_attack(delta)
					#return
#
		## Else, chase the player
		#set_movement_target(player.global_position)
#
	#if navigation_agent.is_navigation_finished():
		#patroll()
		#return
#
	#var next_path_position = navigation_agent.get_next_path_position()
	#var new_velocity = global_position.direction_to(next_path_position) * movement_speed
#
	#if navigation_agent.avoidance_enabled:
		#navigation_agent.velocity = new_velocity
	#else:
		#_on_velocity_computed(new_velocity)
#
#func _on_velocity_computed(safe_velocity: Vector3):
	#velocity = safe_velocity
	#move_and_slide()
#
#func set_movement_target(target: Vector3):
	#navigation_agent.set_target_position(target)
#
#func stop_and_attack(_delta):
	#velocity = Vector3.ZERO
	#var target_dir = (player.global_position - global_position).normalized()
	#look_at(global_position + Vector3(target_dir.x, 0, target_dir.z), Vector3.UP)
#
#
	#if attack_timer <= 0.0:
		#fire_projectile()
		#attack_timer = attack_cooldown
#
#func fire_projectile():
	#if fireball_scene and player:
		#var fireball = fireball_scene.instantiate()
#
		#var start_pos = fire_point.global_transform.origin
		#var target_pos = player.global_transform.origin
		#var dir = (target_pos - start_pos).normalized()
#
		#var fireball_transform = Transform3D()
		#fireball_transform = fireball_transform.looking_at(start_pos + dir, Vector3.UP)
		#fireball_transform.origin = start_pos
		#fireball.global_transform = fireball_transform
#
		#fireball.direction = dir
		#fireball.damage = attack_damage
#
		#get_tree().current_scene.add_child(fireball)
#
#
		#
#func patroll():
	#var vertices = navigation_region.navigation_mesh.get_vertices()
	#if vertices.size() > 0:
		#set_movement_target(vertices[randi_range(0, vertices.size() - 1)])
