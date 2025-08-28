extends CharacterBody3D

@export var baby_cow_health := 100
@export var move_speed: float = 5.0
@export var rotation_speed: float = 3.0
@export var fire_rate: float = 1
@export var stagger_time: float = 0.15 
@export var friendly_lifetime: float = 7.0
@export var distortion_add: float = 2.5

@onready var detection_area = $DetectionArea
@onready var shoot_area = $ShootArea
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var magnum_spawn_1 = $MeshInstance3D/handgun1/Marker3D
@onready var magnum_spawn_2 = $MeshInstance3D/handgun2/Marker3D

@export var magnum: PackedScene
@export var explosion: PackedScene
var frame_counter := 0
var update_interval := 60 # update path every 6 frames (~0.1s at 60fps)
var cached_next_pos: Vector3
var player: CharacterBody3D = null
var group_player: CharacterBody3D = null
var current_target_enemy: CharacterBody3D = null
var is_friendly: bool = false
var friendly_timer: float = 0.0
var mat: StandardMaterial3D
var can_shoot = true
var use_first_gun = true

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	_apply_gravity(delta)
	
	if is_friendly:
		friendly_timer += delta
		if friendly_timer >= friendly_lifetime:
			queue_free()
			return
		_friendly_ai_logic(delta)
		
	else:
		if player:
			_face_player(delta)
		
			if not _player_in_shoot_area():
				if frame_counter % update_interval == 0:
					nav_agent.target_position = player.global_transform.origin
					cached_next_pos = nav_agent.get_next_path_position()
				frame_counter += 1
				var direction = (cached_next_pos- global_transform.origin)
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
	print("moving")
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
	
	_fire_magnum_from_marker(magnum_spawn_1)
	
	await get_tree().create_timer(stagger_time).timeout
	if player:
		_fire_magnum_from_marker(magnum_spawn_2)
	#var spawn_pos = use_first_gun if magnum_spawn_1 else magnum_spawn_2
	#use_first_gun = !use_first_gun
	#
	#var new_magnum = magnum.instantiate()
	#get_tree().current_scene.add_child(new_magnum)
	#
	#new_magnum.global_transform.origin = spawn_pos.global_transform.origin
	#
	#var shot_direction = (player.global_transform.origin - spawn_pos.global_transform.origin).normalized()
	#new_magnum.direction.x = randfn(shot_direction.x, 0.02)
	#new_magnum.direction.y = randfn(shot_direction.y, 0.02)
	#new_magnum.direction.z = shot_direction.z
	

func _fire_magnum_from_marker(spawn_pos: Node3D) -> void:
	var new_magnum = magnum.instantiate()
	get_tree().current_scene.add_child(new_magnum)
	
	new_magnum.global_transform.origin = spawn_pos.global_transform.origin
	
	var shot_direction = (player.global_transform.origin - spawn_pos.global_transform.origin).normalized()
	new_magnum.direction.x = randfn(shot_direction.x, 0.02)
	new_magnum.direction.y = randfn(shot_direction.y, 0.02)
	new_magnum.direction.z = shot_direction.z

func spawn_explode(position: Vector3):
	if explosion:
		var boom = explosion.instantiate()
		boom.global_position = global_position
		get_parent().add_child(boom)
		
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
	baby_cow_health -= dmg
	print("Enemy Health:", baby_cow_health)
	if baby_cow_health <= 0:
		Global.distortion += distortion_add
		if group_player.is_in_group("Revolver"):
			spawn_explode(global_transform.origin)
		if group_player.is_in_group("minigun"):
			_become_friendly()
		else:
			queue_free()
		#if randf() < 0.4 and coin_scene:
			#var coin_instance = coin_scene.instantiate()
			#coin_instance.global_position = global_position + Vector3(0, 1, 0)
			#get_tree().current_scene.add_child(coin_instance)
			
func _become_friendly():
	is_friendly = true
	baby_cow_health = 99999
	friendly_timer = 0.0
	if $MeshInstance3D.material_override:
		mat = $MeshInstance3D.material_override.duplicate()
	else:
		var surf_mat = $MeshInstance3D.mesh.surface_get_material(0)
		if surf_mat:
			mat = surf_mat.duplicate()
		else:
			mat = StandardMaterial3D.new()
	mat.albedo_color = lerp(mat.albedo_color, Color(0,128,0,255), 0.1)
	$MeshInstance3D.material_override = mat
	player = null
	add_to_group("Friendlies")
	remove_from_group("Enemy")

func _friendly_ai_logic(delta):
	if not current_target_enemy or not is_instance_valid(current_target_enemy):
		current_target_enemy = _find_nearest_enemy()
	if current_target_enemy and is_instance_valid(current_target_enemy):
		# Use same logic as enemy used to go after player, but now target current_target_enemy
		var to_enemy = (current_target_enemy.global_transform.origin - global_transform.origin)
		to_enemy.y = 0
		var dist = to_enemy.length()
		if dist > 4.5:
			_face_target(current_target_enemy, delta)
			nav_agent.target_position = current_target_enemy.global_transform.origin
			var next_pos = nav_agent.get_next_path_position()
			var direction = (next_pos - global_transform.origin).normalized()
			velocity.x = lerp(velocity.x, direction.x * move_speed, delta)
			velocity.z = lerp(velocity.z, direction.z * move_speed, delta)
			move_and_slide()
		else:
			_stop_moving()
			_face_target(current_target_enemy, delta)
			_try_shoot_at_enemy(current_target_enemy)
	else:
		_stop_moving()

func _find_nearest_enemy() -> CharacterBody3D:
	var enemies = get_tree().get_nodes_in_group("Enemy")
	var nearest = null
	var min_dist = 99999
	for e in enemies:
		if not is_instance_valid(e): continue
		var dist = global_transform.origin.distance_to(e.global_transform.origin)
		if dist < min_dist:
			min_dist = dist
			nearest = e
	return nearest

func _face_target(target, delta):
	var to_target = (target.global_transform.origin - global_transform.origin).normalized()
	var target_rotation = atan2(to_target.x, to_target.z)
	rotation.y = lerp_angle(rotation.y, target_rotation, rotation_speed * delta)
	
func _try_shoot_at_enemy(enemy):
	if can_shoot:
		_shoot_friendly(enemy)
		can_shoot = false
		await get_tree().create_timer(fire_rate).timeout
		can_shoot = true

func _shoot_friendly(enemy):
	if not enemy.is_in_group("Enemy"):
		current_target_enemy = _find_nearest_enemy()
	elif not enemy or not is_instance_valid(enemy):
		return
	# Use staggered fire like before
	_fire_magnum_from_marker_at_target(magnum_spawn_1, enemy)
	await get_tree().create_timer(stagger_time).timeout
	if enemy and is_instance_valid(enemy):
		_fire_magnum_from_marker_at_target(magnum_spawn_2, enemy)

func _fire_magnum_from_marker_at_target(spawn_marker: Node3D, target_enemy):
	var magnum_instance = magnum.instantiate()
	get_tree().current_scene.add_child(magnum_instance)
	magnum_instance.global_transform.origin = spawn_marker.global_transform.origin
	var dir = (target_enemy.global_transform.origin - spawn_marker.global_transform.origin).normalized()
	magnum_instance.direction.x = randfn(dir.x, 0.01)
	magnum_instance.direction.y = randfn(dir.y, 0.01)
	magnum_instance.direction.z = dir.z

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
