extends Area3D

var tween: Tween
@onready var shader_mat: ShaderMaterial = $"../../CanvasLayer/ColorRect".material


func _on_body_entered(body: Node3D) -> void:
	print("level script called")
	start_transition()


func start_transition():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(shader_mat, "shader_parameter/transition_amount",1.0, 2.0)
	tween.chain().tween_callback(Callable(self, "_on_transition_finished"))

func _on_transition_finished():
	get_tree().change_scene_to_file("res://Barn.tscn")
