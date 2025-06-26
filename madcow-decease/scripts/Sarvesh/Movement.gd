extends CharacterBody3D

@onready var head: Node3D = $Head

var direction = Vector3.ZERO

var on_floor := true

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

#bobbing vars
@export var bob_timer := 0.0
@export var bob_amplitude := 0.1
@export var wbob_freq := 10.0
@export var sbob_freq := 15.0
@export var cbob_freq := 5.0
@export var default_pos := Vector3.ZERO

#jumoing bob vars
@export var lbob_offset = 0.0
@export var land_v_min = -3.0
@export var lbob_ampscl = 2

#mouse movement
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	default_pos = head.position



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
	
#head bobbing
	var is_mov = input_dir.length() > 0.01 and is_on_floor()
	bob_timer = fmod(bob_timer, TAU) #keeps bob movement smooth for long runtimes by limiting value of bob_timer to principle values
	
	#checks for state of motion
	if is_mov:
		if Input.is_action_pressed("Crouch"):
			bob_timer += delta * cbob_freq
		elif Input.is_action_pressed("Sprint"):
			bob_timer += delta * sbob_freq
		else:
			bob_timer += delta * wbob_freq
		#does actual bobbing
		head.position.y = default_pos.y + (sin(bob_timer) * bob_amplitude )
		head.position.x = default_pos.x + (sin(bob_timer / 2.0) * bob_amplitude)
	else:#resets default position of the head when not moving
		head.position.y = lerp(head.position.y, default_pos.y, delta * lerp_speed)
		head.position.x = lerp(head.position.x, default_pos.x, delta * lerp_speed)
	

	move_and_slide()
	
	

	
	# Landing detection and land offset {need to fix}
	var just_landed = not on_floor and is_on_floor() and velocity.y < land_v_min
	if just_landed:
		var imp = clamp(abs(velocity.y) * lbob_ampscl, 0.0, 0.2)
		lbob_offset = -imp
		
	lbob_offset = lerp(lbob_offset, 0.0, delta * lerp_speed)
	head.position.y += lbob_offset
	
	on_floor = is_on_floor()
