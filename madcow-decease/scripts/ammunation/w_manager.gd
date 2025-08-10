extends Node3D

@onready var animation_player: AnimationPlayer = $rig/AnimationPlayer
@onready var Bullet_Point = get_node("%BulletPoint")

@onready var player: CharacterBody3D = $"../../.."

signal Weapon_Change
signal Update_Ammo
signal Update_Weapon_Stack
signal Add_Signal_To_HUD

@export var Melee_Hitbox : ShapeCast3D

var weapon_locked = false  
var original_speed
var original_hitbox_scale
var Shotgun_Store: Weapon_Resource
@export var Powerup_Duration: int
var Current_Weapon = null
var Weapon_Stack = []
var Temp_Stack = []
var Weapon_Indicator = 0
var Next_Weapon: String
var Weapon_List = {}
@export var _weapon_resources: Array[Weapon_Resource]
@export var Start_Weapons: Array[String]
var Ammo_Increase: int = 20
enum{NULL, HITSCAN, PROJECTILE}

func _process(delta: float) -> void:
	_check_minigun()
	
func _check_minigun():
	if not Weapon_Stack.find("minigun", 0):
		get_parent().get_parent().get_parent().add_to_group("have_minigun")
	else:
		get_parent().get_parent().get_parent().remove_from_group("have_minigun")

func _ready():
	Initialize(Start_Weapons)

func _input(event):
	if event.is_action_pressed("Weapon_Up") and not weapon_locked: 
		Weapon_Indicator = min(Weapon_Indicator+1, Weapon_Stack.size()-1)
		exit(Weapon_Stack[Weapon_Indicator])
		print("Up Accept")
		
	if event.is_action_pressed("Weapon_Down") and not weapon_locked:
		Weapon_Indicator = max(Weapon_Indicator-1, 0)
		exit(Weapon_Stack[Weapon_Indicator])
		print("Down Accept")
	
	if event.is_action_pressed("Shoot"):
		if Current_Weapon.W_name == "Horns":
			melee()
		else:
			shoot()
	if event.is_action_pressed("Reload"):
		reload()
func Initialize(_start_weapons: Array):
	for weapon in _weapon_resources:
		Weapon_List[weapon.W_name] = weapon
	
	for i in _start_weapons:
		Weapon_Stack.push_back(i)
	
	Current_Weapon  = Weapon_List[Weapon_Stack[0]]
	emit_signal("Update_Weapon_Stack", Weapon_Stack)
	enter()

func enter():
	animation_player.queue(Current_Weapon.Activate_anim)
	emit_signal("Weapon_Change", Current_Weapon.W_name)
	emit_signal("Update_Ammo", [Current_Weapon.Active_ammo, Current_Weapon.Stored_ammo])

func exit(_next_weapon: String):
	if _next_weapon  != Current_Weapon.W_name:
		if animation_player.get_current_animation() != Current_Weapon.DActivate_anim:
			animation_player.play(Current_Weapon.DActivate_anim)
			Next_Weapon = _next_weapon
			

func Change_Weapon(weapon_name: String):
	Current_Weapon = Weapon_List[weapon_name]
	Next_Weapon = ""
	enter()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == Current_Weapon.DActivate_anim:
		if Next_Weapon == "Shotgun":
			Weapon_List["Shotgun"] = Shotgun_Store
			Current_Weapon = Shotgun_Store
			Weapon_Stack.clear()
			Weapon_Stack.push_back("Shotgun")
			Weapon_Indicator = 0
			
			emit_signal("Update_Weapon_Stack", Weapon_Stack)
			emit_signal("Update_Ammo", [Current_Weapon.Active_ammo, Current_Weapon.Stored_ammo])
			emit_signal("Weapon_Change", "Shotgun")
			
			enter()
		else:
			Change_Weapon(Next_Weapon)
	if anim_name == Current_Weapon.Shoot_anim && Current_Weapon.Auto_fire == true:
		if Input.is_action_pressed("Shoot"):
			shoot()

func shoot():
	if Current_Weapon.Active_ammo != 0:
		#print("ammo available")
		if !animation_player.is_playing():
			#print("animation check pass")
			animation_player.play(Current_Weapon.Shoot_anim)
			#var Cam_Collision = Get_Cam_Collision()
			Current_Weapon.Active_ammo -= 1
			emit_signal("Update_Ammo", [Current_Weapon.Active_ammo, Current_Weapon.Stored_ammo])
			var Spread = Vector2.ZERO
			Load_Projectile(Spread)
			#match Current_Weapon.Type:
				#NULL:
					#print("Invalid")
				#HITSCAN:
					#Hit_Scan_Collision(Cam_Collision)
				#PROJECTILE:
					#Launch_Proj(Get_Cam_Collision())
	else:
		reload()


func melee():
	var Current_Anim = animation_player.get_current_animation()
	
		
	if Current_Anim != Current_Weapon.Melee_Anim:
		animation_player.play(Current_Weapon.Melee_Anim)
		if Melee_Hitbox.is_colliding():
			var colliders = Melee_Hitbox.get_collision_count()
			for c in colliders:
				var Target = Melee_Hitbox.get_collider(c)
				if Target.is_in_group("Enemy") and Target.has_method("Hit"):
					print("melee hit")
					var Direction = (Target.global_transform.origin - owner.global_transform.origin).normalized()
					var Position =  Melee_Hitbox.get_collision_point(c)
					Target.Hit(Current_Weapon.Melee_Damage)


