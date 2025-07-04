extends CharacterBody3D

@export var movement_speed: float = 3.0
@export var navigation_region: NavigationRegion3D
@export var attack_cooldown: float = 1.5
@export var attack_damage: int = 20
@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")

const ATTACK_RANGE = 2.0

var player = null
var attack_timer := 0.0

func _ready():
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	patroll()

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta):
	if player == null:
		var bodies = $ShapeCast3D.get_collision_count()
		for i in range(bodies):
			var collider = $ShapeCast3D.get_collider(i)
			if collider.is_in_group("Player"):
				player = collider
				break

	if player != null:
		var distance = global_position.distance_to(player.global_position)

		if distance <= ATTACK_RANGE:
			velocity = Vector3.ZERO
			look_at(player.global_position, Vector3.UP)
			attack_timer -= delta
			if attack_timer <= 0.0:
				attack()
				attack_timer = attack_cooldown
			return
		else:
			set_movement_target(player.global_position)

	if navigation_agent.is_navigation_finished():
		patroll()
		return

	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * movement_speed

	if navigation_agent.avoidance_enabled:
		navigation_agent.velocity = new_velocity
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()

func patroll():
	var vertices = navigation_region.navigation_mesh.get_vertices()
	if vertices.size() > 0:
		set_movement_target(vertices[randi_range(0, vertices.size() - 1)])

func attack():
	if player and player.has_method("dmg"):
		player.dmg(attack_damage)
		print("Enemy attacked! Player HP:", player.health)
