extends Node3D
class_name WeaponManager

@onready var animation_player: AnimationPlayer = $rig/AnimationPlayer
@onready var Bullet_Point = get_node("%BulletPoint")
@onready var player: CharacterBody3D = $"../../.."
@export var muzzle_flash: Node3D 
@onready var shotgun_sprite: Sprite2D = $"../../../CanvasLayer/Shotgun_sprite"
@onready var revolver_sprite: Sprite2D = $"../../../CanvasLayer/Revolver_Sprite"
@onready var hornyahhh_sprite: Sprite2D = $"../../../CanvasLayer/Hornyahhh_Sprite"
@onready var minigun_sprite: Sprite2D = $"../../../CanvasLayer/Minigun_sprite"
@onready var lines_2: ColorRect = $"../../../CanvasLayer2/Lines2"

@onready var sound_box: AudioStreamPlayer3D = $sound_box

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
enum{NULL, HITSCAN, PROJECTILE}

func _process(delta: float) -> void:
	_check_revolver()
	_check_minigun()
	_check_horns()
	_check_shotgun()

func _check_horns():
	if not Weapon_Stack.find("Horns", 0):
		Global.kills = 0
		get_parent().get_parent().get_parent().add_to_group("Horns")
		hornyahhh_sprite.visible =  true
		lines_2.visible = true
	else:
		get_parent().get_parent().get_parent().remove_from_group("Horns")
		hornyahhh_sprite.visible = false
		lines_2.visible = false

func _check_revolver():
	if not Weapon_Stack.find("Revolver", 0):
		Global.kills = 0
		get_parent().get_parent().get_parent().add_to_group("Revolver")
		revolver_sprite.visible = true
	else:
		get_parent().get_parent().get_parent().remove_from_group("Revolver")
		revolver_sprite.visible = false
func _check_minigun():
	if not Weapon_Stack.find("minigun", 0):
		Global.kills = 0
		get_parent().get_parent().get_parent().add_to_group("minigun")
		minigun_sprite.visible = true
	else:
		get_parent().get_parent().get_parent().remove_from_group("minigun")
		minigun_sprite.visible = false

func _check_shotgun():
	if not Weapon_Stack.find("Shotgun", 0):
		shotgun_sprite.visible = true
	else:
		shotgun_sprite.visible = false

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
	if event.is_action_pressed("Reload") && not Current_Weapon.W_name == "Revolver":
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
			if Current_Weapon.W_name == "Shotgun":
				SfXmanager.play_sound("shotgun_shoot")
			if Current_Weapon.W_name == "minigun":
				SfXmanager.play_sound("minigun_shoot",0.,1.,false, 0., 0.2)
			if Current_Weapon.W_name == "Revolver":
				SfXmanager.play_sound("revolver_shoot")
			#match Current_Weapon.Type:
				#NULL:
					#print("Invalid")
				#HITSCAN:
					#Hit_Scan_Collision(Cam_Collision)
				#PROJECTILE4
					#Launch_Proj(Get_Cam_Collision())
			if Current_Weapon.W_name == "Revolver" && Current_Weapon.Active_ammo == 0:#Checks for Revolver and ammo end tags
				
				var timer = get_node_or_null("WeaponTimer_*")
				for child in get_children():
					if child is Timer and child.name.begins_with("WeaponTimer_"):
						
						child.stop()
						child.emit_signal("timeout")
						break

			for child in muzzle_flash.get_children():
				if child is GPUParticles3D:
					child.restart()
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
	player.camera_shake()
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
	

func _on_weapon_timer_timeout():
	print("Timer end")
	Weapon_Stack.clear()
	Weapon_Stack.push_back("Shotgun")


func _on_weapon_pickup_area_entered(body: Area3D) -> void:
	print("object collided")
	$"../../../Weapon_Pickup".set_deferred("collision_mask", 0)

	if body.has_method("Add_Ammo"):
		print("Ammo adding")
		var Temp_ammo = Weapon_List[body.weapon_name].Stored_ammo
		Temp_ammo += body.increase
		Weapon_List[body.weapon_name].Stored_ammo = Temp_ammo
		emit_signal("Update_Ammo", [Current_Weapon.Active_ammo, Current_Weapon.Stored_ammo])
		$"../../../Weapon_Pickup".set_deferred("collision_mask", (1 << 4) | (1 << 7))
		body.queue_free()

	if body.has_method("Add_Health"):
		print("Health adding")
		var Temp_health = player.health
		Temp_health += body.increase
		player.health = Temp_health
		$"../../../Weapon_Pickup".set_deferred("collision_mask", (1 << 4) | (1 << 7))
		SfXmanager.play_sound("health_pickup")
		print("Health is now " + str(player.health))
		body.queue_free()


	else:
		$"../../../Weapon_Pickup".set_deferred("collision_mask", 1 << 7 )
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
			if body.weapon_name == "minigun":
				SfXmanager.play_sound("minigun_pickup")
			if body.weapon_name == "Revolver":
				SfXmanager.play_sound("revolver_pickup")
			if body.weapon_name == "Horns":
				SfXmanager.play_sound("horns_pickup")
				original_speed = player.speed_walk
				original_hitbox_scale = player.scale

				var tween = create_tween()
				tween.tween_property(player, "speed_walk", player.speed_walk * 3, 0.5)
				tween.tween_property(player, "scale", player.scale * 1.5, 0.5)

			# Create the timer
			var timer := Timer.new()
			timer.name = "WeaponTimer_%s" % str(Time.get_ticks_msec())
			if body.weapon_name == "Revolver":
				timer.wait_time = INF
			else:
				timer.wait_time = Powerup_Duration  

			timer.one_shot = true  
			add_child(timer)

			timer.timeout.connect(func():
				print("Timer end")
				$"../../../Weapon_Pickup".set_deferred("collision_mask", (1 << 4) | (1 << 7))
				# Lock to shotgun after animation finishes
				Next_Weapon = "Shotgun"
				weapon_locked = false  # switching will be allowed again after restore
				exit("Shotgun")
				SfXmanager.play_sound("shotgun_pickup")
				if Current_Weapon.W_name == "Horns":
					hornyahhh_sprite.visible = false
					lines_2.visible = false
					player.speed_walk = original_speed
					player.scale = original_hitbox_scale
				timer.queue_free()
				)
			timer.start()
			
			exit(body.weapon_name)
