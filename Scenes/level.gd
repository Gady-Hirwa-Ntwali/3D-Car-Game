extends Node3D
var lap:= 0
func _ready() -> void:
	Global.lap = 0
func _on_finish_line_body_entered(body: Node3D) -> void:
	lap += 1
	Global.lap +=1
	print("finish line", lap)
	if lap == 2:
		get_tree().change_scene_to_file("res://Scenes/Won.tscn")
