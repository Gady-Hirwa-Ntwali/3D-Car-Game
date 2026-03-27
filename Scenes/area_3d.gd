extends Area3D
var life:= 6
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().call_group("ui", "set_life", life)

func _on_body_entered(body: Node3D) -> void:
	life -= 1
	print("remaining life: ", life)
	get_tree().call_group("ui", "set_life", life)
	if life <= 0:
		get_tree().change_scene_to_file("res://dnf.tscn")
