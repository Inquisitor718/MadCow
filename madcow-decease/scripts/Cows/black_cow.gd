extends CharacterBody3D

@export var black_cow_health := 200
@export var move_speed: float = 1.0
@export var rotation_speed: float = 2.5
@export var fire_rate: float = 1.2
@export var damage: float = 1.0
@export var spread: float = 0.6 #Change kar lena baad me
@export var distortion_add: float = 2.5
@onready var level: Node3D = $"."
@export var b_dmg: float = 1.0

@onready var detection_area = $DetectionArea
@onready var shoot_area = $ShootArea
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var ray_container = $RayContainer
@onready var animation_player: AnimationPlayer = $"Black Cow Animations/AnimationPlayer"
@onready var animation_tree: AnimationTree = $"Black Cow Animations/AnimationTree"

@export var horns_scene: PackedScene
@export var explosion: PackedScene

@onready var state_machine = animation_tree.get("parameters/playback")

var player: CharacterBody3D = null
var group_player: CharacterBody3D = null
var can_shoot = true
var frame_counter := 0
var update_interval := 120  # update path every 6 frames (~0.1s at 60fps)
var cached_next_pos: Vector3

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")



signal on_death

func _ready() -> void:
	
	randomize()

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
			animation_tree.set("parameters/conditions/Idle", false)
			animation_tree.set("parameters/conditions/Walk", true)
			animation_tree.set("parameters/conditions/Shoot", false)
			
			move_and_slide()
			
		if _player_in_shoot_area() and _has_line_of_sight():
			_stop_moving()
			animation_tree.set("parameters/conditions/Shoot", true)
			animation_tree.set("parameters/conditions/Walk", false)
			_try_shoot()
	else:
		_stop_moving()
		animation_tree.set("parameters/conditions/Walk", false)
		animation_tree.set("parameters/conditions/Idle", true)
	
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
		randomize()
		_shoot()
		can_shoot = false
		await get_tree().create_timer(fire_rate).timeout
		can_shoot = true

func _shoot():
	
	if not player:
		return
	
	for r in ray_container.get_children():
		r.target_position.y = randf_range(spread, - spread)
		r.target_position.z = randf_range(spread, - spread)
		if r.is_colliding():
			if r.get_collider().is_in_group("player_S"):
				if r.get_collider().has_method("dmg"):
					r.get_collider().dmg(b_dmg)
					return true

func spawn_explode(position: Vector3):
	if explosion:
		print("boom")
		var boom = explosion.instantiate()
		get_parent().add_child(boom)
		boom.global_transform.origin = position
		boom.global_position.y = global_position.y - 1
		
		#var anim_player = boom.get_node_or_null("AnimationPlayer")
		#if anim_player:
			#anim_player.play("Explosion")
		#if anim_player:
			#anim_player.connect("animation_finished", func(_anim_name):
				#boom.queue_free())
		#else:
			#boom.call_deferred("queue_free")

func Hit(dmg: int) -> void:
	if black_cow_health > 0:
		black_cow_health -= dmg
		print("Enemy Health:", black_cow_health)
		if black_cow_health <= 0:
			animation_tree.set("parameters/conditions/Die", true)
			can_shoot = false
			
			
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
						var horns_instance = horns_scene.instantiate()
						horns_instance.global_position = global_position
						get_tree().current_scene.add_child(horns_instance)
			
			collision_layer = 0
			#TODO: add particle effect
			#particles.emitting = true
			await get_tree().create_timer(1.5).timeout
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
