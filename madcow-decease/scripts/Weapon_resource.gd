extends Resource

class_name Weapon_Resource

@export var W_name: String
@export var Activate_anim: String
@export var Shoot_anim: String
@export var Reload_anim: String
@export var DActivate_anim: String
@export var No_ammo_anim: String

@export var Active_ammo: int
@export var Stored_ammo: int
@export var Magazine: int
@export var Max_ammo: int

@export var Auto_fire: bool
#@export_flags("Hitscan","Projectile") var Type
@export var range: int 
@export var dmg: int
@export var Projectile_To_Load: PackedScene
#@export var Projectile_Velocity: int
@export var Spread_Amount: int
