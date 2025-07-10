extends CanvasLayer

@onready var current_weapon: Label = $GunCounter/WeaponInfo/CurrentWeapon
@onready var current_ammo: Label = $GunCounter/AmmoInfo/CurrentAmmo
@onready var weapon_stack: Label = $GunCounter/StackInfo/WeaponStack




 

func _on_w_manager_update_ammo(Ammo):
	current_ammo.set_text(str(Ammo[0])+" / "+ str(Ammo[1]))


func _on_w_manager_update_weapon_stack(Weapon_Stack):
	weapon_stack.set_text("")
	for i in Weapon_Stack:
		weapon_stack.text += "\n" + i


func _on_w_manager_weapon_change(W_name):
	current_weapon.set_text(W_name)
