extends CharacterBody3D

@export var white_cow_health := 600
@export var move_speed: float = 1.0
@export var rotation_speed: float = 2.5
@export var fire_rate: float = 0.1
@export var distortion_add: float = 2.5

@onready var detection_area = $DetectionArea
@onready var shoot_area = $ShootArea
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var pellets_spawn = $PelletsSpawn

@export var minigun_scene: PackedScene
@export var pellets: PackedScene
@export var explosion: PackedScene

var player: CharacterBody3D = null
var group_player: CharacterBody3D = null
var can_shoot = true
var frame_counter := 0
var update_interval := 60  # update path every 6 frames (~0.1s at 60fps)
var cached_next_pos: Vector3
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

signal on_death

func _physics_process(delta):
	_apply_gravity(delta)
	if player:
		_face_player(delta)
		if not _player_in_shoot_area():
			if frame_counter % update_interval == 0:
				nav_agent.target_position = player.global_transform.origin
				cached_next_pos = nav_agent.get_next_path_position()
			frame_counter += 1
			var direction = (cached_next_pos - global_transform.origin)
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
	
	_fall_death()

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
		randomize()
		_shoot()
		can_shoot = false
		await get_tree().create_timer(fire_rate).timeout
		can_shoot = true

func _shoot():
	if not player:
		return
	
	var new_pellet = pellets.instantiate()
	get_tree().current_scene.add_child(new_pellet)
	new_pellet.global_transform.origin = pellets_spawn.global_transform.origin
	var direction = (player.global_transform.origin - global_transform.origin)
	new_pellet.direction.y = 0
	new_pellet.direction = direction.normalized()
	if player:
		var shot_direction = (player.global_transform.origin - pellets_spawn.global_transform.origin).normalized()
		new_pellet.direction.x = randfn(shot_direction.x, 0.025)
		new_pellet.direction.y = randfn(shot_direction.y, 0.025)
		new_pellet.direction.z = shot_direction.z
		

func spawn_explode(position: Vector3):
	if explosion:
		print("boom")
		var boom = explosion.instantiate()
		get_parent().add_child(boom)
		boom.global_transform.origin = position
		
		#var anim_player = boom.get_node_or_null("AnimationPlayer")
		#if anim_player:
			#anim_player.play("Explosion")
		#if anim_player:
			#anim_player.connect("animation_finished", func(_anim_name):
				#boom.queue_free())
		#else:
			## Fallback if no animation: free after 1 sec
			#boom.call_deferred("queue_free")

func Hit(dmg: int) -> void:
	if white_cow_health > 0:
		white_cow_health -= dmg
		print("Enemy Health:", white_cow_health)
		if white_cow_health <= 0:
			Global.kills += 1
			Global.distortion += distortion_add
			print(Global.kills)
			emit_signal("on_death")
			if group_player.is_in_group("Revolver"):
				spawn_explode(global_transform.origin)
			if not group_player.is_in_group("Revolver") or not group_player.is_in_group("Horns") or not group_player.is_in_group("minigun"):
				if Global.kills > 3:
					var c = randi() % 100
					print("Random Chod ", c)
					if c < 20:
						var minigun_instance = minigun_scene.instantiate()
						minigun_instance.global_position = global_position
						get_tree().current_scene.add_child(minigun_instance)
			queue_free()


func _on_detection_area_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and body.is_in_group("player_S"):
		player = body

func _on_detection_area_body_exited(body: Node3D) -> void:
	if body == player:
		player = null


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and body.is_in_group("player_S"):
		group_player = body

func _fall_death():
	if global_position.y <-1.0 :
		
		print("enemy dead")
		queue_free()
