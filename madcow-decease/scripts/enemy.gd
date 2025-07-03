extends CharacterBody3D
@onready var nav: NavigationAgent3D = $NavigationAgent3D

const speed = 2.0
const gravity = 10.0


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y -= 2
	var next_location = nav.get_next_path_position()
	var current_location = global_transform.origin
	var new_velocity = (next_location - current_location).normalized() * speed
	
	velocity = velocity.move_toward(new_velocity,0.25)

	move_and_slide()

func target_position(target):
	nav.target_position = target
	
