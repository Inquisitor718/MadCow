extends CharacterBody3D

var health = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func Hit(dmg):
	health -= dmg
	print("Target Heath:" ,health)
	if health <=0:
		queue_free()
	

func _on_hitbox_body_entered(body):
	if body.is_in_group("player_S"):
		get_tree().call_group("player_S", "dmg", 10)
		print("entered")
