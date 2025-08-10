extends CharacterBody3D

@export var patched_cow_health := 400
@export var move_speed: float = 2.0
@export var rotation_speed: float = 4.0
@export var fire_rate: float = 2.0

@onready var detection_area = $DetectionArea
@onready var shoot_area = $ShootArea
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var bullet_spawn = $PatchedCow/BulletSpawn

@export var bullet: PackedScene
@export var coin_scene: PackedScene


var player: CharacterBody3D = null
var can_shoot = true

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	_apply_gravity(delta)
	if player:
		_face_player(delta)
		if not _player_in_shoot_area():
			nav_agent.target_position = player.global_transform.origin
			var next_pos = nav_agent.get_next_path_position()
			var direction = (next_pos - global_transform.origin)
			direction.y = 0
			direction = direction.normalized()
			velocity.x = direction.x * move_speed
			velocity.z = direction.z * move_speed
			move_and_slide()
			
		if _player_in_shoot_area() and _has_line_of_sight():
			_stop_moving()
			_try_shoot()
	else:
		_stop_moving()
	move_and_slide()

func _has_line_of_sight() -> bool:
	var from = global_transform.origin
	var to = player.global_transform.origin
	var space = get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.create(from, to)
	params.exclude = [self]
	var result = space.intersect_ray(params)
	return result != null and result.has("collider") and result.collider == player


func _apply_gravity(_delta):
	if not is_on_floor():
		velocity.y -= gravity * _delta
	else:
		velocity.y = 0

func _face_player(delta):
	var to_player = (player.global_transform.origin - global_transform.origin).normalized()
	var target_rotation = atan2(to_player.x, to_player.z)
	rotation.y = lerp_angle(rotation.y, target_rotation, rotation_speed * delta)

func _move_toward_player(_delta):
	var direction = (player.global_transform.origin - global_transform.origin)
	direction.y = 0
	direction = direction.normalized()
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed

func _stop_moving():
	velocity.x = 0
	velocity.z = 0

func _player_in_shoot_area() -> bool:
	return shoot_area.get_overlapping_bodies().has(player)

func _try_shoot():
	if can_shoot:
		_shoot()
		can_shoot = false
		await get_tree().create_timer(fire_rate).timeout
		can_shoot = true

func _shoot():
	if not player:
		return
	
	var new_bullet = bullet.instantiate()
	get_tree().current_scene.add_child(new_bullet)
	new_bullet.global_transform.origin = bullet_spawn.global_transform.origin
	if player:
		var shot_direction = (player.global_transform.origin - bullet_spawn.global_transform.origin).normalized()
		new_bullet.direction = shot_direction


func Hit(dmg: int) -> void:
	patched_cow_health -= dmg
	print("Enemy Health:", patched_cow_health)
	if patched_cow_health <= 0:
		if randf() < 0.4:
			var coin_instance = coin_scene.instantiate()
			coin_instance.global_position = global_position + Vector3(0, 1, 0)
			get_tree().current_scene.add_child(coin_instance)
		queue_free()


func _on_detection_area_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and body.name == "Player":
		player = body

func _on_detection_area_body_exited(body: Node3D) -> void:
	if body == player:
		player = null
