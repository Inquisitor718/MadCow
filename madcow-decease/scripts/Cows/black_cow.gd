extends CharacterBody3D

@export var black_cow_health := 200
@export var move_speed: float = 1.0
@export var rotation_speed: float = 2.5
@export var fire_rate: float = 1.2
@export var damage: float = 20
@export var spread: float = 0.6 #Change kar lena baad me

@onready var detection_area = $DetectionArea
@onready var shoot_area = $ShootArea
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var ray_container = $RayContainer

@export var horns_scene: PackedScene
@export var explosion: PackedScene

var player: CharacterBody3D = null
var group_player: CharacterBody3D = null
var can_shoot = true

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	randomize()

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
					r.get_collider().dmg(20)

func spawn_explode(position: Vector3):
	if explosion:
		print("boom")
		var boom = explosion.instantiate()
		get_parent().add_child(boom)
		boom.global_transform.origin = position
		boom.global_position.y = global_position.y - 1
		
		var anim_player = boom.get_node_or_null("AnimationPlayer")
		if anim_player:
			anim_player.play("Explosion")
		if anim_player:
			anim_player.connect("animation_finished", func(_anim_name):
				boom.queue_free())
		else:
			boom.call_deferred("queue_free")

func Hit(dmg: int) -> void:
	if black_cow_health >= 0:
		black_cow_health -= dmg
		print("Enemy Health:", black_cow_health)
		var c = randi() % 100
		if black_cow_health <= 0:
			print(c)
			if group_player.is_in_group("Revolver"):
				spawn_explode(global_transform.origin)
			if c < 20:
				var horns_instance = horns_scene.instantiate()
				horns_instance.global_position = global_position
				get_tree().current_scene.add_child(horns_instance)
			queue_free()


func _on_detection_area_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and body.name == "Player":
		player = body

func _on_detection_area_body_exited(body: Node3D) -> void:
	if body == player:
		player = null
		
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and body.name == "Player":
		group_player = body
