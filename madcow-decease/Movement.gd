extends CharacterBody3D

@onready var head: Node3D = $Head

var speed_now = 5.0
@export var speed_walk = 5.0
@export var speed_sprint = 10.0
@export var speed_crouch = 2.5
const JUMP_VELOCITY = 4.5

@export var mouse_sens = 0.4


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad((event.relative.x) * mouse_sens * -1))
		head.rotate_x(deg_to_rad((event.relative.y) * mouse_sens *-1))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
func _physics_process(delta: float) -> void:
	
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
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed_now
		velocity.z = direction.z * speed_now
	else:
		velocity.x = move_toward(velocity.x, 0, speed_now)
		velocity.z = move_toward(velocity.z, 0, speed_now)

	move_and_slide()


func _on_timer_timeout() -> void:
	pass # Replace with function body.
