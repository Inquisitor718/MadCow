extends TextureButton
@onready var node_2d: Node2D = $".."

func _on_pressed() -> void:
	node_2d.get_tree().quit()