func Load_Projectile(_spread):
	var _projectile:Projectile = Current_Weapon.Projectile_To_Load.instantiate()
	Bullet_Point.add_child(_projectile)
	Add_Signal_To_HUD.emit(_projectile)
	_projectile._Set_Projectile(Current_Weapon.dmg, _spread, Current_Weapon.range)

func reload():
	if Current_Weapon.Active_ammo == Current_Weapon.Magazine:
		return
	elif !animation_player.is_playing():
		if Current_Weapon.Stored_ammo != 0:
			animation_player.play(Current_Weapon.Reload_anim)
			print("reloadd")
			var Reload_Amount = min(Current_Weapon.Magazine-Current_Weapon.Active_ammo, Current_Weapon.Magazine,Current_Weapon.Stored_ammo)
			
			Current_Weapon.Active_ammo = Current_Weapon.Active_ammo + Reload_Amount
			Current_Weapon.Stored_ammo = Current_Weapon.Stored_ammo - Reload_Amount
			
			emit_signal("Update_Ammo", [Current_Weapon.Active_ammo, Current_Weapon.Stored_ammo])
			
		else:
			animation_player.play(Current_Weapon.No_ammo_anim)
#func Get_Cam_Collision():
	#var camera = get_viewport().get_camera_3d()
	#var viewport = get_viewport().get_size()
	#
	#var Ray_Origin = camera.project_ray_origin(viewport/2)
	#var Ray_End = Ray_Origin + camera.project_ray_normal(viewport/2)*Current_Weapon.range
	#
	#var New_Intersection = PhysicsRayQueryParameters3D.create(Ray_Origin,Ray_End)
	#var Intersection = get_world_3d().direct_space_state.intersect_ray(New_Intersection)
	#
	#if not Intersection.is_empty():
		#var Col_Point = Intersection.position
		#return Col_Point
	#else:
		#return Ray_End
		#
#func Hit_Scan_Collision(Collision_Point):
	#var Bullet_Direction = (Collision_Point - Bullet_Point.get_global_transform().origin).normalized()
	#var New_Interection = PhysicsRayQueryParameters3D.create(Bullet_Point.get_global_transform().origin,Collision_Point+Bullet_Direction*2)
	#
	#var Bullet_Collision = get_world_3d().direct_space_state.intersect_ray(New_Interection)
	#
	#if Bullet_Collision:
		#Hit_Scan_Damage(Bullet_Collision.collider, Bullet_Direction, Bullet_Collision.position)
#func Hit_Scan_Damage(Collider, Direction, Position):
	#if Collider.is_in_group("Enemy") and Collider.has_method("Hit"):
		#Collider.Hit(Current_Weapon.dmg, Direction, Position)
		#print("Hit")
		#
		#
#func Launch_Proj(Point: Vector3):
	#var Direction = (Point - Bullet_Point.get_global_transform().origin).normalized()
	#var Projectile = Current_Weapon.Projectile_To_Load.instantiate()
	#
	#
	#Projectile.position = Bullet_Point.global_position
	#Bullet_Point.add_child(Projectile)
	#Projectile.look_at(Point)
	#Projectile.dmg = Current_Weapon.dmg
	#Projectile.set_linear_velocity(Direction*Current_Weapon.Projectile_Velocity)
	

func _on_weapon_timer_timeout():
	print("Timer end")
	Weapon_Stack.clear()
	Weapon_Stack.push_back("Shotgun")
	


func _on_weapon_pickup_body_entered(body: Node3D) -> void:
	print("object collided")
	$"../../../Weapon_Pickup".set_deferred("monitoring", false)

	if body.has_method("Add_Ammo"):
		print("Ammo adding")
		var Temp_ammo = Weapon_List[body.weapon_name].Stored_ammo
		Temp_ammo += Ammo_Increase
		Weapon_List[body.weapon_name].Stored_ammo = Temp_ammo
		emit_signal("Update_Ammo", [Current_Weapon.Active_ammo, Current_Weapon.Stored_ammo])
		$"../../../Weapon_Pickup".set_deferred("monitoring", true)
		body.queue_free()
	else:
		var Weapon_In_Stack = Weapon_Stack.find(body.weapon_name, 0)
		if Weapon_In_Stack == -1:
			print("weapon Picked up")
			
			# Store the current weapon data (assumed to be Shotgun)
			Shotgun_Store = Current_Weapon.duplicate(true)
			
			# Clear and add only the new weapon
			Weapon_Stack.clear()
			Weapon_Stack.push_back(body.weapon_name)
			Weapon_Indicator = 0
			emit_signal("Update_Weapon_Stack", Weapon_Stack)

			# Lock weapon switching
			weapon_locked = true
			if body.weapon_name == "Horns":
				 
				original_speed = player.speed_walk
				original_hitbox_scale = player.scale

				var tween = create_tween()
				tween.tween_property(player, "speed_walk", player.speed_walk * 3, 0.5)
				tween.tween_property(player, "scale", player.scale * 1.5, 0.5)

			# Create the timer
			var timer := Timer.new()
			timer.name = "WeaponTimer_%s" % str(Time.get_ticks_msec())
			timer.wait_time = Powerup_Duration  
			timer.one_shot = true  
			add_child(timer)
			
			timer.timeout.connect(func():
				print("Timer end")
				$"../../../Weapon_Pickup".set_deferred("monitoring", true)
				# Lock to shotgun after animation finishes
				Next_Weapon = "Shotgun"
				weapon_locked = false  # switching will be allowed again after restore
				exit("Shotgun")
				player.speed_walk = original_speed
				player.scale = original_hitbox_scale
				timer.queue_free()
				)
			timer.start()
				
				
			exit(body.weapon_name)
			body.queue_free()
