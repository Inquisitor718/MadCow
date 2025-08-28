extends StaticBody3D
var transition_tween : Tween

var state := 0
@onready var stone_floor: Node3D = $stone_floor
@onready var stone_floor_flicker: Node3D = $stone_floor2
@onready var stone_floor_hole: Node3D = $stone_floor_hole

@onready var collision_shape_normal: CollisionShape3D = $CollisionShape3D

@onready var collision_shape_distorted1: CollisionShape3D = $CollisionShape3D2
@onready var collision_shape_distorted2: CollisionShape3D = $CollisionShape3D3
@onready var collision_shape_distorted3: CollisionShape3D = $CollisionShape3D4
@onready var collision_shape_distorted4: CollisionShape3D = $CollisionShape3D5



func _ready():
	if randf_range(0,1) < 0.2:
		add_to_group("a_hole")
	collision_shape_distorted1.disabled = true
	collision_shape_distorted2.disabled = true
	collision_shape_distorted3.disabled = true
	collision_shape_distorted4.disabled = true

func _process(delta: float) -> void:
	if not is_in_group("a_hole"):
		return
	if Global.distortion > 30 and state == 0:
		a_hole_appear()
	elif Global.distortion < 30 and state == 1:
		a_hole_disappear()

func a_hole_appear():
	#if transition_tween:
		#transition_tween.kill()
	
	transition_tween = create_tween()
	transition_tween.tween_interval(0.05)
	transition_tween.tween_callback(func():
		state = 1
		stone_floor.hide()
		stone_floor_hole.hide()
		stone_floor_flicker.show())
	transition_tween.tween_interval(2.0)
	transition_tween.tween_callback(func():
		stone_floor.hide()
		stone_floor_flicker.hide()
		stone_floor_hole.show()
		collision_shape_normal.disabled = true
		collision_shape_distorted1.disabled = false
		collision_shape_distorted2.disabled = false
		collision_shape_distorted3.disabled = false
		collision_shape_distorted4.disabled = false)
	
func a_hole_disappear():
	#if transition_tween:
		#transition_tween.kill()
	
	transition_tween = create_tween()
	transition_tween.tween_interval(0.05)
	transition_tween.tween_callback(func():
		state = 0
		stone_floor.show()
		stone_floor_hole.hide()
		stone_floor_flicker.hide()
		collision_shape_normal.disabled = false
		collision_shape_distorted1.disabled = true
		collision_shape_distorted2.disabled = true
		collision_shape_distorted3.disabled = true
		collision_shape_distorted4.disabled = true)
		
