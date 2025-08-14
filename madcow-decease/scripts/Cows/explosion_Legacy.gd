extends Node3D

@export var exp_dmg: float
@export var dmg_rad: float
@export var exp_dur: float


var collision_shape = CollisionShape3D.new()
var shape = SphereShape3D.new()
var area = Area3D.new()

func _ready():
	print("Boom spawn")

	add_child(area)
	
	collision_shape.shape = shape
	shape.radius = 0
	area.add_child(collision_shape)
	area.set_collision_layer(0)
	area.set_collision_mask_value(2, true)
	area.set_collision_mask_value(3, true)
	area.body_entered.connect(_on_body_entered)
	await get_tree().create_timer(exp_dur).timeout
	queue_free()
func _process(delta: float) -> void:
	shape.radius = lerp(shape.radius, dmg_rad, 0.1)


func _on_body_entered(body):
	if body.has_method("Hit"):
		body.Hit(exp_dmg)
		print("Boom damaged "+ str(exp_dmg))
