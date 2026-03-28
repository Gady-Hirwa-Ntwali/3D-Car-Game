extends Area3D
var life:= 6
signal collision
func _ready() -> void:
	get_tree().call_group("ui", "set_life", life)

func _on_body_entered(body: Node3D) -> void:
	collision.emit()
	life -= 1
	print("remaining life: ", life)
	get_tree().call_group("ui", "set_life", life)
	if life <= 0:
		get_tree().call_deferred("change_scene_to_file","res://dnf.tscn")
