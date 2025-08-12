extends Node3D

@export var exp_dmg: int
@export var dmg_rad: int
@export var exp_dur: int
func _ready():
	print("Boom spawn")
	var area = Area3D.new()
	add_child(area)
	var collision_shape = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = dmg_rad  # Adjust explosion radius
	collision_shape.shape = shape
	area.add_child(collision_shape)
	area.set_collision_layer(0)
	area.set_collision_mask_value(2, true)
	area.set_collision_mask_value(3, true)
	area.body_entered.connect(_on_body_entered)
	await get_tree().create_timer(exp_dur).timeout
	queue_free()


func _on_body_entered(body):
	if body.has_method("Hit"):
		body.Hit(exp_dmg)
		print("Boom damaged "+ str(exp_dmg))
