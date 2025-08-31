extends CharacterBody3D
class_name Player

@onready var head: Node3D = $Head
@onready var main_cam: Camera3D = $Head/Camera3D
@onready var animation_player: AnimationPlayer = $CanvasLayer2/AnimationPlayer
@onready var distortion_bar: TextureProgressBar = $CanvasLayer/DistortionBar
@onready var chroma_shader: ShaderMaterial = $CanvasLayer2/ColorRect.material
@onready var pcap: CollisionShape3D = $CollisionShape3D
@onready var run_sound: AudioStreamPlayer = $AudioStreamPlayer

# Health system
@export var health = 100
var max_health := 100

# Movement
var direction = Vector3.ZERO
var on_floor := true
var speed_now = 5.0
@export var speed_walk := 5.0
@export var speed_sprint := 10.0
@export var speed_crouch := 2.5
@export var air_control := 2.0
@export var JUMP_VELOCITY := 10.0
@export var mouse_sens := 0.1
@export var lerp_speed := 10.0

# Crouch
@export var dcrouch_speed := 4.0
@export var ucrouch_speed := 6.5

# Head bob
@export var bob_timer := 0.0
@export var bob_amplitude := 0.1
@export var wbob_freq := 10.0
@export var sbob_freq := 15.0
@export var cbob_freq := 5.0
var default_pos := Vector3.ZERO

# Landing bob
@export var lbob_offset := 0.0
@export var land_v_min := -3.0
@export var lbob_ampscl := 0.025

# Health bottles config
const BOTTLE_PATHS = {
	100: "CanvasLayer/Health_bottles/bottle5/100bottle",
	95: "CanvasLayer/Health_bottles/bottle5/75bottle",
	90: "CanvasLayer/Health_bottles/bottle5/50bottle",
	85: "CanvasLayer/Health_bottles/bottle5/25bottle",
	80: "CanvasLayer/Health_bottles/bottle4/100bottle",
	75: "CanvasLayer/Health_bottles/bottle4/75bottle",
	70: "CanvasLayer/Health_bottles/bottle4/50bottle",
	65: "CanvasLayer/Health_bottles/bottle4/25bottle",
	60: "CanvasLayer/Health_bottles/bottle3/100bottle",
	55: "CanvasLayer/Health_bottles/bottle3/75bottle",
	50: "CanvasLayer/Health_bottles/bottle3/50bottle",
	45: "CanvasLayer/Health_bottles/bottle3/25bottle",
	40: "CanvasLayer/Health_bottles/bottle2/100bottle",
	35: "CanvasLayer/Health_bottles/bottle2/75bottle",
	30: "CanvasLayer/Health_bottles/bottle2/50bottle",
	25: "CanvasLayer/Health_bottles/bottle2/25bottle",
	20: "CanvasLayer/Health_bottles/bottle1/100bottle",
	15: "CanvasLayer/Health_bottles/bottle1/75bottle",
	10: "CanvasLayer/Health_bottles/bottle1/50bottle",
	5:  "CanvasLayer/Health_bottles/bottle1/25bottle"
}

# -- HEALTH FUNCTIONS ------------------------------------------------
func dmg(HP) -> void:
	SfXmanager.play_sound("take_dmg")
	health -= HP
	if not HP == 0:
		animation_player.play("Dmg")
	_update_health_bottles()

	if health <= 0:
		health = 0
		die()

	print("Health:", health)

func _update_health_bottles() -> void:
	for threshold in BOTTLE_PATHS.keys():
		var node = get_node(BOTTLE_PATHS[threshold])
		if health < threshold:
			node.hide()
		else:
			node.show()

func die() -> void:
	print("Player died")
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	get_tree().change_scene_to_file("res://Lose.tscn")
	# TODO: Respawn / game over logic

# -- INPUT -----------------------------------------------------------
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	default_pos = head.position
	_update_health_bottles()

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

# -- MOVEMENT & CAMERA ----------------------------------------------
func update_chroma(chroma_strength: float) -> void:
	chroma_shader.set_shader_parameter("Aberration", chroma_strength)

