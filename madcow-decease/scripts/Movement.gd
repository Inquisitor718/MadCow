extends CharacterBody3D

@onready var head: Node3D = $Head

var direction = Vector3.ZERO

var speed_now = 5.0
@export var speed_walk = 5.0
@export var speed_sprint = 10.0
@export var speed_crouch = 2.5
const JUMP_VELOCITY = 4.5

@export var mouse_sens = 0.4

@export var lerp_speed = 10.0

#crouch_depth = -0.64 * pcap.shape.height
@export var dcrouch_speed = 4.0
@export var ucrouch_speed = 6.5
@onready var pcap = $CollisionShape3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad((event.relative.x) * mouse_sens * -1))
		head.rotate_x(deg_to_rad((event.relative.y) * mouse_sens *-1))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
func _physics_process(delta: float) -> void:
	


# movement states
	if Input.is_action_pressed("Crouch"):
		pcap.shape.height -= dcrouch_speed * delta
		pcap.shape.height = clamp(pcap.shape.height, 0.72 , 2)
		speed_now = speed_crouch
	else:
		pcap.shape.height += ucrouch_speed * delta
		pcap.shape.height = clamp(pcap.shape.height, 0.72, 2)
		if abs(pcap.shape.height - 2.0) < 0.01:
			if Input.is_action_pressed("Sprint"):
				speed_now = speed_sprint
			else:
				speed_now = speed_walk


	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Back")
	direction = lerp(direction , (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() , delta * lerp_speed)
	if direction:
		velocity.x = direction.x * speed_now
		velocity.z = direction.z * speed_now
	else:
		velocity.x = move_toward(velocity.x, 0, speed_now)
		velocity.z = move_toward(velocity.z, 0, speed_now)

	move_and_slide()
