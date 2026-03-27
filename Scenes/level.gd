extends Node3D
var life:= 6
func _ready() -> void:
	pass 

func _on_finish_line_body_entered(body: Node3D) -> void:
	life -= 1
	print("finish line", life)
