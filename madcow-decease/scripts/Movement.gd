extends CharacterBody3D

#Speed Variables
var current_speed = 5.0
const walking_speed = 5.0
const sprinting_speed = 8.0
const crouching_speed = 3.0

#Player Nodes
@onready var head: Node3D = $neck/head
@onready var standing_collision_shape_3d: CollisionShape3D = $StandingCollisionShape3D
@onready var crouching_collision_shape_3d: CollisionShape3D = $CrouchingCollisionShape3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var neck: Node3D = $neck
@onready var camera_3d: Camera3D = $neck/head/eyes/Camera3D
@onready var eyes: Node3D = $neck/head/eyes

#Movement variables
const jump_velocity = 4.5
var lerp_speed = 10.0
var air_lerp_speed = 1.0
var crouching_depth = -0.5
var free_looking_tilt = 7

#Input Variables
var direction = Vector3.ZERO
const mouse_sens = 0.3

#States
var walking = false
var sprinting = false
var crouching = false
var free_looking = false
var sliding = false

#Slide vars
var slide_timer = 0.0
var slide_timer_max = 1.0
var slide_vector = Vector2.ZERO
var slide_speed = 10.0

#Head Bobing vars
const head_bobbing_sprinting_speed = 22.0
const head_bobbing_walking_speed = 14.0
const head_bobbing_crouching_speed = 10.0
const head_bobbing_sprinting_intensity = 0.2
const head_bobbing_walking_intensity = 0.1
const head_bobbing_crouching_intensity = 0.05

var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0
var head_bobbing_current_intensity = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if free_looking:
			neck.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			neck.rotation.y = clamp(neck.rotation.y, deg_to_rad(-120), deg_to_rad(120))
		else:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	if Input.is_action_pressed("crouch") || sliding:
		current_speed = lerp(current_speed, crouching_speed, delta * lerp_speed)
		head.position.y = lerp(head.position.y,crouching_depth, delta*lerp_speed) 
		standing_collision_shape_3d.disabled = true
		crouching_collision_shape_3d.disabled = false
		#Sliding
		if sprinting && input_dir != Vector2.ZERO:
			sliding = true
			slide_timer = slide_timer_max
			slide_vector = input_dir
			free_looking = true
			
		crouching = true
		walking = false
		sprinting = false
			
	elif !ray_cast_3d.is_colliding():
		standing_collision_shape_3d.disabled = false
		crouching_collision_shape_3d.disabled = true
		head.position.y = lerp(head.position.y,0.0, delta*lerp_speed) 
		if Input.is_action_pressed("sprint"):
			crouching = false
			walking = false
			sprinting = true
			current_speed = lerp(current_speed, sprinting_speed, delta * lerp_speed)
		else:
			crouching = false
			walking = true
			sprinting = false
			current_speed = lerp(current_speed, walking_speed, delta * lerp_speed)
	
	if Input.is_action_pressed("free_look") || sliding:
		free_looking = true
		if sliding:
			camera_3d.rotation.z = lerp(camera_3d.rotation.z, -deg_to_rad(7.0), delta*lerp_speed)
		else:
			camera_3d.rotation.z = -deg_to_rad(neck.rotation.y * free_looking_tilt)
	else:
		free_looking = false
		neck.rotation.y = lerp(neck.rotation.y, 0.0, delta*(lerp_speed - 2)) 
		camera_3d.rotation.z = lerp(camera_3d.rotation.z, 0.0, delta*(lerp_speed - 2))
		
	#sliding
	if sliding:
		slide_timer -= delta
		if slide_timer <= 0:
			sliding = false
			free_looking = false
	
	#Head Bobbing Handeling
	if sprinting:
		head_bobbing_current_intensity = head_bobbing_sprinting_intensity
		head_bobbing_index += head_bobbing_sprinting_speed * delta
	elif walking:
		head_bobbing_current_intensity = head_bobbing_walking_intensity
		head_bobbing_index += head_bobbing_walking_speed * delta
	elif crouching:
		head_bobbing_current_intensity = head_bobbing_crouching_intensity
		head_bobbing_index += head_bobbing_crouching_speed * delta
	
	if is_on_floor() && !sliding && input_dir != Vector2.ZERO:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index/2)
		
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y*(head_bobbing_current_intensity/2.0), delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x*(head_bobbing_current_intensity), delta * lerp_speed)
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0, delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, 0.0, delta * lerp_speed)

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		sliding = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if is_on_floor():
		direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*lerp_speed)
	elif input_dir != Vector2.ZERO:
		direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*air_lerp_speed)
	
	if sliding:
		direction = (transform.basis * Vector3(slide_vector.x, 0, slide_vector.y)).normalized()
		current_speed = (slide_timer + 0.1) * slide_speed
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
			
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
