extends Node3D

@onready var hitEffect: GPUParticles3D = $"Hit effect"
@onready var sparks: GPUParticles3D = $Sparks


func _ready():
	hitEffect.emitting = true
	sparks.emitting = true
	
	# Auto free after particle finishes
	get_tree().create_timer(sparks.lifetime).timeout.connect(queue_free)
