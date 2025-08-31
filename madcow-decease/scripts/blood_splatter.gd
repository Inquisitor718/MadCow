extends Node3D

@onready var particles: GPUParticles3D = $Splatter

func _ready():
	particles.emitting = true
	# Auto free after particle finishes
	get_tree().create_timer(particles.lifetime).timeout.connect(queue_free)