func _physics_process(delta: float) -> void:
	_handle_crouch(delta)
	_apply_gravity(delta)
	_handle_jump()
	_move_player(delta)
	_head_bob(delta)
	_landing_bob(delta)
	move_and_slide()

func _handle_crouch(delta: float) -> void:
	if Input.is_action_pressed("Crouch"):
		pcap.shape.height = clamp(pcap.shape.height - dcrouch_speed * delta, 0.72, 2.0)
		speed_now = speed_crouch
	else:
		pcap.shape.height = clamp(pcap.shape.height + ucrouch_speed * delta, 0.72, 2.0)
		if abs(pcap.shape.height - 2.0) < 0.01:
			if Input.is_action_pressed("Sprint") and is_on_floor() and not is_in_group("Horns"):
				speed_now = speed_sprint
			else:
				speed_now = speed_walk

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func _handle_jump() -> void:
	if is_on_floor():
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_VELOCITY
	else:
		if Input.is_action_just_released("Jump") and velocity.y > 0:
			velocity.y *= 0.5
			print("hop")

func _move_player(delta: float) -> void:
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Back")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)

	if is_on_floor():
		if direction.length() > 0.01:
			velocity.x = direction.x * speed_now
			velocity.z = direction.z * speed_now
		else:
			velocity.x = move_toward(velocity.x, 0, speed_now)
			velocity.z = move_toward(velocity.z, 0, speed_now)
	else:
		# Air control
		var accel = direction * speed_now * air_control * delta
		velocity.x += accel.x
		velocity.z += accel.z

		# Limit air speed
		var horiz_vel = Vector2(velocity.x, velocity.z)
		var max_horiz = min(horiz_vel.length(), speed_walk)
		horiz_vel = horiz_vel.normalized() * max_horiz
		velocity.x = horiz_vel.x
		velocity.z = horiz_vel.y

	if abs(velocity.x) + abs(velocity.z) > 1:
		if not run_sound.playing:
			run_sound.play()
	else:
		run_sound.stop()

var camera_tween : Tween
func camera_shake():
	if camera_tween:
		camera_tween.kill()
	
	var camera_shake = func(n:int):
		main_cam.h_offset = randf_range(-0.1, 0.1)
		main_cam.v_offset = randf_range(-0.1, 0.1)
	
	camera_tween = create_tween()
	camera_tween.tween_method(camera_shake, 0, 1, 0.2)
	camera_tween.tween_callback(func():
		main_cam.h_offset = 0
		main_cam.v_offset = 0)

func _head_bob(delta: float) -> void:
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Back")
	var is_mov = input_dir.length() > 0.01 and is_on_floor()

	if is_mov:
		if Input.is_action_pressed("Crouch"):
			bob_timer += delta * cbob_freq
		elif Input.is_action_pressed("Sprint"):
			bob_timer += delta * sbob_freq
		else:
			bob_timer += delta * wbob_freq

		head.position.y = lerp(head.position.y, default_pos.y + sin(bob_timer) * bob_amplitude, delta * lerp_speed)
		head.position.x = lerp(head.position.x, default_pos.x + sin(bob_timer / 2.0) * bob_amplitude, delta * lerp_speed)
	else:
		head.position = head.position.lerp(default_pos, delta * lerp_speed)

func _landing_bob(delta: float) -> void:
	var just_landed = not on_floor and is_on_floor() and velocity.y < land_v_min
	if just_landed:
		var imp = clamp(abs(velocity.y) * lbob_ampscl, 0.0, 0.2)
		lbob_offset = -imp

	lbob_offset = lerp(lbob_offset, 0.0, delta * lerp_speed)
	head.position.y += lbob_offset
	on_floor = is_on_floor()

# -- UI --------------------------------------------------------------
func _dist_display(amt: int):
	distortion_bar.value = amt

func _on_killzone_body_entered(body: Node3D) -> void:
	die()


func _on_killzone_dying() -> void:
	die()
